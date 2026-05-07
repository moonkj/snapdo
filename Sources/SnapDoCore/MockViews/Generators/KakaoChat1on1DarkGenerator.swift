// KakaoChat1on1DarkGenerator — KakaoTalk 1:1 chat (dark mode) mock view.
// Source: classification spec §3.2 (KakaoTalk 1:1, dark mode).
// Mirror of KakaoChat1on1LightGenerator with dark palette swap.
import SwiftUI

public struct KakaoChat1on1DarkGenerator: MockGenerator {
    public let code: CategoryCode = .convKakao1on1Dark

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(KakaoChat1on1DarkView(seed: seed))
    }
}

// MARK: - View

struct KakaoChat1on1DarkView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let counterparty = rng.pick(KakaoChatPool.names)
        let messageCount = rng.int(in: 3...8)

        var minute = rng.int(in: 8 * 60 ... 22 * 60)
        let mineProbability = rng.double(in: 0.4...0.6)

        var messages: [KakaoDarkMessageData] = []
        for _ in 0..<messageCount {
            let isMine = rng.bool(mineProbability)
            let text = rng.pick(KakaoChatPool.messageTemplates)
            let hasReadIndicator = rng.bool(0.10)
            let h = (minute / 60) % 24
            let m = minute % 60
            let ampm = h < 12 ? "오전" : "오후"
            let h12 = h % 12 == 0 ? 12 : h % 12
            let stamp = "\(ampm) \(h12):\(String(format: "%02d", m))"
            messages.append(KakaoDarkMessageData(
                isMine: isMine,
                text: text,
                timestamp: stamp,
                hasReadIndicator: hasReadIndicator
            ))
            minute += rng.int(in: 1...180)
        }

        let timeStr = rng.pick(KakaoChatPool.statusTimes)

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            navBar(name: counterparty)
            messageArea(messages: messages)
            inputBar
        }
        .frame(width: 390, height: 844)
        .background(KakaoDarkColors.barBg)
    }

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi")
                    .font(.system(size: 14))
                Image(systemName: "battery.100")
                    .font(.system(size: 18))
            }
            .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(KakaoDarkColors.barBg)
    }

    private func navBar(name: String) -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Text(name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(KakaoDarkColors.barBg)
    }

    private func messageArea(messages: [KakaoDarkMessageData]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                DarkMessageRow(data: msg)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(KakaoDarkColors.chatBg)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.7))
            RoundedRectangle(cornerRadius: 18)
                .fill(KakaoDarkColors.inputField)
                .frame(height: 36)
            HStack(spacing: 14) {
                Image(systemName: "face.smiling")
                Image(systemName: "mic.fill")
            }
            .font(.system(size: 18))
            .foregroundStyle(Color.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .frame(height: 64)
        .background(KakaoDarkColors.barBg)
    }
}

private struct KakaoDarkMessageData {
    let isMine: Bool
    let text: String
    let timestamp: String
    let hasReadIndicator: Bool
}

private struct DarkMessageRow: View {
    let data: KakaoDarkMessageData

    var body: some View {
        if data.isMine {
            HStack(alignment: .bottom, spacing: 8) {
                Spacer(minLength: 40)
                if data.hasReadIndicator {
                    Text("1")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.red)
                }
                Text(data.timestamp)
                    .font(.system(size: 11))
                    .foregroundStyle(KakaoDarkColors.timestamp)
                DarkMyBubble(text: data.text)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(KakaoDarkColors.avatar)
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 8) {
                        DarkOtherBubble(text: data.text)
                        Text(data.timestamp)
                            .font(.system(size: 11))
                            .foregroundStyle(KakaoDarkColors.timestamp)
                        if data.hasReadIndicator {
                            Text("1")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.red)
                        }
                    }
                }
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct DarkOtherBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 4,
                    bottomLeading: 16,
                    bottomTrailing: 16,
                    topTrailing: 16
                ))
                .fill(KakaoDarkColors.otherBubble)
            )
            .frame(maxWidth: 240, alignment: .leading)
    }
}

private struct DarkMyBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 16,
                    bottomLeading: 16,
                    bottomTrailing: 16,
                    topTrailing: 4
                ))
                .fill(KakaoDarkColors.brandYellow)
            )
            .frame(maxWidth: 240, alignment: .trailing)
    }
}

private enum KakaoDarkColors {
    static let brandYellow  = Color(red: 254.0/255.0, green: 229.0/255.0, blue: 0.0/255.0) // #FEE500
    static let barBg        = Color(red: 26.0/255.0,  green: 26.0/255.0,  blue: 26.0/255.0) // #1A1A1A
    static let chatBg       = Color(red: 45.0/255.0,  green: 45.0/255.0,  blue: 50.0/255.0) // #2D2D32
    static let otherBubble  = Color(red: 58.0/255.0,  green: 58.0/255.0,  blue: 64.0/255.0) // #3A3A40
    static let inputField   = Color(red: 58.0/255.0,  green: 58.0/255.0,  blue: 64.0/255.0)
    static let timestamp    = Color(red: 160.0/255.0, green: 165.0/255.0, blue: 170.0/255.0)
    static let avatar       = Color(red: 90.0/255.0,  green: 95.0/255.0,  blue: 100.0/255.0)
}
