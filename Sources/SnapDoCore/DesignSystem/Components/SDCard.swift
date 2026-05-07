// SDCard — base card container.
// Source: docs/design-tokens-spec.md §6.2.
// Radius lg (16), padding lg, surface2 background, soft shadow.
// Falls back to a 1pt border when reduce-transparency is on.
import SwiftUI

public struct SDCard<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public var body: some View {
        content
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Color.sd.surface2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .strokeBorder(Color.sd.border, lineWidth: reduceTransparency ? 1 : 0)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: 2
            )
    }

    private var shadowColor: Color {
        reduceTransparency ? .clear :
            (colorScheme == .dark ? Color.black.opacity(0.30) : Color.black.opacity(0.06))
    }

    private var shadowRadius: CGFloat {
        colorScheme == .dark ? 12 : 8
    }
}
