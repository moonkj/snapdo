// SDSheet — modifier for presenting a bottom sheet with our design tokens.
// Source: docs/design-tokens-spec.md §6.4.
// Top corners 24, drag indicator 36×5, surface bg, padding xl horizontal.
// Enter snapdoSpring · exit snapdoEase. Detents medium + large.
//
// iOS-only: macOS uses different sheet semantics and SnapDoTrainer (the only
// macOS consumer of SnapDoCore) does not present UI sheets.
//
// Usage:
//   .sdSheet(isPresented: $show) { Text("Hello") }
import SwiftUI

#if os(iOS)
import UIKit

public extension View {
    func sdSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            SDSheetContainer(content: content)
        }
    }
}

public struct SDSheetContainer<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Drag indicator pill (system one hidden via .presentationDragIndicator below
            // because we want our own colour token).
            RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                .fill(Color.sd.textTertiary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, Spacing.lg)

            content
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.sd.surface)
        .clipShape(SDSheetShape(radius: Radius.xl))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(Radius.xl)
    }
}

/// Top-rounded shape used to clip the sheet content.
private struct SDSheetShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
#endif
