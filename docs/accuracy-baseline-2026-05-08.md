# SnapDo · Baseline Accuracy Report (Cycle 0)

**Date:** 2026-05-08 03:08
**Model:** SnapDoClassifier.mlmodel (82.5 KB, ScenePrint v1, 50 iters)
**Training data:** 12,920 imgs (synthetic, --noise medium, augmentation crop+flip+blur+exposure)
**Test data:** 680 imgs (5% hold-out, never seen by trainer)

## Per-category accuracy

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

## Confusion matrix (rows = ground truth, cols = predicted)

```
          receipt place  conver link   todo   other
receipt   213    0      2      0      0      0
place     5      69     0      0      1      0
conversa  33     3      124    0      0      0
link      69     0      0      6      0      0
todo      20     0      3      0      32     0
other     15     1      9      3      0      72
```

## Spec compliance (classification spec §9.1 V1.0 column "합성만")

| Category | Measured | Spec target | Δ |
|---|---|---|---|
| receipt | 99% | 75% | +24 ✅ |
| place | 92% | 80% | +12 ✅ |
| conversation | 77% | 80% | -3 ≈ |
| link | 8% | 85% | **-77 ❌** |
| todo | 58% | 55% | +3 ✅ |
| other | 72% | 70% | +2 ✅ |
| **average** | **75%** | **75%** | **0 ✅** |

Average matches spec exactly. Single critical weakness: **link (8%)**.

## Root cause analysis (link category)

- 69/75 link images (92%) are mis-classified as `receipt`.
- Hypotheses logged in process.md Debate-8:
  - H1: `SharedLinkCardGenerator` renders a KakaoTalk-style chat bubble containing a card → ML pattern "card on coloured background" overlaps with KakaoPay receipt.
  - H2: Safari/Chrome/YouTube generators may render rectangular content blocks too close to receipt detail cards.

## Next: Phase D.cycle-1

1. Per-link-subpattern accuracy (need to render & evaluate per-code, not per-top-category).
2. Tweak Safari/Chrome views to look more like web pages (browser chrome, link-blue text, multi-paragraph text rectangles).
3. Re-render link sub-patterns with `--noise medium`, retrain, re-evaluate.
4. Target after cycle-1: link ≥ 50%, average ≥ 80%.
