// SnapDo iOS app entry point.
// Phase A1 stub — real root view comes in Phase E2 per wireframes B/C/F.
import SwiftUI
import SnapDoCore

@main
struct SnapDoApp: App {
    var body: some Scene {
        WindowGroup {
            BootstrapView()
        }
    }
}

private struct BootstrapView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("스냅두")
                .font(.largeTitle.bold())
            Text("SnapDoCore v\(SnapDoCore.version)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("스크린샷이 다음 단계로, 1탭으로.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
    }
}
