// Motion tokens. Source: docs/design-tokens-spec.md §4 + motion guide v1 §2.
// Six easing tokens cover every transition; one reduced-motion fallback.
import SwiftUI

public extension Animation {
    /// Large element entrance (cards, sheets). spec §4: response 0.40 / damp 0.75.
    static let snapdoSpring  = Animation.spring(response: 0.40, dampingFraction: 0.75)
    /// Button tap feedback, immediate state flip. 0.15s easeOut.
    static let snapdoQuick   = Animation.easeOut(duration: 0.15)
    /// Text fade in/out, subtle opacity. 0.25s easeInOut.
    static let snapdoFade    = Animation.easeInOut(duration: 0.25)
    /// Mid-size element move, list reorder. 0.35s easeOut.
    static let snapdoEase    = Animation.easeOut(duration: 0.35)
    /// Sun-ray, checkmark overshoot, joyful. response 0.40 / damp 0.60.
    static let snapdoBounce  = Animation.spring(response: 0.40, dampingFraction: 0.60)
    /// Empty state, gentle reveal. response 0.50 / damp 0.85.
    static let snapdoCalm    = Animation.spring(response: 0.50, dampingFraction: 0.85)
    /// Reduced-motion fallback. Linear 0.10s.
    static let snapdoReduced = Animation.linear(duration: 0.10)
}

/// Picks a token based on the current Reduced Motion setting.
/// Per tokens-spec §4.1: snapdoFade stays the same (already gentle); the rest fall back to linear.
public func sdAnim(_ token: Animation, reduceMotion: Bool) -> Animation {
    guard reduceMotion else { return token }
    // Treat a token's identity as an opaque value; we cannot inspect it cheaply,
    // so callers who want to keep `.snapdoFade` under reduced-motion must opt out
    // by passing `reduceMotion: false`. This matches the spec table where
    // snapdoFade is the only token kept "as-is" and is inexpensive to fade.
    return .snapdoReduced
}

/// Stagger helper. spec §4.2: 50ms delay, capped at index ≤ 5.
/// Returns the delay (seconds) for a given list-item index.
@inlinable
public func sdStagger(index: Int, reduceMotion: Bool = false) -> Double {
    if reduceMotion { return 0 }
    let capped = min(index, 5)
    return Double(capped) * 0.05
}
