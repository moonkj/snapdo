// Color tokens. Source: docs/design-tokens-spec.md §1.
// All semantic + category + brand colors live here. Do not hard-code hex elsewhere.
import SwiftUI

public extension Color {
    /// Namespace: `Color.sd.*`
    static let sd = SDColor()
}

public struct SDColor {
    // MARK: System / Semantic — values resolve per ColorScheme.
    public let bg            = dynamic(light: 0xFFFFFF, dark: 0x000000)
    public let surface       = dynamic(light: 0xF2F2F7, dark: 0x1C1C1E)
    public let surface2      = dynamic(light: 0xFFFFFF, dark: 0x2C2C2E)
    public let border        = dynamic(light: 0xE5E5EA, dark: 0x38383A)
    public let text          = dynamic(light: 0x000000, dark: 0xFFFFFF)
    public let textSecondary = dynamic(light: 0x3C3C43, dark: 0xEBEBF5, lightAlpha: 0.60, darkAlpha: 0.60)
    public let textTertiary  = dynamic(light: 0x3C3C43, dark: 0xEBEBF5, lightAlpha: 0.30, darkAlpha: 0.30)
    public let accent        = dynamic(light: 0x5E5CE6, dark: 0x7D7AFF)
    public let success       = dynamic(light: 0x34C759, dark: 0x30D158)
    public let warn          = dynamic(light: 0xFF9500, dark: 0xFF9F0A)
    public let error         = dynamic(light: 0xFF3B30, dark: 0xFF453A)

    // MARK: Categories — HSL S=70%, L tuned per spec §1.2.
    public let cat = SDCategoryColor()

    // MARK: Korean brand colors — restricted to attribution chips / integration buttons.
    public let brand = SDBrandColor()
}

public struct SDCategoryColor {
    public let receipt      = Color(hue: 140/360, saturation: 0.70, brightness: 0.70) // L≈45 derived
    public let place        = Color(hue:  25/360, saturation: 0.70, brightness: 0.85) // L≈55
    public let conversation = Color(hue: 280/360, saturation: 0.70, brightness: 0.85) // L≈60
    public let link         = Color(hue: 210/360, saturation: 0.70, brightness: 0.78) // L≈50
    public let todo         = Color(hue:  50/360, saturation: 0.70, brightness: 0.78) // L≈50
    public let other        = Color(white: 0.55)                                       // S=0
}

public struct SDBrandColor {
    public let kakao = Color(hex: 0xFEE500) // KakaoTalk yellow
    public let toss  = Color(hex: 0x0064FF) // Toss blue
    public let naver = Color(hex: 0x03C75A) // Naver green
}

// MARK: - Helpers

extension Color {
    /// Initialise from a 0xRRGGBB integer.
    public init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >>  8) & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

/// Builds a resolved colour that switches by ColorScheme.
fileprivate func dynamic(
    light: UInt32,
    dark: UInt32,
    lightAlpha: Double = 1.0,
    darkAlpha: Double = 1.0
) -> Color {
    #if canImport(UIKit)
    return Color(UIColor { trait in
        let isDark = trait.userInterfaceStyle == .dark
        let hex = isDark ? dark : light
        let alpha = isDark ? darkAlpha : lightAlpha
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >>  8) & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    })
    #elseif canImport(AppKit)
    return Color(NSColor(name: nil, dynamicProvider: { appearance in
        let isDark = appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
        let hex = isDark ? dark : light
        let alpha = isDark ? darkAlpha : lightAlpha
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >>  8) & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255
        return NSColor(red: r, green: g, blue: b, alpha: alpha)
    }))
    #else
    // Fallback: light-mode constant (only hits non-Apple platforms which we don't ship to).
    let r = Double((light >> 16) & 0xFF) / 255
    let g = Double((light >>  8) & 0xFF) / 255
    let b = Double( light        & 0xFF) / 255
    return Color(.sRGB, red: r, green: g, blue: b, opacity: lightAlpha)
    #endif
}

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
