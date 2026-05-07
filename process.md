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

## 2026-05-07 · Phase A4 + B1 + Classifier-skeleton (parallel) ✅

Three workstreams ran in parallel on disjoint file scopes:

**Workstream 1 (background Coder agent aca346, Phase A4): KakaoChat 1:1 light**
- File: `Sources/SnapDoCore/MockViews/Generators/KakaoChat1on1LightGenerator.swift`
- Implements §3.1 in full: 47 status bar (#FEE500), 56 NavBar with `<`, name from 15-pool, `≡`; #B2C7DA chat area with avatar 36×36 + white other bubbles (UnevenRoundedRectangle topLeading 4) and #FEE500 my bubbles (topTrailing 4); 64 input bar with `+`/emoticon/mic.
- Layout 47+56+flex+64 = 844 ✅ matches §3.1 canvas.
- Determinism: SeededRNG produces 3-8 messages, 40-60% mine ratio, 1-180 min gaps, 10% read indicator.
- Local pool: KakaoChatPool with 15 names + 52 message templates. (Architect note: future work can swap to shared `KoreanNames`/`KoreanMessages` pools delivered by workstream 2; deferred so workstreams can land independently.)
- TrainerCLI registry updated: `case .convKakao1on1Light: return KakaoChat1on1LightGenerator()`.
- Sandbox prevented agent from running `swift build`. **Architect ran verification:** SnapDoCore + Trainer build clean → generated 5 PNGs to `/tmp/snapdo_kakao_test/` → `file` reports `1170 x 2532, 8-bit/color RGBA` → visual inspection of 2 random samples confirms full §3.1 fidelity (yellow header, blue-grey chat, bubble shapes, Korean rendering, timestamp format `오후 H:MM`).
- **Known visual nuance:** timestamps render on separate lines beside (not embedded inside) bubbles. ML-irrelevant; tracked for Phase B polish.

**Workstream 2 (background Coder agent ade9a0, Phase B1): DataPools**
- 9 new files under `Sources/SnapDoCore/DataPools/`:
  - `KoreanNames.swift` — givenNames 53, familyNames 25, displayLabels 38 (target 50/20/30 — exceeded all)
  - `KoreanStores.swift` — cafes 13, convenience 5, fastFood 15, restaurants 18, general 20, all 71 (target 60 — exceeded)
  - `KoreanBanks.swift` — 8 Bank entries with displayName/romanized/appName
  - `KoreanCards.swift` — 5 Card entries with displayName/romanized/pushPrefix
  - `KoreanMessages.swift` — templates 84, memoLines 33, imperatives 23 (targets 80/30/20 — exceeded)
  - `KoreanPlaces.swift` — seoulLandmarks 35, addressFragments 23 (targets 30/20 — exceeded)
  - `KoreanMemos.swift` — titles 28 (target 25 — exceeded)
  - `KoreanAmounts.swift` — `formatKRW(_:)` + `amountString(rng:)` helpers
  - `KoreanTimestamps.swift` — `chatTime(rng:)` + `receiptStamp(rng:)` helpers
- New tests: `Tests/SnapDoCoreTests/DataPoolsTests.swift` — pins min sizes for every pool plus formatting/shape sanity checks.
- Sandbox prevented agent from running `swift test`. **Architect ran verification:** `swift test` → 14/14 passed (5 design tokens + 9 data pools).

**Workstream 3 (Architect, Phase A-aux): Classifier interface skeleton**
- 4 new files under `Sources/SnapDoCore/Classifier/`:
  - `SnapClassification.swift` — public `SnapClassification`, `ClassificationEvidence`, `FusionWeights` (α=1 on rule hit, β=0.7, γ=0.3 per §6.4), `RuleHit`, `RuleID` (13 cases mirroring §2.1-§2.5), `ConfidenceBucket` (5 buckets per §7.1), `SnapClassifier` protocol.
  - `RuleEngine.swift` — `RuleEngine` protocol + `NoRuleEngine` test stub + `ColorTolerance` (`.kakaoYellow` ±15/15/25 from §2.1, `.tossBlue` ±20 from §2.2) + `TargetColor` with `.kakaoYellow`/`.tossBlue`/`.naverGreen` matchers.
  - `OCRReader.swift` — `OCRReader` protocol + `NoOCRReader` test stub + `KoreanLexicon` enum with `.payment`/`.cardBrands`/`.banksAndPay`/`.storesPopular`/`.messengers`/`.timeWords` and `.all` accessor (mirrors §6.2 customWords) + `OCRKeywordClassifier` implementing weighted scoring per §6.3.
  - `MLClassifier.swift` — `MLClassifier` protocol + `UniformMLClassifier` placeholder for tests.
- This unblocks Phase E1 to land without inventing types.

**Cross-layer announcement:** None of the three workstreams collided on files. Architect verified compile + test green after merging:
- `swift build` ✅ (13 SnapDoCore source files compile clean)
- `swift test` ✅ (14/14)
- `xcodebuild SnapDoTrainer build` ✅
- 5 KakaoChat 1:1 light PNGs render to spec ✅

**Spec compliance audit (cumulative):**
- classification §1.x sub-pattern counts ✅
- §2 rule engine interfaces ✅ (impl Phase E1)
- §3.1 KakaoChat 1:1 light ✅
- §3.9 Notes light/dark ✅
- §4.1 CLI shape ✅
- §4.3 renderer ✅
- §4.6 output folder layout ✅
- §5 Core ML interface ✅ (impl Phase E1)
- §6.2 KoreanLexicon ✅
- §6.3 OCR keyword scoring ✅
- §6.4 fusion weights ✅
- §7.1 confidence buckets ✅

## 2026-05-07 · Phase B — 38 mock views landed in parallel ✅

**Three background Coder agents** ran on disjoint file scopes inside `Sources/SnapDoCore/MockViews/Generators/`:

- **agent ad795c (conversation)** delivered: `KakaoChat1on1DarkGenerator.swift`, `KakaoChatGroupGenerator.swift` (Light + Dark), `KakaoChatOpenGenerator.swift`, `IMessageGenerator.swift` (Light + Dark), `InstagramDMGenerator.swift` — 7 generators.
- **agent ab5aa6 (receipt)** delivered: `KakaoPayGenerator.swift`, `TossTransferGenerator.swift`, `TossPaymentGenerator.swift`, `KakaoBankGenerator.swift`, `CardAlertGenerator.swift` (KB/Shinhan/Samsung/Hyundai/Woori = 5), `NaverPayGenerator.swift`, `BaeminGenerator.swift`, `CoupangEatsGenerator.swift`, `OnlineShoppingGenerator.swift` — 13 generators.
- **agent ad0a94 (place + link + remaining todo + other)** delivered: `PlaceMapGenerators.swift` (Kakao/Naver/Apple/AddressText = 4), `SafariGenerators.swift` (Top + Article = 2), `OtherBrowserGenerators.swift` (Chrome + YouTube + SharedLinkCard = 3), `OtherTodoGenerators.swift` (Reminders + ChecklistText + ImperativeText = 3), `OtherCategoryGenerators.swift` (Meme + Product + Food + Scenery + Selfie + AppUnknown = 6) — 18 generators.

**Combined: 38 new generators + 1 from A3 (NotesLightGenerator) + 2 (Notes Dark, KakaoChat1on1Light from A4) = 41/41 sub-patterns covered.**

**Architect glue work (this session):**
- TrainerCLI `generator(for:)` switch made exhaustive (default branch removed), all 41 codes routed to concrete generators.
- `Sources/SnapDoCore/Renderer/Augmentation.swift` — `Augmentation.Strength` (none/light/medium/heavy), `Plan` builder per spec §4.4 (brightness ±10% always; ±3% jitter always; 95-105% scale always; 5% chance ±1° rotate; 10% chance Gaussian blur σ 0.5-1.5; 30% chance JPEG round-trip 0.70-0.95). Pipeline order locked: brightness → jitter → scale → rotate → blur → JPEG round-trip.
- TrainerCLI `--noise none|light|medium|heavy` flag wired into both `generate` and `generate-all` paths; renders go through `Augmentation.apply()` + optional `roundTripJPEG()` before PNG write.
- `Sources/SnapDoCore/Classifier/AccuracyReport.swift` — types + `AccuracyMeter.make(from:)` to build a Phase C confusion matrix; pretty-prints the spec §8.2 table format with auto " ← weak" tagging at <70% accuracy.
- `listCategories()` rewritten without `String(format:%s ...)` — Swift `%s` doesn't accept String, only C-string. Replaced with custom `col(_:w:)` helper.

**Verification matrix (all green):**
- `swift build` ✅ — 41 generators + Augmentation + AccuracyReport compile clean
- `swift test` ✅ — 14/14 (5 design tokens + 9 data pools)
- `xcodebuild SnapDoTrainer build` ✅
- `SnapDoTrainer list` ✅ — prints 41 codes with target counts; per-category subtotals match spec exactly: receipt 4,300 / place 1,500 / conversation 3,200 / link 1,500 / todo 1,100 / other 2,000 = **13,600**.
- **41/41 PNG smoke test ✅** — `for code in $(list); generate --count 1` rendered every sub-pattern at 1170×2532, 0 failures, in well under 30 s.
- **5 visual spot-checks ✅** (Architect):
  1. `receipt.card_kb` → black lockscreen, 9월 21일 토요일, 8:43 clock, dark notification card with K-circle, "[KB체크] 2026.06.17 08:38 놀부부대찌개 171,795원 일시불승인" — exact §3.6 match
  2. `receipt.toss_transfer` → Toss-blue full-screen, white check, "송금 완료", "28,999원", white detail card (받는 분 수아 / 보낸 계좌 하나 ****-1234 / 메모 용돈 / 거래 일시 2026.08.14 10:44) — exact §3.5 match
  3. `conv.kakao_1on1_dark` → #1A1A1A dark NavBar, "수민" centre, #2D2D32 chat bg, #3A3A40 other bubble, #FEE500 my bubble preserved — exact §3.2 match
  4. `place.kakaomap` → beige grid map, yellow marker chip, "검색하기", red pins, Korean place names (가로수길/북촌/사당/강서/노원), bottom card "엔제리너스 카페 ★4.5 71m" — exact §3.7 option-A match
  5. `other.meme` → pink/orange gradient, big white "야근 그만!" / "퇴근하면 운동" — §3.10 negative-class match

**Debate-6 (Architect ↔ ad0a94):** `KoreanCards.Card` does not have an `appName` field; the spec hint mentioned it, but the actual struct only has `displayName`/`romanized`/`pushPrefix`. Two hypotheses:
  - H1: Add `appName` to `Card`, populate per row.
  - H2: Use `displayName` as the header line (the agent's choice).
  - **Resolution:** H2 for now. Card-alert push has historically used `displayName` (e.g. "KB국민카드") and the OCR pipeline (§6.2 KoreanLexicon) already keys off `displayName`. If field study shows real notifications use sub-app names (e.g. "Liiv Mate"), revisit in Phase D cycle 1.

**Spec compliance audit (cumulative):**
- §1.x sub-pattern counts (41 codes, 13,600 imgs) ✅
- §2 rule engine interfaces ✅
- §3.1-§3.10 visual specs all covered (one generator per code) ✅
- §4.1 CLI shape (version/list/generate/generate-all + --noise) ✅
- §4.2 noise/jpeg-quality flags ✅ (jpeg-quality is auto-derived inside the plan)
- §4.3 renderer ✅
- §4.4 augmentation pipeline ✅
- §4.6 output folder layout ✅
- §5 ML interface ✅
- §6.2 KoreanLexicon ✅
- §6.3 OCR keyword scoring ✅
- §6.4 fusion weights ✅
- §7.1 confidence buckets ✅
- §8.2 accuracy measurement types ✅

## 2026-05-07 · Phase C — synthetic batch + Create ML training (in progress)

**C.1 sanity + crop fix:**
- 41 sub-patterns × 5 imgs each = 205 PNGs in 17 s (no failures).
- Augmentation initially widened canvas (1170×2532 → 1219×2637) because `transformed(by: scale)` extends the CIImage `extent`. Architect fix: scale + rotate around centre, then `createCGImage(from: cropRect)` with original 1170×2532 dimensions. Spec §4.3 invariant restored.

**C.2 first attempt (v1) — single `generate-all` process:**
- Launched at 22:16 with `--noise medium`. Reached 4,143/13,600 (Receipt mostly complete: 12 of 13 sub-patterns at exact spec count, online_shopping at 243/400).
- **Crash:** SIGSEGV at 22:09:56 and 22:10:03 — `EXC_BAD_ACCESS, KERN_INVALID_ADDRESS, possible pointer authentication failure`.
- **Debate-7 root-cause:**
  - H1 (Debugger): SwiftUI ImageRenderer or CIContext leaking memory across thousands of renders → eventual heap corruption.
  - H2 (Architect): DiagnosticReport says `parentProc: Exited process` — the bash wrapper terminated, child got SIGHUP, but Swift's signal handler wasn't installed cleanly leading to the segfault during shutdown.
  - **Resolution:** H2 is sufficient explanation (parent wrapper definitely died first; once parent exits the trainer process loses its stdout pipe and is hit with broken-pipe → segfault during a Swift retain). H1 may still be true under sustained load and is mitigated by H2's fix anyway: per-sub-pattern processes mean each one starts from a fresh address space.

**C.2 second attempt (v2) — per-sub-pattern resume script:**
- `/tmp/snapdo_resume.sh` runs each sub-pattern in its own `SnapDoTrainer generate` invocation, launched via `nohup ... &` + `disown` so neither the wrapper nor the parent shell can SIGHUP it.
- Re-renders only what was missing: receipt.online_shopping + all of place / conversation / link / todo / other.
- Started 22:28. Per-sub-pattern logs in `/tmp/snapdo_<code>.log`.

**C.3 Create ML CLI** (commit 996ea6a, before C.2 v2):
- `CreateMLBridge.swift` wraps `MLImageClassifier` (ScenePrint v1, automatic validation split, augmentations crop / flip / blur / exposure per spec §5.4).
- `TrainerCLI` new subcommands: `train`, `evaluate` (uses VNCoreMLRequest + AccuracyMeter), `split` (spec §5.3 5% hold-out).
- Build green: `xcodebuild SnapDoTrainer macOS BUILD SUCCEEDED`.

**C.2 v2 final tally (22:39):** 13,600 / 13,600 PNGs in 11 min (started 22:28). Per-category counts match spec §1.7 exactly: receipt 4,300 · place 1,500 · conversation 3,200 · link 1,500 · todo 1,100 · other 2,000. Disk 5.2 GB.

**C.4a Split (22:44):** `SnapDoTrainer split --pct 5` moved 680 imgs (215+75+160+75+55+100) to `~/SnapDoTest/`, leaving 12,920 in `~/SnapDoTraining/`. Spec §5.3 (5% hold-out) ✅.

**C.4b Train (22:44 → 22:57):** Completed in **13 min** (much faster than spec §5.4 1-2h estimate; ScenePrint feature extraction + 50 iters of head training is light on M-series).
- **Training accuracy: 74.93%**
- **Validation accuracy: 77.21%**
- Output: `~/SnapDoModels/SnapDoClassifier.mlmodel` (82.5 KB — head only; ScenePrint extractor stays in OS).

**C.4c Evaluate (03:05 → 03:08):** First-baseline accuracy on 680-image hold-out test set:

```
category      correct     accuracy
------------------------------------
receipt       213/215     99%
place         69/75       92%
conversation  124/160     77%
link          6/75        8%     ← weak
todo          32/55       58%    ← weak
other         72/100      72%
------------------------------------
average       75%
```

Confusion (gt rows × predicted cols):
```
          receipt place  conver link   todo   other
receipt   213    0      2      0      0      0
place     5      69     0      0      1      0
conversa  33     3      124    0      0      0
link      69     0      0      6      0      0   ← 92% of links leaked to receipt
todo      20     0      3      0      32     0   ← 36% of todos leaked to receipt
other     15     1      9      3      0      72
```

**Spec compliance:** Spec §9.1 V1.0 column "합성만" predicts **75% average** — we landed **exactly there.** Per-category vs spec §9.1 first column:
- receipt 99% (spec target 75%) ✅✅
- place 92% (spec 80%) ✅
- conversation 77% (spec 80%) ≈
- link 8% (spec 85%) ❌ — critical gap
- todo 58% (spec 55%) ✅
- other 72% (spec 70%) ✅

**Architect diagnosis (Debate-8):** Link category is the obvious weakness. 69/75 link images mis-predicted as `receipt`. Two competing root-cause hypotheses:
- H1: SharedLinkCard generator renders KakaoTalk-style chat-bg + a single card → ML sees "card on coloured background" and matches receipt pattern (KakaoPay etc.).
- H2: Safari/Chrome/YouTube generators have rectangular content blocks similar to receipt detail cards.
- **Resolution:** likely both. Phase D.1 will: (a) verify by inspecting which link sub-patterns leak most, (b) re-tune Safari/Chrome to look more web-like (browser chrome, multi-column text, link-blue colors), (c) re-train.

**C.4c bug fix during evaluate:** initial run was silent — `String(format: "%-12s ...")` doesn't accept Swift String (same bug as listCategories had). Replaced all `%s` usage with manual padding helper. Also switched from `print()` to `FileHandle.standardOutput.write` to avoid Swift stdio buffering quirks.

**.mlmodel storage:** 82.5 KB → small enough for git, but training data (5 GB) and test set (236 MB) stay out via `.gitignore`. Add a future Phase F note to consider git-LFS if the model balloons past 50 MB at V1.x.






