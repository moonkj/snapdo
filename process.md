# SnapDo · Process Log

Chronological build log. Architect writes one entry per phase milestone.
Each entry: timestamp · phase · what changed · spec ref · commit hash.

---

## 2026-05-07 · Bootstrap

- Repo initialized at `/Users/kjmoon/SnapDo`, connected to `https://github.com/moonkj/snapdo.git`.
- Charter (`AGENTS.md`), task board (`Tasklist.md`), this log (`process.md`) created.
- Stack confirmed: Swift 5.9, SwiftUI, SwiftData, iOS 17 / macOS 14.
- Roadmap entry point: Phase A1 — Xcode project init.

## 2026-05-07 · Phase A1 — Xcode project init ✅

- **Decision-1 (Architect):** Use **XcodeGen** for project generation. Single `project.yml` describes 3-target structure (SnapDo iOS app / SnapDoCore SwiftPM library / SnapDoTrainer macOS CLI) per classification spec §0. Rejected Tuist (learning curve) and pure-SPM (awkward iOS app target).
- **Debate-1:** Test-target wiring. XcodeGen rejected `SnapDoCoreTests` as a scheme test target because SwiftPM testTargets cannot be referenced directly. Two hypotheses considered:
  - H1 (Architect): drop `test:` from schemes, run `swift test` separately.
  - H2 (Test): create native Xcode test targets duplicating SwiftPM ones.
  - **Resolution:** H1. SwiftPM tests stay inside the package (`Tests/SnapDoCoreTests`). One source of truth, no duplication. Trade-off: Xcode UI Test Navigator won't list them, but `swift test` from CLI works and `xcodebuild test -scheme SnapDo` can be added later when iOS-side tests appear.
- **Verification matrix (all green):**
  - `swift build` → SnapDoCore compiles
  - `swift test` → 1/1 pass
  - `xcodebuild -scheme SnapDo -destination 'generic/platform=iOS Simulator' build` → BUILD SUCCEEDED
  - `xcodebuild -scheme SnapDoTrainer -destination 'platform=macOS' build` → BUILD SUCCEEDED
  - `SnapDoTrainer version` → `0.0.1` (CLI runs end-to-end, links SnapDoCore)
- **Spec compliance:** classification §0 three-target structure ✅ · concept §11 (iOS 17+, on-device, no external deps) ✅ · concept §13 (NSPhotoLibraryUsageDescription required strings present) ✅
- **Files added:** `project.yml`, `Package.swift`, `App/SnapDoApp.swift`, `App/Resources/Info.plist`, `Sources/SnapDoCore/SnapDoCore.swift`, `Sources/SnapDoTrainer/main.swift`, `Tests/SnapDoCoreTests/SnapDoCoreTests.swift`. `.xcodeproj` is git-tracked (regenerated via `xcodegen generate`).

