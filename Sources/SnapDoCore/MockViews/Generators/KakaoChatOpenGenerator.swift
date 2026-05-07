// KakaoChatOpenGenerator — KakaoTalk 오픈채팅 (open chat) mock view.
// Source: classification spec §3.4 (KakaoTalk open chat).
// Reuses the group view with isOpenChat = true (light palette).
import SwiftUI

public struct KakaoChatOpenGenerator: MockGenerator {
    public let code: CategoryCode = .convKakaoOpen

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        // Open chat is visually most often light; keep dark off for this code.
        AnyView(KakaoGroupView(seed: seed, dark: false, isOpenChat: true))
    }
}
