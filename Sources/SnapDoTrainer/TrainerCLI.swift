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

        Categories: run `SnapDoTrainer list`.
        Noise levels apply augmentation per classification spec §4.4.
        """)
    }
}
