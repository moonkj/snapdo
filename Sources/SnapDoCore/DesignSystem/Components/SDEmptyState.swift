// SDEmptyState — icon + heading + body + optional CTA.
// Source: docs/design-tokens-spec.md §6.5.
// Stagger icon → heading → body → CTA at 50ms each. Enter snapdoCalm.
import SwiftUI

public struct SDEmptyState: View {
    public let systemIcon: String      // SF Symbol name (Lucide icons can swap in later via Resources)
    public let heading: String
    public let bodyText: String
    public let cta: (title: String, action: () -> Void)?

    public init(
        systemIcon: String,
        heading: String,
        body: String,
        cta: (title: String, action: () -> Void)? = nil
    ) {
        self.systemIcon = systemIcon
        self.heading = heading
        self.bodyText = body
        self.cta = cta
    }

    @State private var visible = [false, false, false, false]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: systemIcon)
                .resizable()
                .scaledToFit()
                .frame(width: IconSize.empty, height: IconSize.empty)
                .foregroundStyle(Color.sd.textTertiary)
                .opacity(visible[0] ? 1 : 0)
                .offset(y: visible[0] ? 0 : 8)

            Text(heading)
                .font(Font.sd.heading)
                .foregroundStyle(Color.sd.text)
                .opacity(visible[1] ? 1 : 0)
                .offset(y: visible[1] ? 0 : 8)

            Text(bodyText)
                .font(Font.sd.body)
                .foregroundStyle(Color.sd.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .opacity(visible[2] ? 1 : 0)
                .offset(y: visible[2] ? 0 : 8)

            if let cta {
                SDButton(cta.title, variant: .primary) {
                    cta.action()
                }
                .padding(.top, Spacing.xl)
                .opacity(visible[3] ? 1 : 0)
                .offset(y: visible[3] ? 0 : 8)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { runStagger() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(heading). \(bodyText)")
    }

    private func runStagger() {
        let count = cta == nil ? 3 : 4
        for i in 0..<count {
            let delay = sdStagger(index: i, reduceMotion: reduceMotion)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(reduceMotion ? .snapdoReduced : .snapdoCalm) {
                    visible[i] = true
                }
            }
        }
    }
}
