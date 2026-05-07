// InstagramDMGenerator — Instagram DM mock view.
// Source: classification spec §3.5 (Instagram DM sub-pattern).
// White bg; grey #EFEFEF other-bubble; my-bubble blue→purple gradient (#4F5BD5 → #962FBF).
import SwiftUI

public struct InstagramDMGenerator: MockGenerator {
    public let code: CategoryCode = .convInstagramDM

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(InstagramDMView(seed: seed))
    }
}

struct InstagramDMView: View {
    let seed: UInt64

    private static let usernames: [String] = [
        "jiyoung_lee", "minsu.park", "haein_92", "sushi_taylor",
        "alex.kim", "moonlight_jay", "dailycoffee_", "seoul.runs",
        "kpop_hannah", "travel.with.dan", "ramen_addict", "blue_skies_91"
    ]

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let username = rng.pick(Self.usernames)

        let messageCount = rng.int(in: 3...8)
        var minute = rng.int(in: 8 * 60 ... 22 * 60)
        let mineProbability = rng.double(in: 0.4...0.6)

        var messages: [InstaDMData] = []
        var lastSenderWasMine: Bool? = nil
        for _ in 0..<messageCount {
            let isMine = rng.bool(mineProbability)
            let text = rng.pick(KoreanMessages.templates)
            let firstOfRun: Bool
            if let prev = lastSenderWasMine {
                firstOfRun = prev != isMine
            } else {
                firstOfRun = true
            }
            let h = (minute / 60) % 24
            let m = minute % 60
            let ampm = h < 12 ? "오전" : "오후"
            let h12 = h % 12 == 0 ? 12 : h % 12
            let stamp = "\(ampm) \(h12):\(String(format: "%02d", m))"
            messages.append(InstaDMData(
                isMine: isMine,
                text: text,
                timestamp: stamp,
                firstOfRun: firstOfRun
            ))
            lastSenderWasMine = isMine
            minute += rng.int(in: 1...180)
        }

        let timeStr = rng.pick(KakaoChatPool.statusTimes)

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            navBar(username: username)
            messageArea(messages: messages)
            inputBar
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    // MARK: bars

    private var border: Color {
        Color(red: 219.0/255.0, green: 219.0/255.0, blue: 219.0/255.0)
    }

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
            .foregroundStyle(.black)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(Color.white)
    }

    private func navBar(username: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
                Circle()
                    .fill(Color(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0))
                    .frame(width: 32, height: 32)
                    .padding(.leading, 6)
                Text(username)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.leading, 6)
                Spacer()
                HStack(spacing: 16) {
                    Image(systemName: "phone")
                    Image(systemName: "video")
                }
                .font(.system(size: 20))
                .foregroundStyle(.black)
            }
            .padding(.horizontal, 14)
            .frame(height: 56)
            .background(Color.white)
            Rectangle()
                .fill(border)
                .frame(height: 0.5)
        }
    }

    private func messageArea(messages: [InstaDMData]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                InstaDMRow(data: msg)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "camera.fill")
                .font(.system(size: 22))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0x4F/255.0, green: 0x5B/255.0, blue: 0xD5/255.0),
                            Color(red: 0x96/255.0, green: 0x2F/255.0, blue: 0xBF/255.0)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(border, lineWidth: 0.5)
                    .frame(height: 40)
                HStack(spacing: 12) {
                    Text("Message...")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gray.opacity(0.6))
                        .padding(.leading, 14)
                    Spacer()
                    Image(systemName: "mic")
                    Image(systemName: "photo")
                    Image(systemName: "heart")
                }
                .font(.system(size: 18))
                .foregroundStyle(.black.opacity(0.7))
                .padding(.trailing, 12)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 64)
        .background(Color.white)
    }
}

private struct InstaDMData {
    let isMine: Bool
    let text: String
    let timestamp: String
    let firstOfRun: Bool
}

private struct InstaDMRow: View {
    let data: InstaDMData

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0x4F/255.0, green: 0x5B/255.0, blue: 0xD5/255.0),
                Color(red: 0x96/255.0, green: 0x2F/255.0, blue: 0xBF/255.0)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private let otherBg = Color(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0) // #EFEFEF

    var body: some View {
        if data.isMine {
            HStack {
                Spacer(minLength: 60)
                Text(data.text)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 22).fill(gradient)
                    )
                    .frame(maxWidth: 260, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            HStack(alignment: .bottom, spacing: 6) {
                if data.firstOfRun {
                    Circle()
                        .fill(Color(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0))
                        .frame(width: 32, height: 32)
                } else {
                    Color.clear.frame(width: 32, height: 32)
                }
                Text(data.text)
                    .font(.system(size: 15))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 22).fill(otherBg)
                    )
                    .frame(maxWidth: 260, alignment: .leading)
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
