// IMessageGenerator — Apple Messages (iMessage) light + dark mocks.
// Source: classification spec §3.5 (iMessage light/dark).
// White/black bg, blue #0B93F6 my-bubble, grey other-bubble, FaceTime/info icons.
import SwiftUI

public struct IMessageLightGenerator: MockGenerator {
    public let code: CategoryCode = .convImessageLight
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(IMessageView(seed: seed, dark: false))
    }
}

public struct IMessageDarkGenerator: MockGenerator {
    public let code: CategoryCode = .convImessageDark
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(IMessageView(seed: seed, dark: true))
    }
}

// MARK: - View

struct IMessageView: View {
    let seed: UInt64
    let dark: Bool

    private static let phoneNumbers: [String] = [
        "010-1234-5678", "010-2345-6789", "010-9876-5432",
        "+1 (415) 555-0142", "010-5555-1234", "010-7777-8888"
    ]

    private static let englishContacts: [String] = [
        "Alex", "Sam", "Mom", "Dad", "Jamie", "Taylor", "Jordan", "Morgan"
    ]

    var body: some View {
        var rng = SeededRNG(seed: seed)
        // Mix Korean given names + English short names + occasional phone number.
        let usePhone = rng.bool(0.15)
        let useEnglish = rng.bool(0.35)
        let contact: String
        if usePhone {
            contact = rng.pick(Self.phoneNumbers)
        } else if useEnglish {
            contact = rng.pick(Self.englishContacts)
        } else {
            contact = rng.pick(KoreanNames.givenNames)
        }

        let messageCount = rng.int(in: 3...8)
        var minute = rng.int(in: 8 * 60 ... 22 * 60)
        let mineProbability = rng.double(in: 0.4...0.6)

        var messages: [IMessageData] = []
        for _ in 0..<messageCount {
            let isMine = rng.bool(mineProbability)
            let text = rng.pick(KoreanMessages.templates)
            let h = (minute / 60) % 24
            let m = minute % 60
            let ampm = h < 12 ? "오전" : "오후"
            let h12 = h % 12 == 0 ? 12 : h % 12
            let stamp = "\(ampm) \(h12):\(String(format: "%02d", m))"
            messages.append(IMessageData(isMine: isMine, text: text, timestamp: stamp))
            minute += rng.int(in: 1...180)
        }

        let timeStr = rng.pick(KakaoChatPool.statusTimes)

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            navBar(name: contact)
            messageArea(messages: messages)
            inputBar
        }
        .frame(width: 390, height: 844)
        .background(bg)
    }

    // MARK: palette

    private var bg: Color { dark ? .black : .white }
    private var fg: Color { dark ? .white : .black }
    private var navBg: Color {
        dark ? Color(red: 28.0/255.0, green: 28.0/255.0, blue: 30.0/255.0) : .white
    }
    private var navBorder: Color {
        dark
            ? Color(red: 60.0/255.0, green: 60.0/255.0, blue: 64.0/255.0)
            : Color(red: 200.0/255.0, green: 200.0/255.0, blue: 205.0/255.0)
    }
    private var otherBubbleBg: Color {
        dark
            ? Color(red: 44.0/255.0, green: 44.0/255.0, blue: 46.0/255.0) // #2C2C2E
            : Color(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0) // #E5E5EA
    }
    private var iMessageBlue: Color {
        Color(red: 0x0B/255.0, green: 0x93/255.0, blue: 0xF6/255.0)
    }
    private var inputField: Color {
        dark
            ? Color(red: 44.0/255.0, green: 44.0/255.0, blue: 46.0/255.0)
            : Color(red: 240.0/255.0, green: 240.0/255.0, blue: 245.0/255.0)
    }

    // MARK: bars

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(fg)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
            .foregroundStyle(fg)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(bg)
    }

    private func navBar(name: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(iMessageBlue)
                Spacer()
                VStack(spacing: 2) {
                    Circle()
                        .fill(otherBubbleBg)
                        .frame(width: 28, height: 28)
                    Text(name)
                        .font(.system(size: 11))
                        .foregroundStyle(fg)
                        .lineLimit(1)
                }
                Spacer()
                HStack(spacing: 14) {
                    Image(systemName: "video.fill")
                    Image(systemName: "info.circle")
                }
                .font(.system(size: 18))
                .foregroundStyle(iMessageBlue)
            }
            .padding(.horizontal, 16)
            .frame(height: 70)
            .background(navBg)
            Rectangle()
                .fill(navBorder)
                .frame(height: 0.5)
        }
    }

    private func messageArea(messages: [IMessageData]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(messages.enumerated()), id: \.offset) { idx, msg in
                let showStamp = idx == 0 || idx == messages.count - 1 || idx % 3 == 0
                if showStamp {
                    Text(msg.timestamp)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(fg.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 6)
                }
                IMessageRow(
                    data: msg,
                    otherBubbleBg: otherBubbleBg,
                    otherBubbleFg: fg,
                    blue: iMessageBlue
                )
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(bg)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(fg.opacity(0.4))
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(navBorder, lineWidth: 0.5)
                    .background(
                        RoundedRectangle(cornerRadius: 18).fill(inputField)
                    )
                    .frame(height: 36)
                Image(systemName: "mic.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(fg.opacity(0.5))
                    .padding(.trailing, 10)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 64)
        .background(bg)
    }
}

private struct IMessageData {
    let isMine: Bool
    let text: String
    let timestamp: String
}

private struct IMessageRow: View {
    let data: IMessageData
    let otherBubbleBg: Color
    let otherBubbleFg: Color
    let blue: Color

    var body: some View {
        if data.isMine {
            HStack {
                Spacer(minLength: 50)
                Text(data.text)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: 20,
                            bottomLeading: 20,
                            bottomTrailing: 4,
                            topTrailing: 20
                        ))
                        .fill(blue)
                    )
                    .frame(maxWidth: 260, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            HStack {
                Text(data.text)
                    .font(.system(size: 16))
                    .foregroundStyle(otherBubbleFg)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: 4,
                            bottomLeading: 20,
                            bottomTrailing: 20,
                            topTrailing: 20
                        ))
                        .fill(otherBubbleBg)
                    )
                    .frame(maxWidth: 260, alignment: .leading)
                Spacer(minLength: 50)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
