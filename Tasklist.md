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
| A3 | NotesGenerator (Apple Notes light mock view, simplest first) | Coder | pending | classification §3.9 |
| A4 | ImageRenderer (SwiftUI View → NSImage → PNG) for SnapDoTrainer | Coder | pending | classification §4.3 |
| A5 | KakaoChat 1:1 light mock view — primary category | Coder+Debugger | pending | classification §3.1 |
| A6 | First 100 imgs export sanity-check + visual review | Architect+UX | pending | classification §8 Phase A |

## Phase B — Data Pools + Variants (Week 3)
| ID | Task | Owner | Status | Spec ref |
|---|---|---|---|---|
| B1 | DataPools: Names (100+), Messages (100+), Stores (100+), Banks/Cards | Coder | pending | classification §4.1 |
| B2 | All remaining 39 mock views (kakao dark/group, kakaopay, toss, card alerts ×5, naver/kakao/apple maps, safari ×3, notes dark/reminders, memes etc.) | Coder | pending | classification §3.2-3.10 |
| B3 | Augmentation module (JPEG, blur, brightness, color jitter, rotate, scale, status-bar variation, notch mask) | Coder | pending | classification §4.4 |

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
