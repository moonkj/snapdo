// KakaoChat1on1LightGenerator — KakaoTalk 1:1 chat (light mode) mock view.
// Source: classification spec §3.1 (KakaoTalk 1:1, light mode).
//
// Layout (top → bottom, 390 × 844 logical pts):
//   1. Status bar (47 pt)  — yellow #FEE500 bg, black time / signal-battery
//   2. NavBar (56 pt)      — yellow #FEE500 bg, "<" + name + hamburger
//   3. Message area        — light blue-grey #B2C7DA bg, bubbles
//   4. Input bar (64 pt)   — white bg, "+", grey rounded field, mic / emoji
//
// Randomisation per render:
//   - 3-8 messages, other/mine ratio random in 40-60%
//   - Message length 1-80 chars (template pool)
//   - Timestamps chronological top→bottom, 1 min – 3 hours apart
//   - 10% chance per message of a "1" red read indicator
//   - Counterparty name from the 15-name pool
import SwiftUI

public struct KakaoChat1on1LightGenerator: MockGenerator {
    public let code: CategoryCode = .convKakao1on1Light

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(KakaoChat1on1LightView(seed: seed))
    }
}

// MARK: - View

struct KakaoChat1on1LightView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let counterparty = rng.pick(KakaoChatPool.names)
        let messageCount = rng.int(in: 3...8)

        // First message: random start time during the day (so the displayed
        // chronological ordering is reasonable). Stored as minute-of-day.
        var minute = rng.int(in: 8 * 60 ... 22 * 60)
        let mineProbability = rng.double(in: 0.4...0.6)

        var messages: [KakaoMessageData] = []
        for _ in 0..<messageCount {
            let isMine = rng.bool(mineProbability)
            let text = rng.pick(KakaoChatPool.messageTemplates)
            let hasReadIndicator = rng.bool(0.10)
            let h = (minute / 60) % 24
            let m = minute % 60
            let ampm = h < 12 ? "오전" : "오후"
            let h12 = h % 12 == 0 ? 12 : h % 12
            let stamp = "\(ampm) \(h12):\(String(format: "%02d", m))"
            messages.append(KakaoMessageData(
                isMine: isMine,
                text: text,
                timestamp: stamp,
                hasReadIndicator: hasReadIndicator
            ))
            // 1 min – 3 hours gap.
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
        .background(Color.white)
    }

    // MARK: status bar

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi")
                    .font(.system(size: 14))
                Image(systemName: "battery.100")
                    .font(.system(size: 18))
            }
            .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(KakaoColors.brandYellow)
    }

    // MARK: nav bar (47 → 103, height 56)

    private func navBar(name: String) -> some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer()
            Text(name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(KakaoColors.brandYellow)
    }

    // MARK: messages

    private func messageArea(messages: [KakaoMessageData]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                MessageRow(data: msg)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(KakaoColors.chatBg)
    }

    // MARK: input bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.6))
            RoundedRectangle(cornerRadius: 18)
                .fill(KakaoColors.inputField)
                .frame(height: 36)
            HStack(spacing: 14) {
                Image(systemName: "face.smiling")
                Image(systemName: "mic.fill")
            }
            .font(.system(size: 18))
            .foregroundStyle(Color.black.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .frame(height: 64)
        .background(Color.white)
    }
}

// MARK: - Message row

private struct KakaoMessageData {
    let isMine: Bool
    let text: String
    let timestamp: String
    let hasReadIndicator: Bool
}

private struct MessageRow: View {
    let data: KakaoMessageData

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
                    .foregroundStyle(KakaoColors.timestamp)
                MyBubble(text: data.text)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(KakaoColors.avatar)
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom, spacing: 8) {
                        OtherBubble(text: data.text)
                        Text(data.timestamp)
                            .font(.system(size: 11))
                            .foregroundStyle(KakaoColors.timestamp)
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

private struct OtherBubble: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 4,
                    bottomLeading: 16,
                    bottomTrailing: 16,
                    topTrailing: 16
                ))
                .fill(Color.white)
            )
            .frame(maxWidth: 240, alignment: .leading)
    }
}

private struct MyBubble: View {
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
                .fill(KakaoColors.brandYellow)
            )
            .frame(maxWidth: 240, alignment: .trailing)
    }
}

// MARK: - Colors

private enum KakaoColors {
    static let brandYellow = Color(red: 254.0/255.0, green: 229.0/255.0, blue: 0.0/255.0) // #FEE500
    static let chatBg      = Color(red: 178.0/255.0, green: 199.0/255.0, blue: 218.0/255.0) // #B2C7DA
    static let inputField  = Color(red: 242.0/255.0, green: 244.0/255.0, blue: 246.0/255.0) // #F2F4F6
    static let timestamp   = Color(red: 139.0/255.0, green: 149.0/255.0, blue: 161.0/255.0) // #8B95A1
    static let avatar      = Color(red: 200.0/255.0, green: 205.0/255.0, blue: 212.0/255.0)
}

// MARK: - Pool

enum KakaoChatPool {
    static let names: [String] = [
        "지영", "민수", "엄마", "팀장님", "현주", "수민", "지훈", "혜진",
        "동훈", "윤서", "재민", "다은", "준호", "예린", "성민"
    ]

    static let statusTimes: [String] = [
        "9:41", "10:23", "11:07", "12:14", "13:32",
        "14:51", "15:09", "16:28", "17:45", "18:02",
        "19:18", "20:34", "21:50"
    ]

    static let messageTemplates: [String] = [
        "안녕! 잘 지내?",
        "내일 7시에 강남역 어때?",
        "이거 봤어? 진짜 웃기다",
        "회의 자료 확인 부탁해",
        "고마워 ㅠㅠ",
        "ㅋㅋㅋㅋ 진짜?",
        "오늘 점심 뭐 먹지?",
        "응 알겠어 도착하면 연락해",
        "그거 어디서 샀어?",
        "다음 주에 시간 어때?",
        "잘 자~",
        "방금 도착했어",
        "조금 늦을 거 같아",
        "확인했어요!",
        "넵 알겠습니다",
        "지금 회의 중이라 나중에 연락해",
        "오늘 컨디션 어때?",
        "주말에 시간 되면 같이 영화 볼래?",
        "계산서 보냈어 확인해줘",
        "오케이 그럼 그렇게 진행할게",
        "내일 일정 변경됐어",
        "자료 메일로 보냈어요",
        "퇴근하고 만나자",
        "도착하면 카톡 줘",
        "아직 출발 못했어",
        "지금 가는 길이야",
        "10분만 기다려",
        "혹시 자료 좀 부탁해도 될까?",
        "내가 한 번 확인해볼게",
        "정말 미안",
        "괜찮아 천천히 와",
        "좋은 아침!",
        "수고하셨어요",
        "오늘 너무 피곤하다",
        "주말 잘 보내",
        "축하해!! 🎉",
        "건강 잘 챙겨",
        "이번 주 너무 바쁘다",
        "잠깐 통화 가능?",
        "회의 끝나고 연락드릴게요",
        "혹시 시간 되시면 잠깐 봬요",
        "받았어요 감사합니다",
        "확인 부탁드릴게요",
        "엄마 미안 오늘 못 갈 거 같아",
        "네 알겠습니다",
        "잘 부탁드립니다",
        "한 번 더 부탁해도 돼?",
        "응 그래",
        "ㅎㅎ 그러게",
        "편하게 말해줘",
        "조심히 가",
        "뭐해?"
    ]
}
