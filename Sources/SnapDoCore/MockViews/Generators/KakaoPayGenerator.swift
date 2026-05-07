// KakaoPayGenerator — KakaoPay receipt (결제완료 / 송금완료) mock view.
// Source: classification spec §3.4 (KakaoPay receipt screen).
// 390 × 844 frame; deterministic per seed.
import SwiftUI

public struct KakaoPayGenerator: MockGenerator {
    public let code: CategoryCode = .receiptKakaoPay

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(KakaoPayView(seed: seed))
    }
}

// MARK: - View

struct KakaoPayView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let isPayment   = rng.bool(0.6)              // 60% 결제, 40% 송금
        let yellowHeader = rng.bool(0.5)
        let store       = rng.pick(KoreanStores.all)
        let amount      = KoreanAmounts.amountString(rng: &rng)
        let stamp       = KoreanTimestamps.receiptStamp(rng: &rng)
        let card        = rng.pick(KoreanCards.all)
        let timeStr     = "\(rng.int(in: 8...22)):\(String(format: "%02d", rng.int(in: 0...59)))"
        let title       = isPayment ? "결제완료" : "송금완료"
        let subtitle    = isPayment ? "결제가 완료되었어요" : "송금이 완료되었어요"
        let receiver    = isPayment ? store : rng.pick(KoreanNames.givenNames)

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            header(title: title, yellow: yellowHeader)
            mainArea(amount: amount, subtitle: subtitle)
            detailCard(receiver: receiver, stamp: stamp, card: card.displayName, isPayment: isPayment)
            Spacer(minLength: 0)
            bottomButton(yellow: yellowHeader)
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
            .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(Color.white)
    }

    private func header(title: String, yellow: Bool) -> some View {
        ZStack {
            HStack {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black)
                Spacer()
            }
            .padding(.horizontal, 16)

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.black)
        }
        .frame(height: 56)
        .background(yellow ? KakaoPayColors.brandYellow : Color.white)
    }

    private func mainArea(amount: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(KakaoPayColors.checkGreen)
                    .frame(width: 60, height: 60)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            Text(amount)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.black)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.55))
        }
        .padding(.top, 36)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
    }

    private func detailCard(receiver: String, stamp: String, card: String, isPayment: Bool) -> some View {
        VStack(spacing: 14) {
            row(label: isPayment ? "결제처" : "받는 분", value: receiver)
            row(label: isPayment ? "결제일시" : "송금일시", value: stamp)
            row(label: isPayment ? "결제수단" : "출금계좌", value: card)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(KakaoPayColors.cardGrey)
        )
        .padding(.horizontal, 20)
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private func bottomButton(yellow: Bool) -> some View {
        Text(yellow ? "확인" : "영수증 보기")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(yellow ? Color.black : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(yellow ? KakaoPayColors.brandYellow : Color.black)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
    }
}

private enum KakaoPayColors {
    static let brandYellow = Color(red: 254.0/255.0, green: 229.0/255.0, blue: 0.0/255.0) // #FEE500
    static let checkGreen  = Color(red: 52.0/255.0,  green: 199.0/255.0, blue: 89.0/255.0) // #34C759
    static let cardGrey    = Color(red: 242.0/255.0, green: 244.0/255.0, blue: 246.0/255.0) // #F2F4F6
}
