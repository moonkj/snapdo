// KakaoBankGenerator — KakaoBank (카카오뱅크) receipt mock view.
// Source: classification spec §3.4 style; KakaoBank brand variant
// (yellow #FEE500 accent, "카카오뱅크" header label, 송금/결제 screens).
import SwiftUI

public struct KakaoBankGenerator: MockGenerator {
    public let code: CategoryCode = .receiptKakaobank

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(KakaoBankView(seed: seed))
    }
}

struct KakaoBankView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let isPayment = rng.bool(0.5)
        let amount    = KoreanAmounts.amountString(rng: &rng)
        let stamp     = KoreanTimestamps.receiptStamp(rng: &rng)
        let receiver  = isPayment
            ? rng.pick(KoreanStores.all)
            : rng.pick(KoreanNames.givenNames)
        let bank      = rng.pick(KoreanBanks.all)
        let timeStr   = "\(rng.int(in: 8...22)):\(String(format: "%02d", rng.int(in: 0...59)))"
        let title     = isPayment ? "결제 완료" : "송금 완료"

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            header(title: title)
            mainArea(amount: amount)
            detailCard(receiver: receiver, bank: bank, stamp: stamp, isPayment: isPayment)
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

    private func header(title: String) -> some View {
        ZStack {
            HStack {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.black)
                Spacer()
            }
            .padding(.horizontal, 16)

            VStack(spacing: 2) {
                Text("카카오뱅크")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.55))
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.black)
            }
        }
        .frame(height: 72)
        .background(KakaoBankColors.brandYellow)
    }

    private func mainArea(amount: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(KakaoBankColors.checkGreen)
                    .frame(width: 60, height: 60)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            Text(amount)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color.black)
            Text("카카오뱅크 거래가 완료되었어요")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.55))
        }
        .padding(.top, 36)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
    }

    private func detailCard(receiver: String, bank: KoreanBanks.Bank, stamp: String, isPayment: Bool) -> some View {
        VStack(spacing: 14) {
            row(label: isPayment ? "결제처" : "받는 분", value: receiver)
            row(label: "거래일시", value: stamp)
            row(label: isPayment ? "결제수단" : "출금계좌", value: "\(bank.displayName) ****-1234")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(KakaoBankColors.cardGrey)
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
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(KakaoBankColors.brandYellow)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
    }
}

private enum KakaoBankColors {
    static let brandYellow = Color(red: 254.0/255.0, green: 229.0/255.0, blue: 0.0/255.0) // #FEE500
    static let checkGreen  = Color(red: 52.0/255.0,  green: 199.0/255.0, blue: 89.0/255.0) // #34C759
    static let cardGrey    = Color(red: 242.0/255.0, green: 244.0/255.0, blue: 246.0/255.0) // #F2F4F6
}
