// SDToast — top toast with linear progress.
// Source: docs/design-tokens-spec.md §6.3.
// Variant: success / warning / error · width min(screen-32, 360) · radius.md
// Enter snapdoSpring · exit snapdoFade · default 3s.
import SwiftUI

public enum SDToastVariant {
    case success, warning, error

    var background: Color {
        switch self {
        case .success: return Color.sd.success
        case .warning: return Color.sd.warn
        case .error:   return Color.sd.error
        }
    }

    var haptic: SDHaptic {
        switch self {
        case .success: return .toastSuccess
        case .warning: return .toastWarning
        case .error:   return .toastError
        }
    }
}

public struct SDToast: View {
    public let message: String
    public let variant: SDToastVariant
    public let duration: TimeInterval
    public let onDismiss: () -> Void

    public init(
        message: String,
        variant: SDToastVariant = .success,
        duration: TimeInterval = 3.0,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.message = message
        self.variant = variant
        self.duration = duration
        self.onDismiss = onDismiss
    }

    @State private var progress: CGFloat = 1.0
    @State private var visible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.md) {
                Text(message)
                    .font(Font.sd.bodyEmph)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)

            // Progress bar (2pt) — linear over duration.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.30))
                        .frame(height: 2)
                    Rectangle()
                        .fill(Color.sd.accent)
                        .frame(width: geo.size.width * progress, height: 2)
                }
            }
            .frame(height: 2)
        }
        .frame(minHeight: 48)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(variant.background.opacity(reduceTransparency ? 1.0 : 0.95))
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .padding(.horizontal, Spacing.lg)
        .opacity(visible ? 1 : 0)
        .offset(y: visible ? 0 : -16)
        .onAppear {
            variant.haptic.fire()
            withAnimation(reduceMotion ? .snapdoReduced : .snapdoSpring) { visible = true }
            withAnimation(.linear(duration: duration)) { progress = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(reduceMotion ? .snapdoReduced : .snapdoFade) { visible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.30, execute: onDismiss)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}
