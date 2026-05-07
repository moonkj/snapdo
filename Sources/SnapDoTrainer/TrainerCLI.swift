// SnapDoTrainer — macOS CLI for synthetic training data generation.
// Source: classification spec §4.1 (CLI interface), §4.6 (output layout).
//
// Usage:
//   SnapDoTrainer version
//   SnapDoTrainer list
//   SnapDoTrainer generate --category <code> --count <n> --output <dir> [--seed <u64>]
//   SnapDoTrainer generate-all --output <dir> [--seed <u64>]
import Foundation
import SnapDoCore
#if canImport(CoreML)
import CoreML
#endif
#if canImport(Vision)
import Vision
#endif
#if canImport(ImageIO)
import ImageIO
#endif

@main
struct TrainerCLI {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        guard let command = args.first else {
            printUsage()
            return
        }

        do {
            switch command {
            case "version":
                print("SnapDoTrainer 0.1.0 (SnapDoCore v\(SnapDoCore.version))")

            case "list":
                listCategories()

            case "generate":
                let opts = parseArgs(args.dropFirst())
                guard
                    let codeStr = opts["category"],
                    let code = CategoryCode(rawValue: codeStr),
                    let countStr = opts["count"],
                    let count = Int(countStr),
                    let outputStr = opts["output"]
                else {
                    print("Error: --category, --count, --output are required.")
                    exit(64)
                }
                let seed = opts["seed"].flatMap(UInt64.init) ?? 1
                let noise = Augmentation.Strength(rawValue: opts["noise"] ?? "none") ?? .none
                let outURL = URL(fileURLWithPath: NSString(string: outputStr).expandingTildeInPath)
                try await generate(code: code, count: count, output: outURL, seed: seed, noise: noise)

            case "generate-all":
                let opts = parseArgs(args.dropFirst())
                guard let outputStr = opts["output"] else {
                    print("Error: --output is required.")
                    exit(64)
                }
                let seed = opts["seed"].flatMap(UInt64.init) ?? 1
                let noise = Augmentation.Strength(rawValue: opts["noise"] ?? "none") ?? .none
                let outURL = URL(fileURLWithPath: NSString(string: outputStr).expandingTildeInPath)
                try await generateAll(output: outURL, seed: seed, noise: noise)

            case "train":
                let opts = parseArgs(args.dropFirst())
                guard
                    let inputStr  = opts["input"],
                    let outputStr = opts["output"]
                else {
                    print("Error: --input <training-dir> --output <model-dir> required.")
                    exit(64)
                }
                let iterations = Int(opts["iterations"] ?? "50") ?? 50
                let inURL  = URL(fileURLWithPath: NSString(string: inputStr).expandingTildeInPath)
                let outURL = URL(fileURLWithPath: NSString(string: outputStr).expandingTildeInPath)
                try CreateMLBridge().train(input: inURL, output: outURL, iterations: iterations)

            case "evaluate":
                let opts = parseArgs(args.dropFirst())
                guard
                    let modelStr = opts["model"],
                    let testStr  = opts["test"]
                else {
                    print("Error: --model <path-to-mlmodel> --test <test-dir> required.")
                    exit(64)
                }
                let modelURL = URL(fileURLWithPath: NSString(string: modelStr).expandingTildeInPath)
                let testURL  = URL(fileURLWithPath: NSString(string: testStr).expandingTildeInPath)
                try await evaluate(model: modelURL, testDir: testURL)

            case "split":
                let opts = parseArgs(args.dropFirst())
                guard
                    let inputStr = opts["input"],
                    let testStr  = opts["test"]
                else {
                    print("Error: --input <full-training-dir> --test <out-test-dir> required.")
                    exit(64)
                }
                let pct = Double(opts["pct"] ?? "5") ?? 5
                let inURL   = URL(fileURLWithPath: NSString(string: inputStr).expandingTildeInPath)
                let testURL = URL(fileURLWithPath: NSString(string: testStr).expandingTildeInPath)
                try splitTestSet(input: inURL, test: testURL, percent: pct)

            default:
                printUsage()
            }
        } catch {
            print("ERROR: \(error.localizedDescription)")
            exit(70)
        }
    }

    // MARK: Commands

    static func listCategories() {
        var totalCount = 0
        var totalSubpatterns = 0
        var perTop: [TopCategory: (subs: Int, count: Int)] = [:]
        for c in CategoryCode.allCases {
            totalCount += c.targetCount
            totalSubpatterns += 1
            var bucket = perTop[c.topCategory, default: (0, 0)]
            bucket.subs += 1
            bucket.count += c.targetCount
            perTop[c.topCategory] = bucket
        }
        // Fixed-width without printf — Swift String(format: %s) doesn't accept Swift String.
        func col(_ s: String, w: Int) -> String { s + String(repeating: " ", count: max(0, w - s.count)) }
        print(col("code", w: 32) + col("topCategory", w: 16) + "count")
        print(String(repeating: "-", count: 60))
        for c in CategoryCode.allCases {
            print(col(c.rawValue, w: 32) + col(c.topCategory.rawValue, w: 16) + "\(c.targetCount)")
        }
        print(String(repeating: "-", count: 60))
        for top in TopCategory.allCases {
            if let b = perTop[top] {
                print(col("(\(top.rawValue))", w: 32) + col("\(b.subs) subs", w: 16) + "\(b.count)")
            }
        }
        print(col("TOTAL", w: 32) + col("\(totalSubpatterns) subs", w: 16) + "\(totalCount)")
    }

    @MainActor
    static func generate(
        code: CategoryCode,
        count: Int,
        output: URL,
        seed: UInt64,
        noise: Augmentation.Strength = .none
    ) async throws {
        guard let gen = generator(for: code) else {
            print("Error: no generator implemented yet for \(code.rawValue).")
            exit(65)
        }
        let renderer = SnapImageRenderer()

        let started = Date()
        for i in 1...count {
            let url = snapTrainingOutputURL(base: output, code: code, index: i)
            let view = gen.makeView(seed: seed &+ UInt64(i))
            // Render → augment (if any) → write.
            if noise == .none {
                _ = try renderer.renderPNG(view, to: url)
            } else {
                var rng = SeededRNG(seed: seed &+ UInt64(i) &+ 0xA1A1)
                let plan = Augmentation.plan(strength: noise, rng: &rng)
                var img = try renderer.render(view)
                img = Augmentation.apply(img, plan: plan)
                if plan.applyJPEG {
                    img = Augmentation.roundTripJPEG(img, quality: plan.jpegQuality)
                }
                try SnapImageRenderer.writePNG(img, to: url)
            }
            if i % 25 == 0 || i == count {
                let pct = Int(Double(i) / Double(count) * 100)
                print("[\(code.rawValue)] \(i)/\(count) (\(pct)%)")
            }
        }
        let dt = Date().timeIntervalSince(started)
        print("done — \(count) images in \(String(format: "%.1f", dt))s · \(output.path)")
    }

    @MainActor
    static func generateAll(
        output: URL,
        seed: UInt64,
        noise: Augmentation.Strength = .none
    ) async throws {
        var renderedTotal = 0
        var skipped: [CategoryCode] = []
        for code in CategoryCode.allCases {
            guard generator(for: code) != nil else {
                skipped.append(code)
                continue
            }
            try await generate(
                code: code,
                count: code.targetCount,
                output: output,
                seed: seed,
                noise: noise
            )
            renderedTotal += code.targetCount
        }
        print("---")
        print("Rendered: \(renderedTotal) images.")
        if !skipped.isEmpty {
            print("Skipped (no generator yet): \(skipped.map(\.rawValue).joined(separator: ", "))")
        }
    }

    // MARK: Train/test split helper (spec §5.3)

    /// Move `percent`% of images from each `<input>/<topCategory>/` to
    /// `<test>/<topCategory>/` so they are NOT seen by Create ML.
    /// Default: 5% per spec §5.3 (Test set 5%).
    static func splitTestSet(input: URL, test: URL, percent: Double) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: test, withIntermediateDirectories: true)
        var totalMoved = 0
        for cat in TopCategory.allCases {
            let src = input.appendingPathComponent(cat.rawValue, isDirectory: true)
            let dst = test.appendingPathComponent(cat.rawValue, isDirectory: true)
            guard fm.fileExists(atPath: src.path) else { continue }
            try fm.createDirectory(at: dst, withIntermediateDirectories: true)
            var files = (try? fm.contentsOfDirectory(at: src, includingPropertiesForKeys: nil)) ?? []
            files = files.filter { $0.pathExtension.lowercased() == "png" }
            // Deterministic shuffle: stable sort by name then take stride.
            files.sort { $0.lastPathComponent < $1.lastPathComponent }
            let n = Int(Double(files.count) * percent / 100.0)
            // Take every (1 / pct)-th file so we get a uniform sample.
            let step = max(1, files.count / max(n, 1))
            var moved = 0
            var i = 0
            while moved < n && i < files.count {
                let src = files[i]
                let target = dst.appendingPathComponent(src.lastPathComponent)
                try? fm.moveItem(at: src, to: target)
                moved += 1
                i += step
            }
            totalMoved += moved
            print("\(cat.rawValue): moved \(moved)/\(files.count) into test set.")
        }
        print("Total: \(totalMoved) test images held out.")
    }

    // MARK: Evaluation

    @MainActor
    static func evaluate(model modelURL: URL, testDir: URL) async throws {
        #if canImport(CoreML) && canImport(Vision)
        let compiledURL = try await MLModel.compileModel(at: modelURL)
        let model = try MLModel(contentsOf: compiledURL)
        let vnModel = try VNCoreMLModel(for: model)

        let fm = FileManager.default
        var pairs: [(gt: TopCategory, pred: TopCategory)] = []
        for cat in TopCategory.allCases {
            let folder = testDir.appendingPathComponent(cat.rawValue, isDirectory: true)
            guard fm.fileExists(atPath: folder.path) else { continue }
            let files = (try? fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
            for f in files where f.pathExtension.lowercased() == "png" {
                if let pred = await predict(url: f, model: vnModel) {
                    pairs.append((cat, pred))
                }
            }
        }

        let report = AccuracyMeter.make(from: pairs)
        print(report.formattedTable())
        print("---")
        print(report.formattedConfusion())
        #else
        print("Evaluation requires CoreML+Vision (macOS only).")
        exit(70)
        #endif
    }

    #if canImport(CoreML) && canImport(Vision)
    @MainActor
    static func predict(url: URL, model: VNCoreMLModel) async -> TopCategory? {
        guard let cgImage = loadCGImage(at: url) else { return nil }
        return await withCheckedContinuation { cont in
            let req = VNCoreMLRequest(model: model) { req, _ in
                guard
                    let obs = req.results?.first as? VNClassificationObservation,
                    let cat = TopCategory(rawValue: obs.identifier)
                else { cont.resume(returning: nil); return }
                cont.resume(returning: cat)
            }
            req.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cgImage: cgImage)
            do { try handler.perform([req]) } catch { cont.resume(returning: nil) }
        }
    }

    static func loadCGImage(at url: URL) -> CGImage? {
        guard
            let src = CGImageSourceCreateWithURL(url as CFURL, nil),
            let img = CGImageSourceCreateImageAtIndex(src, 0, nil)
        else { return nil }
        return img
    }
    #endif

    // MARK: Generator registry — each new sub-pattern adds a case here.

    static func generator(for code: CategoryCode) -> MockGenerator? {
        switch code {
        // Receipt (13)
        case .receiptKakaoPay:        return KakaoPayGenerator()
        case .receiptTossTransfer:    return TossTransferGenerator()
        case .receiptTossPayment:     return TossPaymentGenerator()
        case .receiptKakaobank:       return KakaoBankGenerator()
        case .receiptCardKB:          return CardAlertKBGenerator()
        case .receiptCardShinhan:     return CardAlertShinhanGenerator()
        case .receiptCardSamsung:     return CardAlertSamsungGenerator()
        case .receiptCardHyundai:     return CardAlertHyundaiGenerator()
        case .receiptCardWoori:       return CardAlertWooriGenerator()
        case .receiptNaverPay:        return NaverPayGenerator()
        case .receiptBaemin:          return BaeminGenerator()
        case .receiptCoupangEats:     return CoupangEatsGenerator()
        case .receiptOnlineShopping:  return OnlineShoppingGenerator()

        // Place (4)
        case .placeKakaomap:          return KakaoMapGenerator()
        case .placeNavermap:          return NaverMapGenerator()
        case .placeAppleMaps:         return AppleMapsGenerator()
        case .placeAddressText:       return AddressTextGenerator()

        // Conversation (8)
        case .convKakao1on1Light:     return KakaoChat1on1LightGenerator()
        case .convKakao1on1Dark:      return KakaoChat1on1DarkGenerator()
        case .convKakaoGroupLight:    return KakaoChatGroupLightGenerator()
        case .convKakaoGroupDark:     return KakaoChatGroupDarkGenerator()
        case .convKakaoOpen:          return KakaoChatOpenGenerator()
        case .convImessageLight:      return IMessageLightGenerator()
        case .convImessageDark:       return IMessageDarkGenerator()
        case .convInstagramDM:        return InstagramDMGenerator()

        // Link (5)
        case .linkSafariTop:          return SafariTopGenerator()
        case .linkSafariArticle:      return SafariArticleGenerator()
        case .linkChrome:             return ChromeGenerator()
        case .linkYoutubeVideo:       return YoutubeVideoGenerator()
        case .linkSharedLinkCard:     return SharedLinkCardGenerator()

        // Todo (5)
        case .todoNotesLight:         return NotesLightGenerator()
        case .todoNotesDark:          return NotesDarkGenerator()
        case .todoReminders:          return RemindersGenerator()
        case .todoChecklistText:      return ChecklistTextGenerator()
        case .todoImperativeText:     return ImperativeTextGenerator()

        // Other / negative (6)
        case .otherMeme:              return MemeGenerator()
        case .otherProductPhoto:      return ProductPhotoGenerator()
        case .otherFoodPhoto:         return FoodPhotoGenerator()
        case .otherScenery:           return SceneryGenerator()
        case .otherSelfiePortrait:    return SelfiePortraitGenerator()
        case .otherAppUnknown:        return AppUnknownGenerator()
        }
    }

    // MARK: Argv helpers

    static func parseArgs(_ args: ArraySlice<String>) -> [String: String] {
        var dict: [String: String] = [:]
        let arr = Array(args)
        var k = 0
        while k < arr.count {
            let token = arr[k]
            if token.hasPrefix("--") {
                let key = String(token.dropFirst(2))
                if k + 1 < arr.count, !arr[k+1].hasPrefix("--") {
                    dict[key] = arr[k+1]
                    k += 2
                } else {
                    dict[key] = "true"
                    k += 1
                }
            } else {
                k += 1
            }
        }
        return dict
    }

    static func printUsage() {
        print("""
        SnapDoTrainer (SnapDoCore v\(SnapDoCore.version))

        Commands:
          version
          list
          generate     --category <code> --count <n> --output <dir> [--seed <u64>] [--noise none|light|medium|heavy]
          generate-all --output <dir> [--seed <u64>] [--noise none|light|medium|heavy]
          train        --input <training-dir> --output <model-dir> [--iterations 50]
          evaluate     --model <path/to/SnapDoClassifier.mlmodel> --test <test-dir>
          split        --input <training-dir> --test <out-test-dir> [--pct 5]

        Categories: run `SnapDoTrainer list`.
        Noise levels apply augmentation per classification spec §4.4.
        Train/evaluate use Apple CreateML.MLImageClassifier (ScenePrint v1) per spec §5.
        """)
    }
}
