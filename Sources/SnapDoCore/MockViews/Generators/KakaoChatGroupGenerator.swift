// KakaoChatGroupGenerator — KakaoTalk 단톡방 (group chat) light + dark mocks.
// Source: classification spec §3.3 (KakaoTalk group, both modes).
// NavBar shows "{이름} 외 {N}명". Each other-bubble has a coloured sender caption.
import SwiftUI

public struct KakaoChatGroupLightGenerator: MockGenerator {
    public let code: CategoryCode = .convKakaoGroupLight
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(KakaoGroupView(seed: seed, dark: false, isOpenChat: false))
    }
}

public struct KakaoChatGroupDarkGenerator: MockGenerator {
    public let code: CategoryCode = .convKakaoGroupDark
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(KakaoGroupView(seed: seed, dark: true, isOpenChat: false))
    }
}

// MARK: - Shared View (used by group + open-chat)

struct KakaoGroupView: View {
    let seed: UInt64
    let dark: Bool
    let isOpenChat: Bool

    private static let senderColors: [Color] = [
        Color(red: 0x5E/255.0, green: 0x5C/255.0, blue: 0xE6/255.0),
        Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0),
        Color(red: 0xFF/255.0, green: 0x95/255.0, blue: 0x00/255.0),
        Color(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0),
        Color(red: 0xA8/255.0, green: 0x64/255.0, blue: 0xE0/255.0)
    ]

    private static let openNicknames: [String] = [
        "익명1", "코딩하는딸기", "주말여행", "치킨러버", "조용한고양이",
        "북클럽지기", "5월의햇살", "맛집탐험가", "산책하는개", "음악듣는늑대"
    ]

    private static let openTopics: [String] = [
        "강남 맛집", "주말 등산 모임", "코딩 스터디", "독서 모임",
        "5월 캠핑", "재테크 정보방", "강아지 산책 친구", "보드게임 모임",
        "카페 투어", "영화 추천방"
    ]

    var body: some View {
        var rng = SeededRNG(seed: seed)

        // Sender pool: 3-5 distinct names (excluding "나").
        let senderCount = rng.int(in: 3...5)
        let pool = isOpenChat ? Self.openNicknames : KakaoChatPool.names
        var sendersSet: [String] = []
        var attempts = 0
        while sendersSet.count < senderCount && attempts < 40 {
            let candidate = rng.pick(pool)
            if !sendersSet.contains(candidate) { sendersSet.append(candidate) }
            attempts += 1
        }
        let senders = sendersSet
        // Stable sender → colour mapping.
        var senderColorMap: [String: Color] = [:]
        for (i, name) in senders.enumerated() {
            senderColorMap[name] = Self.senderColors[i % Self.senderColors.count]
        }

        let totalMembers = rng.int(in: 2...6) // "외 N명"
        let firstName = senders.first ?? (isOpenChat ? "익명1" : "지영")
        let topic = rng.pick(Self.openTopics)
        let title: String = isOpenChat
            ? "#오픈채팅: \(topic) 🔒"
            : "\(firstName) 외 \(totalMembers)명"

        let messageCount = rng.int(in: 3...8)
        var minute = rng.int(in: 8 * 60 ... 22 * 60)
        let mineProbability = rng.double(in: 0.4...0.6)

        var messages: [KakaoGroupMessageData] = []
        for _ in 0..<messageCount {
            let isMine = rng.bool(mineProbability)
            let sender = rng.pick(senders)
            let text = rng.pick(KakaoChatPool.messageTemplates)
            let hasReadIndicator = rng.bool(0.10)
            let h = (minute / 60) % 24
            let m = minute % 60
            let ampm = h < 12 ? "오전" : "오후"
            let h12 = h % 12 == 0 ? 12 : h % 12
            let stamp = "\(ampm) \(h12):\(String(format: "%02d", m))"
            messages.append(KakaoGroupMessageData(
                isMine: isMine,
                sender: sender,
                senderColor: senderColorMap[sender] ?? .black,
                text: text,
                timestamp: stamp,
                hasReadIndicator: hasReadIndicator
            ))
            minute += rng.int(in: 1...180)
        }

        let timeStr = rng.pick(KakaoChatPool.statusTimes)

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            navBar(title: title)
            messageArea(messages: messages)
            inputBar
        }
        .frame(width: 390, height: 844)
        .background(barBg)
    }

    // MARK: palette

    private var barBg: Color {
        dark
            ? Color(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0) // #1A1A1A
            : Color(red: 254.0/255.0, green: 229.0/255.0, blue: 0.0/255.0) // #FEE500
    }
    private var barFg: Color { dark ? .white : .black }
    private var chatBg: Color {
        dark
            ? Color(red: 45.0/255.0, green: 45.0/255.0, blue: 50.0/255.0)
            : Color(red: 178.0/255.0, green: 199.0/255.0, blue: 218.0/255.0)
    }
    private var otherBubbleBg: Color {
        dark
            ? Color(red: 58.0/255.0, green: 58.0/255.0, blue: 64.0/255.0)
            : .white
    }
    private var otherBubbleFg: Color { dark ? .white : .black }
    private var inputBg: Color {
        dark
            ? Color(red: 45.0/255.0, green: 45.0/255.0, blue: 50.0/255.0)
            : .white
    }
    private var inputField: Color {
        dark
            ? Color(red: 58.0/255.0, green: 58.0/255.0, blue: 64.0/255.0)
            : Color(red: 242.0/255.0, green: 244.0/255.0, blue: 246.0/255.0)
    }
    private var timestampFg: Color {
        dark
            ? Color(red: 160.0/255.0, green: 165.0/255.0, blue: 170.0/255.0)
            : Color(red: 139.0/255.0, green: 149.0/255.0, blue: 161.0/255.0)
    }
    private var avatarFill: Color {
        dark
            ? Color(red: 90.0/255.0, green: 95.0/255.0, blue: 100.0/255.0)
            : Color(red: 200.0/255.0, green: 205.0/255.0, blue: 212.0/255.0)
    }
    private var brandYellow: Color {
        Color(red: 254.0/255.0, green: 229.0/255.0, blue: 0.0/255.0)
    }

    // MARK: bars

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(barFg)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
            .foregroundStyle(barFg)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(barBg)
    }

    private func navBar(title: String) -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(barFg)
            Spacer()
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(barFg)
                .lineLimit(1)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(barFg)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(barBg)
    }

    private func messageArea(messages: [KakaoGroupMessageData]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                GroupMessageRow(
                    data: msg,
                    otherBubbleBg: otherBubbleBg,
                    otherBubbleFg: otherBubbleFg,
                    timestampFg: timestampFg,
                    avatarFill: avatarFill,
                    brandYellow: brandYellow
                )
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(chatBg)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 20))
                .foregroundStyle(barFg.opacity(0.6))
            RoundedRectangle(cornerRadius: 18)
                .fill(inputField)
                .frame(height: 36)
            HStack(spacing: 14) {
                Image(systemName: "face.smiling")
                Image(systemName: "mic.fill")
            }
            .font(.system(size: 18))
            .foregroundStyle(barFg.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .frame(height: 64)
        .background(inputBg)
    }
}

struct KakaoGroupMessageData {
    let isMine: Bool
    let sender: String
    let senderColor: Color
    let text: String
    let timestamp: String
    let hasReadIndicator: Bool
}

struct GroupMessageRow: View {
    let data: KakaoGroupMessageData
    let otherBubbleBg: Color
    let otherBubbleFg: Color
    let timestampFg: Color
    let avatarFill: Color
    let brandYellow: Color

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
                    .foregroundStyle(timestampFg)
                Text(data.text)
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
                        .fill(brandYellow)
                    )
                    .frame(maxWidth: 240, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(avatarFill)
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(data.sender)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(data.senderColor)
                    HStack(alignment: .bottom, spacing: 8) {
                        Text(data.text)
                            .font(.system(size: 16))
                            .foregroundStyle(otherBubbleFg)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                UnevenRoundedRectangle(cornerRadii: .init(
                                    topLeading: 4,
                                    bottomLeading: 16,
                                    bottomTrailing: 16,
                                    topTrailing: 16
                                ))
                                .fill(otherBubbleBg)
                            )
                            .frame(maxWidth: 240, alignment: .leading)
                        Text(data.timestamp)
                            .font(.system(size: 11))
                            .foregroundStyle(timestampFg)
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
