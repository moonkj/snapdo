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
- **Files added:** `project.yml`, `Package.swift`, `App/SnapDoApp.swift`, `App/Resources/Info.plist`, `Sources/SnapDoCore/SnapDoCore.swift`, `Sources/SnapDoTrainer/main.swift`, `Tests/SnapDoCoreTests/SnapDoCoreTests.swift`. `.xcodeproj` regenerated via `xcodegen generate` (now git-ignored — project.yml is source of truth).

## 2026-05-07 · Phase A2 — Design system tokens ✅

- **UX brief (background subagent):** consolidated `snapdo_design_system_v1.md` §1-12 + `concept_v3.9.md` §22 + `motion_guide_v1.pdf` §2 into a single `docs/design-tokens-spec.md` (250 lines) — single source for all subsequent token implementations.
- **Architect-confirm decisions** (resolved §9 Open Items in tokens-spec):
  1. Dark-mode `surface=#1C1C1E`, `surface2=#2C2C2E`, `border=#38383A` — iOS HIG defaults. Confirm at first OLED device review.
  2. Dark accent `#7D7AFF` — keeps indigo identity, lifts L by ~12 for OLED contrast. ✅
  3. Category dark variants — derived `+10–12 L`, applied programmatically via HSL builder. ✅
  4. Card shadow dark `radius:12, opacity:0.30` — conservative, easy to dial down later. ✅
  5. Caption Dynamic Type clamp at `.xxxLarge` — accepted to prevent chip layout break.
- **Files added (Sources/SnapDoCore/DesignSystem/):**
  - `SDColor.swift` — `Color.sd.{bg, surface, surface2, border, text, textSecondary, textTertiary, accent, success, warn, error}` + `Color.sd.cat.{receipt, place, conversation, link, todo, other}` + `Color.sd.brand.{kakao, toss, naver}`. Dynamic colour resolves per ColorScheme on iOS+macOS.
  - `SDFont.swift` — `Font.sd.{display, title, heading, body, bodyEmph, footnote, caption}` with Pretendard PostScript-name lookup → SF Pro fallback.
  - `SDSpacing.swift` — `Spacing` enum (xs/sm/md/lg/xl/xxl/xxxl/huge = 4/8/12/16/24/32/48/64), `Radius` enum (xs/sm/md/lg/xl = 4/8/12/16/24), `IconSize` enum (xs/sm/md/lg/xl/empty = 16/20/24/32/40/60).
  - `SDAnimation.swift` — 6 `Animation` extensions (`.snapdoSpring/Quick/Fade/Ease/Bounce/Calm`) + `.snapdoReduced` fallback + `sdStagger(index:reduceMotion:)` helper (50ms × min(index,5)).
  - `SDHaptics.swift` — `SDHaptic` enum with 10 events mapped to UIImpact/UISelection/UINotification generators. `@MainActor` `fire()` ensures call site safety.
  - `Components/SDButton.swift` — primary/secondary/destructive variants, regular/compact size, press FX scale 0.97 with snapdoQuick (or opacity 0.85 under reduced motion).
  - `Components/SDCard.swift` — radius.lg, padding.lg, surface2 bg, dynamic shadow per ColorScheme, 1pt border fallback under reduce-transparency.
  - `Components/SDToast.swift` — top toast, 360 max-width, 48 min-height, success/warning/error variants, 2pt linear progress bar, snapdoSpring enter / snapdoFade exit, fires matching haptic.
  - `Components/SDEmptyState.swift` — icon (60pt) → heading → body → CTA staggered at 50ms each with snapdoCalm.
  - `Components/SDSheet.swift` — `.sdSheet(isPresented:)` modifier, top corners 24, custom drag indicator, .medium+.large detents (iOS-only via `#if os(iOS)`).
- **Debate-2 (Debugger ↔ Coder):** SwiftPM `Bundle.module` not yet emitted because no resources existed; symbol resolved to `Bundle?` (no `.module` member). Two hypotheses:
  - H1: Add a placeholder `.gitkeep` resource and rely on `Bundle.module`.
  - H2: Drop asset-catalogue lookup entirely, programmatic colours only.
  - **Resolution:** H2 — programmatic dynamic colours via `UIColor(dynamicProvider:)` / `NSColor(dynamicProvider:)`. Asset catalogue can be re-introduced in Phase F1 when designers ship `.xcassets`.
- **Debate-3 (Debugger ↔ Coder):** Strict concurrency flagged `SDHaptic.fire()` calling `@MainActor` `fireImpl` from nonisolated context. Two hypotheses:
  - H1: Make `fire()` itself `@MainActor`.
  - H2: Use `MainActor.assumeIsolated` shim.
  - **Resolution:** H1. Haptics are always called from SwiftUI body / button handler (already MainActor). H2 would mask wrong-thread bugs.
- **Debate-4 (Coder ↔ Debugger):** SDSheet's UIBezierPath / UIRectCorner missing on macOS. **Resolution:** wrap whole file in `#if os(iOS)`. SnapDoTrainer (only macOS consumer) doesn't need sheets. Cross-layer announcement noted in Tasklist.
- **Verification matrix (all green):**
  - `swift build` (macOS) ✅
  - `swift test` → 5/5 pass (DesignTokensTests covers Spacing/Radius/IconSize/Stagger/Version) ✅
  - `xcodebuild SnapDo iOS Simulator build` ✅
  - `xcodebuild SnapDoTrainer macOS build` ✅
- **Spec compliance audit:** design-system §1 colors ✅ · §2 typography ✅ · §3 8pt grid ✅ · §4 motion (6 easing) ✅ · §5 haptics (B1/B2/B3/D1/F4 + bonus events) ✅ · §6 components (5 of 6 — Progress component deferred to Phase A6 when used by inbox card stack) · §10 a11y hooks ✅

## 2026-05-07 · Phase A3 — CategoryCode + ImageRenderer + NotesGenerator (1st mock view) ✅

- **CategoryCode** (Sources/SnapDoCore/MockViews/CategoryCode.swift): all 41 sub-patterns from spec §1.1-§1.7, with `.topCategory` (6 enum cases, folder names match Create ML §4.6), `.targetCount` (matches spec totals exactly: receipt 4,300 · place 1,500 · conversation 3,200 · link 1,500 · todo 1,100 · other 2,000 = 13,600 ✅), `.fileSlug` for filenames.
- **MockGenerator protocol + SeededRNG** (xorshift64*): every generator accepts a seed and returns an `AnyView`. Determinism unlocks reproducible debugging during Phase D weakness reinforcement.
- **SnapImageRenderer** (Sources/SnapDoCore/Renderer/): SwiftUI `ImageRenderer` (modern API) → CGImage at 390×844 logical pts × scale 3.0 = 1170 × 2532 px (matches spec §3.1 iPhone 14 Pro target). Cross-platform PNG write via NSBitmapImageRep / UIImage.pngData. Plus `snapTrainingOutputURL(...)` helper for spec §4.6 folder layout.
- **NotesLightGenerator + NotesDarkGenerator** (todo.notes_light / todo.notes_dark): full §3.9 layout — status bar 47pt with random time, NavBar 44pt with `< 메모` / edit / more buttons (Notes-yellow tint), 24pt Bold title from 16-entry pool, 작성 N월 metadata, 6-12 body lines from 30-entry pool, 30% checklist mode with circle bullets.
- **TrainerCLI** (Sources/SnapDoTrainer/TrainerCLI.swift): `@main` entry. Subcommands `version`, `list`, `generate --category --count --output [--seed]`, `generate-all --output [--seed]`. Built-in generator registry maps `CategoryCode → MockGenerator?`; unimplemented categories print "no generator implemented yet".
- **End-to-end verification:**
  - `xcodebuild SnapDoTrainer macOS build` ✅
  - `SnapDoTrainer generate --category todo.notes_light --count 30 --output /tmp/snapdo_test_out` → 30 PNGs, 1170 × 2532 RGBA, ~120-170 KB each, 0.8 s total. ✅
  - Visual review (3 random samples): proper Notes app layout, Korean text rendering correct, checklist branch (30%) confirmed firing on seed 16.
  - `file` reports `PNG image data, 1170 x 2532, 8-bit/color RGBA, non-interlaced` ✅
- **Debate-5 (Coder ↔ Debugger ↔ UX):** First render had empty body. Three competing hypotheses:
  - H1 (Debugger): `ScrollView { ... }.scrollDisabled(true)` is a known ImageRenderer trip-up — ScrollView reports zero intrinsic height during off-screen render.
  - H2 (Coder): `Spacer(minLength: 0)` collapsed ScrollView upstream.
  - H3 (UX): Color was all-white-on-white due to a missed `foregroundStyle`.
  - **Resolution:** H1+H2 combined. Removed ScrollView entirely (irrelevant for a static PNG); content rendered correctly on next run. Lesson logged for Phase B mock views.
- **Spec compliance audit:** classification §1.x sub-pattern counts ✅ · §3.9 Notes layout ✅ · §4.1 CLI shape ✅ · §4.3 renderer ✅ · §4.6 output folder layout ✅
- **Known follow-up:** body-line pool needs deduplication during a single render (currently picks with replacement, occasional duplicate lines). Tracked for Phase B1 data-pool hardening.



