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
                let outURL = URL(fileURLWithPath: NSString(string: outputStr).expandingTildeInPath)
                try await generate(code: code, count: count, output: outURL, seed: seed)

            case "generate-all":
                let opts = parseArgs(args.dropFirst())
                guard let outputStr = opts["output"] else {
                    print("Error: --output is required.")
                    exit(64)
                }
                let seed = opts["seed"].flatMap(UInt64.init) ?? 1
                let outURL = URL(fileURLWithPath: NSString(string: outputStr).expandingTildeInPath)
                try await generateAll(output: outURL, seed: seed)

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
        print(String(format: "%-30s %-15s %s", "code", "topCategory", "count"))
        print(String(repeating: "-", count: 60))
        for c in CategoryCode.allCases {
            print(String(format: "%-30s %-15s %d",
                         c.rawValue, c.topCategory.rawValue, c.targetCount))
        }
        print(String(repeating: "-", count: 60))
        for top in TopCategory.allCases {
            if let b = perTop[top] {
                print(String(format: "%-30s %-15s %d",
                             "(\(top.rawValue))", "\(b.subs) subs", b.count))
            }
        }
        print(String(format: "%-30s %-15s %d",
                     "TOTAL", "\(totalSubpatterns) subs", totalCount))
    }

    @MainActor
    static func generate(code: CategoryCode, count: Int, output: URL, seed: UInt64) async throws {
        guard let gen = generator(for: code) else {
            print("Error: no generator implemented yet for \(code.rawValue).")
            exit(65)
        }
        let renderer = SnapImageRenderer()

        let started = Date()
        for i in 1...count {
            let url = snapTrainingOutputURL(base: output, code: code, index: i)
            let view = gen.makeView(seed: seed &+ UInt64(i))
            _ = try renderer.renderPNG(view, to: url)
            if i % 25 == 0 || i == count {
                let pct = Int(Double(i) / Double(count) * 100)
                print("[\(code.rawValue)] \(i)/\(count) (\(pct)%)")
            }
        }
        let dt = Date().timeIntervalSince(started)
        print("done — \(count) images in \(String(format: "%.1f", dt))s · \(output.path)")
    }

    @MainActor
    static func generateAll(output: URL, seed: UInt64) async throws {
        var renderedTotal = 0
        var skipped: [CategoryCode] = []
        for code in CategoryCode.allCases {
            guard generator(for: code) != nil else {
                skipped.append(code)
                continue
            }
            try await generate(code: code, count: code.targetCount, output: output, seed: seed)
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
        case .todoNotesLight:     return NotesLightGenerator()
        case .todoNotesDark:      return NotesDarkGenerator()
        case .convKakao1on1Light: return KakaoChat1on1LightGenerator()
        // Phase A4-B2 will fill in the rest. Spec spec §3.1-§3.10 + §1.x sub-pattern table.
        default: return nil
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
          generate     --category <code> --count <n> --output <dir> [--seed <u64>]
          generate-all --output <dir> [--seed <u64>]

        Categories: run `SnapDoTrainer list`.
        """)
    }
}
