// Typography tokens. Source: docs/design-tokens-spec.md §2.
// Pretendard primary → SF Pro fallback → System last resort.
import SwiftUI

public extension Font {
    /// Namespace: `Font.sd.*`
    static let sd = SDFont()
}

public struct SDFont {
    public let display  = Font.sd(34, .bold)        // type.display
    public let title    = Font.sd(28, .bold)        // type.title
    public let heading  = Font.sd(22, .semibold)    // type.heading
    public let body     = Font.sd(17, .regular)     // type.body
    public let bodyEmph = Font.sd(17, .semibold)    // type.bodyEmph
    public let footnote = Font.sd(13, .regular)     // type.footnote
    public let caption  = Font.sd(11, .regular)     // type.caption
}

public extension Font {
    /// Pretendard with weight, falling back to system if the font is not registered.
    /// SwiftUI does not silently fall back, so we resolve via UIFont and check.
    static func sd(_ size: CGFloat, _ weight: Font.Weight) -> Font {
        #if canImport(UIKit)
        let postScriptName = pretendardPostScriptName(for: weight)
        if UIFont(name: postScriptName, size: size) != nil {
            return .custom(postScriptName, size: size).weight(weight)
        }
        #elseif canImport(AppKit)
        let postScriptName = pretendardPostScriptName(for: weight)
        if NSFont(name: postScriptName, size: size) != nil {
            return .custom(postScriptName, size: size).weight(weight)
        }
        #endif
        // System fallback (uses SF Pro on Apple platforms).
        return .system(size: size, weight: weight)
    }
}

private func pretendardPostScriptName(for weight: Font.Weight) -> String {
    switch weight {
    case .ultraLight, .thin:   return "Pretendard-Thin"
    case .light:               return "Pretendard-Light"
    case .regular:             return "Pretendard-Regular"
    case .medium:              return "Pretendard-Medium"
    case .semibold:            return "Pretendard-SemiBold"
    case .bold:                return "Pretendard-Bold"
    case .heavy:               return "Pretendard-ExtraBold"
    case .black:               return "Pretendard-Black"
    default:                   return "Pretendard-Regular"
    }
}

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
