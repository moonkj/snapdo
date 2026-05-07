// RuleEngine — fast rule-based detector. Spec §2.
// 50ms target, 95% confidence on hit, 40-60% expected hit rate per spec §2.6.
//
// Phase E1 implements:
//   - KakaoTalk NavBar yellow detection (§2.1) using histogram in top 0-120pt
//   - Card-alert keyword scan (§2.3) cooperating with OCRReader
//   - Toss blue + 원 unit (§2.2)
//   - Safari URL bar (§2.4)
//   - KakaoMap / NaverMap visual signals (§2.5)
//
// This file declares the abstract surface; the implementation lands in Phase E.
import Foundation
import CoreGraphics

public protocol RuleEngine: Sendable {
    /// Returns `nil` when no rule matched. Should run in <50ms per spec §2.
    func evaluate(_ image: CGImage, ocrText: String?) async -> RuleHit?
}

/// No-op engine for unit testing & for stages where the real engine isn't available yet.
public struct NoRuleEngine: RuleEngine {
    public init() {}
    public func evaluate(_ image: CGImage, ocrText: String?) async -> RuleHit? { nil }
}

// MARK: - Color matching helpers (§2.1, §2.2)

public struct ColorTolerance: Sendable {
    public let dR: Int
    public let dG: Int
    public let dB: Int
    public init(dR: Int, dG: Int, dB: Int) { self.dR = dR; self.dG = dG; self.dB = dB }

    /// Spec §2.1 KakaoTalk yellow #FEE500 tolerance ±(15,15,25).
    public static let kakaoYellow = ColorTolerance(dR: 15, dG: 15, dB: 25)
    /// Spec §2.2 Toss blue #0064FF tolerance ±(20,20,20).
    public static let tossBlue    = ColorTolerance(dR: 20, dG: 20, dB: 20)
}

public struct TargetColor: Sendable {
    public let r: Int
    public let g: Int
    public let b: Int
    public let tolerance: ColorTolerance

    public init(r: Int, g: Int, b: Int, tolerance: ColorTolerance) {
        self.r = r; self.g = g; self.b = b; self.tolerance = tolerance
    }

    public func matches(r r2: Int, g g2: Int, b b2: Int) -> Bool {
        abs(r - r2) <= tolerance.dR &&
        abs(g - g2) <= tolerance.dG &&
        abs(b - b2) <= tolerance.dB
    }

    public static let kakaoYellow = TargetColor(r: 0xFE, g: 0xE5, b: 0x00, tolerance: .kakaoYellow)
    public static let tossBlue    = TargetColor(r: 0x00, g: 0x64, b: 0xFF, tolerance: .tossBlue)
    public static let naverGreen  = TargetColor(r: 0x03, g: 0xC7, b: 0x5A, tolerance: .tossBlue)
}
