# SnapDo · Agent Team Charter

**Mission:** Build the SnapDo iOS app from the 13 spec documents to a launch-ready V1.0, following the 12-week roadmap (Phase A → E).

**Stack:** Swift 5.9+, SwiftUI, SwiftData, iOS 17+. Zero external runtime dependencies. 100% on-device ML (Vision framework + Create ML ScenePrint).

**Repo:** https://github.com/moonkj/snapdo

---

## Roles

| Role | Owner | Responsibility |
|---|---|---|
| **Lead / Architect** | Main session | UX/UI design ownership, architecture, integration, final call. Updates `process.md` + commits per phase. |
| **UX Designer** | Spawned subagent | Flows, wireframe-level screen specs, empty/loading/error states, action priority. Skipped when not needed. |
| **Coder** | Spawned subagent | Implements designs in Swift/SwiftUI per architect's plan. Follows `AppColors`, design tokens, conventions. Output = runnable code blocks. |
| **Debugger** | Spawned subagent | Reviews coder's output for logic errors, runtime errors, edge cases, missed conditions. Sends back to Coder. Skipped if no errors. |
| **Test Engineer** | Spawned subagent | Picks high-risk logic, writes XCTest unit/integration tests. On test failure → back to Debugger. |
| **Reviewer** | Spawned subagent | Final code-quality review (readability, maintainability, extensibility). If improvements needed → loop back to Architect with `(개선 R2)`, `(개선 R3)`. |
| **Performance Engineer** | Spawned subagent | Render counts, async/caching, list scroll, battery, animation jank. Runs **before Reviewer** when relevant. |
| **Doc Writer** | Spawned subagent | README/docstring/feature-doc. Runs at final cleanup of each phase. |

---

## Working Protocol

1. **Single source of truth:** `Tasklist.md` (live status) + `process.md` (phase log).
2. **Scientific debate on conflict:** When two roles disagree, each must state its hypothesis + evidence in `process.md` under a "Debate" entry. Architect calls the resolution.
3. **Cross-layer coordination:** Any change touching ≥2 layers (e.g. data model + UI) must announce in `Tasklist.md` "Active edits" and ping affected roles.
4. **Bug debate mode:** When root cause is unclear, ≥2 roles propose competing hypotheses in parallel, each tests, then compare findings.
5. **Spec compliance:** Every shipped feature must trace back to a spec section. Architect runs a spec-vs-impl audit at every phase boundary.

---

## Per-Phase Cycle

```
Architect plan → (UX if needed) → Coder → Debugger? → Test → (Performance if relevant) → Reviewer
                                       ↑                                                      │
                                       └──────────────── loop on issues ──────────────────────┘
                                                                                              ↓
                                                                                Doc Writer → commit/push
```

---

## Spec Source Documents (parsed in prior session)

1. `snapdo_master_for_claude_code.md` (master, 11 PARTs)
2. `snapdo_concept_v3.9.md` (31 sections, 184 cumulative improvements)
3. `snapdo_classification_spec_v1.pdf` (12 sections, 6 cats × 41 sub-patterns × 13,600 imgs)
4. `snapdo_design_system_v1.md` (12 sections — tokens, components, a11y)
5. `snapdo_motion_guide_v1.pdf` (8 sections, 6 easing tokens, 18 motion items M1-M18)
6. `snapdo_v1_roadmap.md` (12-week plan, Phase A1 → E10)
7. `snapdo_wireframes_v1.pdf` (43+ screens, 9 groups A-I)
8. `snapdo_main_visualization_v6.pdf` (19 screens with motion)
9. `snapdo_main_visualization_v5.pdf` (19 screens static)
10. `snapdo_onboarding_visualization_v2.pdf` (7 onboarding + 2 expiry)
11. `snapdo_app_icon_candidates.pdf` (6 candidates, recommended: Card Stack + Check)
12. `snapdo_appstore_screenshots.pdf` (6 KR/EN, ASO keywords)
13. (Download guide)

Architect must keep this list in mind during every decision and audit deliverables against it.
