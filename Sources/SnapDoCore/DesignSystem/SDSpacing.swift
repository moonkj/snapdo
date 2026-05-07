// Spacing & Radius tokens. Source: docs/design-tokens-spec.md §3.
// 8pt grid (xs..4xl) and 5 corner radii (xs..xl).
import CoreGraphics
import Foundation

public enum Spacing {
    public static let xs: CGFloat   =  4
    public static let sm: CGFloat   =  8
    public static let md: CGFloat   = 12
    public static let lg: CGFloat   = 16
    public static let xl: CGFloat   = 24
    public static let xxl: CGFloat  = 32
    public static let xxxl: CGFloat = 48
    public static let huge: CGFloat = 64
}

public enum Radius {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
}

/// Lucide icon size scale. Source: tokens-spec §6.6.
public enum IconSize {
    public static let xs: CGFloat    = 16
    public static let sm: CGFloat    = 20
    public static let md: CGFloat    = 24
    public static let lg: CGFloat    = 32
    public static let xl: CGFloat    = 40
    public static let empty: CGFloat = 60
}
