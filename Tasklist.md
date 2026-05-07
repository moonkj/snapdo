# SnapDo · Tasklist (Live)

> Live status board. All agents read & update this. One row = one atomic task.
> Status legend: `pending` · `in_progress` · `blocked` · `review` · `done`

## Active edits (cross-layer announcements)
_Empty. Add a line here whenever a change touches ≥2 layers, with affected roles tagged._

---

## Phase A — Infrastructure (Week 1-2)

| ID | Task | Owner | Status | Spec ref |
|---|---|---|---|---|
| A1 | Init Xcode project: SnapDo.xcodeproj + 3 targets (SnapDo iOS app / SnapDoCore Swift Package / SnapDoTrainer macOS CLI) | Architect+Coder | done | classification §0, roadmap A1 |
| A1.1 | `.gitignore`, `README.md`, repo bootstrap | Architect | done | — |
| A1.2 | Decide Swift toolchain version, deployment targets (iOS 17 / macOS 14) | Architect | done | concept §11 |
| A1.3 | XcodeGen project.yml + Package.swift, both schemes build green (`xcodebuild` SnapDo iOS sim + SnapDoTrainer macOS) | Architect | done | classification §0 |
| A2 | Design tokens in SnapDoCore: AppColors (light+dark), Typography (Pretendard), Easing 6 tokens, Spacing 8pt grid, Haptics, Components | Architect+UX+Coder | done | design system §1-3, motion §2 |
| A2.1 | UX brief consolidated to `docs/design-tokens-spec.md` (250 lines, 9 sections) | UX | done | design system §1-12 |
| A2.2 | SDColor (semantic + 6 categories HSL S70 + 3 KR brands) | Coder | done | tokens-spec §1 |
| A2.3 | SDFont (7 type tokens + Pretendard fallback chain) | Coder | done | tokens-spec §2 |
| A2.4 | Spacing/Radius/IconSize tokens + 5 unit tests | Coder+Test | done | tokens-spec §3, §6.6 |
| A2.5 | Animation tokens (6 easing + reduce-motion + stagger helper) | Coder | done | tokens-spec §4, motion §2 |
| A2.6 | SDHaptic (10 events: B1/B2/B3/D1/F4 + snap-create/destructive) | Coder | done | tokens-spec §5 |
| A2.7 | SDButton / SDCard / SDToast / SDEmptyState / SDSheet (iOS) | Coder | done | tokens-spec §6 |
| A3 | CategoryCode enum (41 sub-patterns + counts + topCategory + folderName) | Architect+Coder | done | classification §1.1-§1.7 |
| A4 | ImageRenderer (SwiftUI View → CGImage → PNG, 1170×2532 @3x) | Coder | done | classification §4.3 |
| A5 | NotesLight + NotesDark generators (todo.notes_light/dark) | Coder | done | classification §3.9 |
| A5.1 | MockGenerator protocol + SeededRNG (deterministic) | Architect | done | classification §4 |
| A5.2 | NotesPool (16 titles, 30 body lines, 13 timestamps) | Coder | done | classification §3.9 |
| A6 | SnapDoTrainer CLI (`version`, `list`, `generate`, `generate-all`) | Coder | done | classification §4.1 |
| A6.1 | End-to-end generation: 30 todo.notes_light PNGs · 1170×2532 PNG verified · 30% checklist branch fires | Test | done | classification §3.9, §4.6 |
| A7 | KakaoChat 1:1 light mock view — primary category | Coder+Debugger | done | classification §3.1 |
| A7.1 | KakaoColors palette (#FEE500, #B2C7DA, #F2F4F6, #8B95A1) + KakaoChatPool (15 names + 52 messages) | Coder | done | classification §3.1 |
| A7.2 | UnevenRoundedRectangle bubble tails (other top-leading 4, mine top-trailing 4) | Coder | done | classification §3.1 |
| A7.3 | Build verified · 5 PNGs rendered 1170×2532 · visual review pass | Architect | done | classification §3.1 |
| A8 | Classifier interface skeleton (RuleEngine, OCRReader, MLClassifier, FusionWeights, ConfidenceBucket) ready for Phase E1 | Architect | done | classification §2/§5/§6/§7.1 |

## Phase B — Data Pools + Variants (Week 3)
| ID | Task | Owner | Status | Spec ref |
|---|---|---|---|---|
| B1 | DataPools: 9 pool files (Names 116, Stores 71, Banks 8, Cards 5, Messages 84+33+23, Places 35+23, Memos 28, Amounts helper, Timestamps helper) + DataPoolsTests | Coder+Test | done | classification §4.1 |
| B2 | All remaining 38 mock views — 3 background agents in parallel | Coder | done | classification §3.2-3.10 |
| B2.conv | 7 conversation: kakao 1:1 dark, group light/dark, open chat, iMessage light/dark, Instagram DM | agent ad795c | done | §3.1-3.4 |
| B2.recpt | 13 receipt: KakaoPay, Toss transfer/payment, KakaoBank, 5 card alerts (KB/Shinhan/Samsung/Hyundai/Woori), NaverPay, Baemin, CoupangEats, OnlineShopping | agent ab5aa6 | done | §3.4-3.6 |
| B2.place | 4 place: KakaoMap, NaverMap, AppleMaps, AddressText | agent ad0a94 | done | §3.7 |
| B2.link | 5 link: SafariTop, SafariArticle, Chrome, YouTube, SharedLinkCard | agent ad0a94 | done | §3.8 |
| B2.todo | 3 remaining todo: Reminders, ChecklistText, ImperativeText | agent ad0a94 | done | §3.9 |
| B2.other | 6 other: Meme, ProductPhoto, FoodPhoto, Scenery, SelfiePortrait, AppUnknown | agent ad0a94 | done | §3.10 |
| B2.cli | TrainerCLI registry: 41/41 sub-patterns wired (default removed, exhaustive switch) | Architect | done | §4.1 |
| B2.smoke | 41/41 PNGs rendered, 0 failures, 5 visual spot-checks pass spec fidelity | Architect+Test | done | §3.x |
| B3 | Augmentation module (brightness/jitter/scale/rotate/blur/JPEG round-trip), `--noise` flag in trainer | Architect | done | classification §4.2, §4.4 |
| B3.1 | AccuracyReport + AccuracyMeter for Phase C measurement | Architect | done | §8.2 |

## Phase C — First ML training (Week 4)
| ID | Task | Owner | Status | Spec ref |
|---|---|---|---|---|
| C1 | Generate 13,600 training images | Coder (CLI) | pending | classification §4.5 |
| C2 | Create ML training (50 iters, ScenePrint) | Architect | pending | classification §5.4 |
| C3 | Accuracy measurement script vs personal-phone test set | Test | pending | classification §8.2 |

## Phase D — Weakness reinforcement (Week 5-7, 5 cycles)
_Defined per-cycle by audit findings._

## Phase E — Main app integration (Week 8)
| ID | Task | Owner | Status | Spec ref |
|---|---|---|---|---|
| E1 | SnapDoClassifier: 4-stage pipeline (Rule → ML → OCR → Fusion) | Coder | pending | classification §2,§5,§6 |
| E2 | Inbox/Library/Settings tabs, B/C/D/E/F screens | Coder+UX | pending | wireframes A-I |
| E3 | User-correction sheet + SwiftData | Coder | pending | classification §7 |
| E4 | StoreKit 2 IAP (₩3,900) + 14-day trial | Coder | pending | concept §13 |
| E5 | Widgets G1-G4 (small/medium/inline/circular) | Coder | pending | wireframes G |

## Phase F-G — Design assets + release prep (Week 9-12)
| ID | Task | Owner | Status | Spec ref |
|---|---|---|---|---|
| F1 | App icon (Candidate 01 Card Stack + Check) | Architect | pending | icon candidates |
| F2 | App Store 6 screenshots (KR + EN) | Architect | pending | appstore screenshots |
| F3 | Final QA + perf pass (500ms classify, 100MB memory) | Performance+Test | pending | classification §8 |
| F4 | App Store submission | Architect | pending | concept §15 |

---

## Debate log
_Append a `### Debate-N` block whenever ≥2 roles disagree._

## Decisions
_Append a `### Decision-N` block when Architect resolves an open question._
