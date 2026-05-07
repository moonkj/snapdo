# SnapDo Design Tokens — Consolidated Spec v1.0

**Source of truth for the Coder.** Consolidates `snapdo_design_system_v1.md` (§1–§12), `snapdo_concept_v3.9.md` §22, and `snapdo_motion_guide_v1.pdf` §2. Coder implements directly from this file; do not re-read the source PDFs.

Decisions marked `[Architect-confirm]` are opinionated calls where the source was ambiguous.

---

## 1. Color Tokens

### 1.1 System / Semantic Palette

All hex values are sRGB. Light values are pinned in source; dark values marked `[Architect-confirm]` are tuned to iOS HIG dark-mode conventions.

| Token              | Light       | Dark                          | Role / Usage                                  |
| ------------------ | ----------- | ----------------------------- | --------------------------------------------- |
| `color.bg`         | `#FFFFFF`   | `#000000`                     | Root window background                        |
| `color.surface`    | `#F2F2F7`   | `#1C1C1E` `[Architect-confirm]` | Cards, sheets, raised containers              |
| `color.surface2`   | `#FFFFFF`   | `#2C2C2E` `[Architect-confirm]` | Card-on-card, elevated rows                   |
| `color.border`     | `#E5E5EA`   | `#38383A` `[Architect-confirm]` | Hairlines, dividers, 1pt strokes              |
| `color.text`       | `#000000`   | `#FFFFFF`                     | Primary text                                  |
| `color.textSecondary` | `#3C3C43` (60%) | `#EBEBF5` (60%) `[Architect-confirm]` | Subheads, metadata                            |
| `color.textTertiary`  | `#3C3C43` (30%) | `#EBEBF5` (30%) `[Architect-confirm]` | Placeholder, disabled                         |
| `color.accent`     | `#5E5CE6`   | `#7D7AFF` `[Architect-confirm]` | Indigo. Primary CTA, active toggles, links    |
| `color.success`    | `#34C759`   | `#30D158`                     | Toast success, completed badges               |
| `color.warn`       | `#FF9500`   | `#FF9F0A`                     | Caution toast, near-deadline                  |
| `color.error`      | `#FF3B30`   | `#FF453A`                     | Destructive, delete confirm                   |

### 1.2 Category Colors (HSL, S=70%)

Six snap categories. Hue fixed; saturation locked at 70% for visual consistency; lightness tuned per category for AA contrast on `color.surface`.

| Token                  | HSL              | Hex (Light) | Hex (Dark) `[Architect-confirm]` | Used For        |
| ---------------------- | ---------------- | ----------- | -------------------------------- | --------------- |
| `cat.receipt`          | `hsl(140,70,45)` | `#22B65C`   | `#3DD97A`                        | Receipt snaps   |
| `cat.place`            | `hsl(25,70,55)`  | `#E08A3E`   | `#F0A766`                        | Place snaps     |
| `cat.conversation`     | `hsl(280,70,60)` | `#A864E0`   | `#BE85ED`                        | Conversation    |
| `cat.link`             | `hsl(210,70,50)` | `#2680D9`   | `#4DA0F0`                        | Link snaps      |
| `cat.todo`             | `hsl(50,70,50)`  | `#D9B826`   | `#F0CE4D`                        | Todo snaps      |
| `cat.other`            | `hsl(0,0,55)`    | `#8C8C8C`   | `#A8A8A8`                        | Other / unknown |

Pattern: `Color(hue: H/360, saturation: 0.70, brightness: L/100)` in SwiftUI for parametric generation.

### 1.3 Korean Hyper-Local Brand Colors

Used only inside source-attribution chips and integration buttons. Never repurpose for system semantics.

| Token              | Hex       | Brand     |
| ------------------ | --------- | --------- |
| `brand.kakao`      | `#FEE500` | KakaoTalk |
| `brand.toss`       | `#0064FF` | Toss      |
| `brand.naver`      | `#03C75A` | Naver     |

---

## 2. Typography

Font: **Pretendard Variable** (primary) → **SF Pro** (fallback) → **System** (last resort).

```swift
// Fallback chain — register Pretendard via UIFont; use .system as final fallback.
extension Font {
    static func sd(_ size: CGFloat, _ weight: Font.Weight) -> Font {
        .custom("Pretendard-Variable", size: size).weight(weight)
        // SwiftUI auto-falls back to SF Pro / System if Pretendard missing.
    }
}
```

| Token        | Size | Weight     | Leading (line-height) | Tracking | Use                                |
| ------------ | ---- | ---------- | --------------------- | -------- | ---------------------------------- |
| `type.display` | 34   | Bold       | 41                    | 0.37     | Splash, onboarding hero            |
| `type.title`   | 28   | Bold       | 34                    | 0.36     | Screen titles, large numbers       |
| `type.heading` | 22   | Semibold   | 28                    | -0.26    | Section headers, sheet titles      |
| `type.body`    | 17   | Regular    | 22                    | -0.41    | Body, list rows, snap content      |
| `type.bodyEmph`| 17   | Semibold   | 22                    | -0.41    | Body emphasized, button labels     |
| `type.footnote`| 13   | Regular    | 18                    | -0.08    | Metadata, timestamps               |
| `type.caption` | 11   | Regular    | 13                    | 0.07     | Chips, badges, micro-labels        |

Dynamic Type: all tokens scale via `.scaledFont(.body)` etc. Caption/footnote scale with `.footnote` and `.caption2` text style respectively. Do **not** clamp; allow full XS–AX5 range.

---

## 3. Spacing & Radius

### 3.1 Spacing — 8pt grid

| Token        | pt | Use                                  |
| ------------ | -- | ------------------------------------ |
| `space.xs`   | 4  | Icon-text gap, chip inner padding    |
| `space.sm`   | 8  | Tight stacks, icon padding           |
| `space.md`   | 12 | Card inner row gap                   |
| `space.lg`   | 16 | Card padding, section gutter         |
| `space.xl`   | 24 | Sheet padding, large gap             |
| `space.2xl`  | 32 | Empty-state stack, hero margin       |
| `space.3xl`  | 48 | Splash centering                     |
| `space.4xl`  | 64 | Onboarding hero offset               |

### 3.2 Radius

| Token           | pt | Use                              |
| --------------- | -- | -------------------------------- |
| `radius.xs`     | 4  | Chips, tiny pills                |
| `radius.sm`     | 8  | Inputs, small buttons            |
| `radius.md`     | 12 | Toast, secondary cards           |
| `radius.lg`     | 16 | Card (default)                   |
| `radius.xl`     | 24 | Sheet top corners, modals        |

---

## 4. Motion / Easing Tokens

All defined as `Animation` extensions on `Animation`. Six tokens cover every transition.

```swift
extension Animation {
    static let snapdoSpring = Animation.spring(response: 0.40, dampingFraction: 0.75)
    static let snapdoQuick  = Animation.easeOut(duration: 0.15)
    static let snapdoFade   = Animation.easeInOut(duration: 0.25)
    static let snapdoEase   = Animation.easeOut(duration: 0.35)
    static let snapdoBounce = Animation.spring(response: 0.40, dampingFraction: 0.60)
    static let snapdoCalm   = Animation.spring(response: 0.50, dampingFraction: 0.85)
    static let snapdoReduced = Animation.linear(duration: 0.10) // reduce-motion fallback
}
```

| Token           | Type   | Params                              | When to Use                                |
| --------------- | ------ | ----------------------------------- | ------------------------------------------ |
| `snapdoSpring`  | spring | response 0.40, damp 0.75            | Large element entrance (cards, sheets)     |
| `snapdoQuick`   | easeOut| 0.15s                               | Button tap feedback, immediate state flip  |
| `snapdoFade`    | easeInOut | 0.25s                            | Text fade in/out, subtle opacity shift     |
| `snapdoEase`    | easeOut| 0.35s                               | Mid-size element move, list reorder        |
| `snapdoBounce`  | spring | response 0.40, damp 0.60            | Sun-ray (햇살), checkmark overshoot, joy   |
| `snapdoCalm`    | spring | response 0.50, damp 0.85            | Empty state appearance, gentle reveal      |

### 4.1 Reduced-Motion Rule

When `@Environment(\.accessibilityReduceMotion)` is `true`, replace all six tokens with `snapdoReduced` (`.linear(duration: 0.10)`). Springs become linear; bounces become flat fades. Implement via a single helper:

```swift
func sdAnim(_ token: Animation, reduce: Bool) -> Animation {
    reduce ? .snapdoReduced : token
}
```

### 4.2 Stagger Pattern

For list entrances (snap feed, search results): `delay = index * 0.05s`, capped at `index ≤ 5` (max 6 items staggered). Items 7+ animate in sync with item 6. Disable stagger entirely under reduced motion.

---

## 5. Haptic Mapping

Use `UIImpactFeedbackGenerator` (impact) and `UINotificationFeedbackGenerator` (notification). Prepare generators on view appear; fire on event.

| UX Moment               | Generator                    | Style / Type   | Notes                                   |
| ----------------------- | ---------------------------- | -------------- | --------------------------------------- |
| **B1** Swipe to delete  | `UIImpactFeedbackGenerator`  | `.medium`      | Fire at swipe-commit threshold          |
| **B2** Category change  | `UISelectionFeedbackGenerator` | `selectionChanged()` | Fires on each category cell hover-snap |
| **B3** Toast appears    | `UINotificationFeedbackGenerator` | `.success` / `.warning` / `.error` | Match toast variant     |
| **D1** Sheet close      | `UIImpactFeedbackGenerator`  | `.light`       | Fires at dismiss-commit                 |
| **F4** Toggle (settings)| `UIImpactFeedbackGenerator`  | `.light`       | On state flip                           |
| Snap-create success     | `UINotificationFeedbackGenerator` | `.success` | After OCR/parse pipeline returns ok     |
| Destructive confirm     | `UINotificationFeedbackGenerator` | `.warning` | On showing confirm dialog               |

Haptics are silenced when system "Reduce Motion" or "System Haptics" is off — respect both.

---

## 6. Component Shapes

### 6.1 Button

Three variants. Height 50pt (regular) / 44pt (compact). Corner `radius.md` (12).

| Variant       | Background       | Foreground       | Border         | Disabled (alpha) |
| ------------- | ---------------- | ---------------- | -------------- | ---------------- |
| `primary`     | `color.accent`   | `#FFFFFF`        | none           | 0.40             |
| `secondary`   | `color.surface`  | `color.accent`   | `color.border` | 0.40             |
| `destructive` | `color.error`    | `#FFFFFF`        | none           | 0.40             |

Padding: `space.lg` horizontal, `space.md` vertical. Press state: scale 0.97 with `snapdoQuick`. Label uses `type.bodyEmph`.

### 6.2 Card

- Corner: `radius.lg` (16)
- Padding: `space.lg` (16) all sides
- Background: `color.surface2`
- Shadow: `color: black.opacity(0.06), radius: 8, x: 0, y: 2` (light); `radius: 12, opacity: 0.30` (dark) `[Architect-confirm]`
- Border: 1pt `color.border` only when shadow disabled (e.g., reduced transparency)

### 6.3 Toast

- Corner: `radius.md` (12)
- Width: `min(screen - 32, 360)`; height: intrinsic, min 48
- Background: solid by variant (`success` / `warn` / `error` colors at 0.95 alpha)
- Text: `type.bodyEmph` white
- Progress bar: 2pt tall at bottom, `color.accent` over `white.opacity(0.30)`, animated linearly over duration (default 3s)
- Position: top, safe-area + 8pt
- Enter: `snapdoSpring`; exit: `snapdoFade`

### 6.4 Sheet

- Top corners: `radius.xl` (24); bottom: 0
- Drag indicator: 36×5pt, `color.textTertiary`, top-center, 8pt below top edge
- Background: `color.surface`
- Padding: `space.xl` (24) horizontal, `space.lg` top (after indicator)
- Detents: `.medium` and `.large` (use SwiftUI `.presentationDetents`)
- Enter/exit: `snapdoSpring` / `snapdoEase`

### 6.5 Empty State

Vertical stack, centered, `space.lg` between elements:

1. Lucide icon, **60pt**, `color.textTertiary`
2. Heading: `type.heading`, `color.text`
3. Body: `type.body`, `color.textSecondary`, max 2 lines, centered
4. Optional CTA: `primary` button, `space.xl` margin top

Enter animation: `snapdoCalm`. Stagger icon → heading → body → CTA at 50ms each.

### 6.6 Lucide Icon Sizes

| Token           | pt | Use                      |
| --------------- | -- | ------------------------ |
| `icon.xs`       | 16 | Inline with footnote     |
| `icon.sm`       | 20 | Buttons, list rows       |
| `icon.md`       | 24 | Default, nav             |
| `icon.lg`       | 32 | Section headers          |
| `icon.xl`       | 40 | Tab bar, prominent       |
| `icon.empty`    | 60 | Empty-state hero (special) |

Icon stroke width: 1.5pt (Lucide default). Tint: inherit from parent foreground.

---

## 7. Accessibility Hooks

### 7.1 Required `@Environment` Reads

Every component reads at minimum:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
@Environment(\.colorScheme)               private var colorScheme
@Environment(\.dynamicTypeSize)           private var dynamicType
@Environment(\.accessibilityReduceTransparency) private var reduceTransparency
@Environment(\.accessibilityDifferentiateWithoutColor) private var diffWithoutColor
```

### 7.2 Reduced-Motion Fallback Rules

| Default Animation | Reduced Fallback              |
| ----------------- | ----------------------------- |
| `snapdoSpring`    | `snapdoReduced` (linear 0.1s) |
| `snapdoBounce`    | `snapdoReduced`               |
| `snapdoCalm`      | `snapdoReduced`               |
| `snapdoEase`      | `snapdoReduced`               |
| `snapdoFade`      | `snapdoFade` (kept — already gentle) |
| `snapdoQuick`     | `snapdoReduced`               |
| Stagger delays    | All set to 0                  |
| Scale press FX    | Replaced with opacity 0.85    |

### 7.3 Reduced-Transparency Rule

When `reduceTransparency == true`, swap any `.ultraThinMaterial` / `.regularMaterial` background for solid `color.surface`. Toast alpha 0.95 → 1.0.

### 7.4 Differentiate Without Color

Category badges add a 1-letter glyph (R/P/C/L/T/O) when `diffWithoutColor == true`, since hue alone is not sufficient.

### 7.5 Dynamic Type

- Body content: no upper clamp.
- Buttons: allow growth; height auto-expands; min tap target 44pt always.
- Captions on chips: clamp at `.xxxLarge` to prevent layout break `[Architect-confirm]`.

### 7.6 VoiceOver

- Every interactive element: `.accessibilityLabel` + `.accessibilityHint` when action not obvious.
- Cards with category: label includes category name first ("Receipt snap, …").
- Toast: announce via `.accessibilityAnnouncement` notification.

---

## 8. Token Naming Convention (for SwiftUI extension)

Recommended Swift surface so call sites read naturally:

```swift
Color.sd.accent           // semantic
Color.sd.cat.receipt      // category
Font.sd.body              // typography
CGFloat.sd.space.lg       // spacing
CGFloat.sd.radius.lg      // radius
Animation.snapdoSpring    // motion (flat namespace per source spec)
```

Coder may collapse `CGFloat.sd.space.lg` → `Spacing.lg` if preferred — not load-bearing.

---

## 9. Open Items for Architect Confirm

1. Dark-mode `surface` / `surface2` / `border` exact hex (provisional iOS HIG values used).
2. Dark-mode accent `#7D7AFF` — needs confirm against on-brand indigo perception.
3. Category dark-mode hex — derived by +10–12 L on HSL; please verify on real OLED device.
4. Card shadow params in dark mode (current `0.30` opacity at radius 12 is conservative).
5. Caption Dynamic Type clamp at `.xxxLarge` — confirm vs. full AX5 range.
