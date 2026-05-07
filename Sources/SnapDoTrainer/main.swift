// SnapDoTrainer — macOS CLI for synthetic training data generation.
// Phase A1 stub. Real generators land in Phase A2-B per classification spec §3, §4.
import Foundation
import SnapDoCore

let args = CommandLine.arguments
print("SnapDoTrainer (SnapDoCore v\(SnapDoCore.version))")

guard args.count > 1 else {
    print("""
    Usage:
      SnapDoTrainer generate --category <id> --count <n> --output <dir>
      SnapDoTrainer generate-all --output <dir>
      SnapDoTrainer version
    """)
    exit(0)
}

switch args[1] {
case "version":
    print("0.0.1")
case "generate", "generate-all":
    print("[TODO] not yet implemented (Phase A2/B)")
default:
    print("Unknown command: \(args[1])")
    exit(1)
}
