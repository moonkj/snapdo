// NaverPayGenerator — 네이버페이 receipt mock view.
// Source: classification spec §3.4–3.6 family; NaverPay variant
// (green #03C75A header, big amount + check + detail card).
import SwiftUI

public struct NaverPayGenerator: MockGenerator {
    public let code: CategoryCode = .receiptNaverPay

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(NaverPayView(seed: seed))
    }
}

struct NaverPayView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let store   = rng.pick(KoreanStores.all)
        let amount  = KoreanAmounts.amountString(rng: &rng)
        let stamp   = KoreanTimestamps.receiptStamp(rng: &rng)
        let card    = rng.pick(KoreanCards.all)
        let timeStr = "\(rng.int(in: 8...22)):\(String(format: "%02d", rng.int(in: 0...59)))"

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            header
            mainArea(amount: amount)
            detailCard(store: store, stamp: stamp, card: card.displayName)
            Spacer(minLength: 0)
            bottomButton
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
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
        .background(NaverPayColors.brandGreen)
    }

    private var header: some View {
        ZStack {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding(.horizontal, 16)

            Text("네이버페이")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(height: 56)
        .background(NaverPayColors.brandGreen)
    }

    private func mainArea(amount: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(NaverPayColors.brandGreen)
                    .frame(width: 60, height: 60)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            Text("결제 완료")
                .font(.system(size: 16))
                .foregroundStyle(Color.black.opacity(0.6))
            Text(amount)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.black)
        }
        .padding(.top, 36)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
    }

    private func detailCard(store: String, stamp: String, card: String) -> some View {
        VStack(spacing: 14) {
            row(label: "결제처", value: store)
            row(label: "결제일시", value: stamp)
            row(label: "결제수단", value: card)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(NaverPayColors.cardGrey)
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

    private var bottomButton: some View {
        Text("확인")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(NaverPayColors.brandGreen)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
    }
}

private enum NaverPayColors {
    static let brandGreen = Color(red: 3.0/255.0, green: 199.0/255.0, blue: 90.0/255.0) // #03C75A
    static let cardGrey   = Color(red: 242.0/255.0, green: 244.0/255.0, blue: 246.0/255.0) // #F2F4F6
}
