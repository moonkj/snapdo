// CardAlertGenerator — Lock-screen card-charge push-notification mock views.
// Source: classification spec §3.6 (5 card brands × push-style alert).
// One CardAlertView, 5 generator wrappers picking the right Card row.
import SwiftUI

// MARK: - Generators (one per brand)

public struct CardAlertKBGenerator: MockGenerator {
    public let code: CategoryCode = .receiptCardKB
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(CardAlertView(seed: seed, card: cardForRomanized("KB")))
    }
}

public struct CardAlertShinhanGenerator: MockGenerator {
    public let code: CategoryCode = .receiptCardShinhan
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(CardAlertView(seed: seed, card: cardForRomanized("Shinhan")))
    }
}

public struct CardAlertSamsungGenerator: MockGenerator {
    public let code: CategoryCode = .receiptCardSamsung
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(CardAlertView(seed: seed, card: cardForRomanized("Samsung")))
    }
}

public struct CardAlertHyundaiGenerator: MockGenerator {
    public let code: CategoryCode = .receiptCardHyundai
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(CardAlertView(seed: seed, card: cardForRomanized("Hyundai")))
    }
}

public struct CardAlertWooriGenerator: MockGenerator {
    public let code: CategoryCode = .receiptCardWoori
    public init() {}
    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(CardAlertView(seed: seed, card: cardForRomanized("WOORI")))
    }
}

/// Selects the matching Card from the shared pool. Falls back to the first
/// entry to keep the renderer alive if the pool ever changes.
private func cardForRomanized(_ romanized: String) -> KoreanCards.Card {
    KoreanCards.all.first(where: { $0.romanized == romanized }) ?? KoreanCards.all[0]
}

// MARK: - Shared lock-screen view

struct CardAlertView: View {
    let seed: UInt64
    let card: KoreanCards.Card

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let store      = rng.pick(KoreanStores.all)
        let amount     = KoreanAmounts.amountString(rng: &rng)
        let stamp      = KoreanTimestamps.receiptStamp(rng: &rng)
        let isDarkCard = rng.bool(0.5)
        let isJustNow  = rng.bool(0.4)
        let agoText    = isJustNow
            ? "방금"
            : "오전 \(rng.int(in: 6...11)):\(String(format: "%02d", rng.int(in: 0...59)))"
        let lockTime   = "\(rng.int(in: 1...12)):\(String(format: "%02d", rng.int(in: 0...59)))"
        let lockDate   = lockDateString(rng: &rng)
        let header     = card.displayName     // Card lacks appName; spec fallback.
        let body       = "\(card.pushPrefix) \(stamp) \(store) \(amount) 일시불승인"

        return ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                statusBar
                Spacer().frame(height: 24)
                lockClock(time: lockTime, date: lockDate)
                Spacer().frame(height: 60)
                notificationCard(header: header, body: body, ago: agoText, dark: isDarkCard)
                Spacer(minLength: 0)
            }
        }
        .frame(width: 390, height: 844)
    }

    private var statusBar: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
            .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
    }

    private func lockClock(time: String, date: String) -> some View {
        VStack(spacing: 4) {
            Text(date)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.85))
            Text(time)
                .font(.system(size: 88, weight: .thin))
                .foregroundStyle(Color.white)
        }
        .frame(maxWidth: .infinity)
    }

    private func notificationCard(header: String, body: String, ago: String, dark: Bool) -> some View {
        let bg     = dark ? Color(red: 28.0/255.0, green: 28.0/255.0, blue: 30.0/255.0) // #1C1C1E
                          : Color.white
        let primary   = dark ? Color.white : Color.black
        let secondary = primary.opacity(0.55)
        let badgeBg   = primary.opacity(0.15)

        return HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(badgeBg)
                Text(String(card.romanized.prefix(1)))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(primary)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(header)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(primary)
                    Spacer()
                    Text(ago)
                        .font(.system(size: 12))
                        .foregroundStyle(secondary)
                }
                Text(body)
                    .font(.system(size: 14))
                    .foregroundStyle(primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 390 - 32, height: 96, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(bg)
        )
    }

    private func lockDateString<R: RandomNumberGenerator>(rng: inout R) -> String {
        let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
        let mo = Int.random(in: 1...12, using: &rng)
        let d  = Int.random(in: 1...28, using: &rng)
        let w  = weekdays[Int.random(in: 0..<weekdays.count, using: &rng)]
        return "\(mo)월 \(d)일 \(w)"
    }
}
