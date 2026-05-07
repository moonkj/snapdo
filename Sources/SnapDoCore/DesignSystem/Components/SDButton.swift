// SDButton — primary / secondary / destructive variants.
// Source: docs/design-tokens-spec.md §6.1.
// Height 50pt regular / 44pt compact, radius.md, padding lg×md, type.bodyEmph,
// press FX scale 0.97 with snapdoQuick (or opacity 0.85 under reduced motion).
import SwiftUI

public enum SDButtonVariant {
    case primary, secondary, destructive
}

public enum SDButtonSize {
    case regular, compact

    var height: CGFloat {
        switch self {
        case .regular: return 50
        case .compact: return 44
        }
    }
}

public struct SDButton: View {
    public let title: String
    public let variant: SDButtonVariant
    public let size: SDButtonSize
    public let isEnabled: Bool
    public let action: () -> Void

    public init(
        _ title: String,
        variant: SDButtonVariant = .primary,
        size: SDButtonSize = .regular,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public var body: some View {
        Button(action: {
            SDHaptic.cardActionStart.fire()
            action()
        }) {
            Text(title)
                .font(Font.sd.bodyEmph)
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity, minHeight: size.height)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: variant == .secondary ? 1 : 0)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.40)
        .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.97 : 1.0))
        .opacity(reduceMotion && isPressed ? 0.85 : (isEnabled ? 1 : 0.40))
        .animation(reduceMotion ? .snapdoReduced : .snapdoQuick, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .accessibilityLabel(title)
    }

    // MARK: - Style resolution

    private var background: Color {
        switch variant {
        case .primary:     return Color.sd.accent
        case .secondary:   return Color.sd.surface
        case .destructive: return Color.sd.error
        }
    }

    private var foreground: Color {
        switch variant {
        case .primary, .destructive: return .white
        case .secondary:             return Color.sd.accent
        }
    }

    private var borderColor: Color {
        variant == .secondary ? Color.sd.border : .clear
    }
}
