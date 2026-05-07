// TossTransferGenerator — Toss 송금완료 transfer-receipt mock view.
// Source: classification spec §3.5 (Toss transfer/payment screen).
// 390 × 844 frame; deterministic per seed.
import SwiftUI

public struct TossTransferGenerator: MockGenerator {
    public let code: CategoryCode = .receiptTossTransfer

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(TossReceiptView(seed: seed, isPayment: false))
    }
}

// MARK: - Shared Toss receipt view (transfer + payment)

struct TossReceiptView: View {
    let seed: UInt64
    let isPayment: Bool

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let receiver = isPayment
            ? rng.pick(KoreanStores.all)
            : rng.pick(KoreanNames.givenNames)
        let bank   = rng.pick(KoreanBanks.all)
        let card   = rng.pick(KoreanCards.all)
        let memo   = rng.pick(TossMemoPool.memos)
        let amount = KoreanAmounts.amountString(rng: &rng)
        let stamp  = KoreanTimestamps.receiptStamp(rng: &rng)
        let title  = isPayment ? "결제 완료" : "송금 완료"
        let timeStr = "\(rng.int(in: 8...22)):\(String(format: "%02d", rng.int(in: 0...59)))"

        return ZStack {
            TossColors.brandBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                statusBar(time: timeStr)
                header
                heroBlock(title: title, amount: amount)
                detailCard(receiver: receiver, bank: bank, card: card, memo: memo, stamp: stamp)
                Spacer(minLength: 0)
                bottomButton
            }
        }
        .frame(width: 390, height: 844)
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
    }

    private var header: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
    }

    private func heroBlock(title: String, amount: String) -> some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(TossColors.brandBlue)
            }
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.white)
            Text(amount)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .padding(.top, 24)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
    }

    private func detailCard(
        receiver: String,
        bank: KoreanBanks.Bank,
        card: KoreanCards.Card,
        memo: String,
        stamp: String
    ) -> some View {
        VStack(spacing: 16) {
            if isPayment {
                detailRow("가맹점", receiver)
                detailRow("결제 카드", "\(card.displayName) ****-1234")
                detailRow("출금 계좌", "\(bank.displayName) ****-1234")
                detailRow("거래 일시", stamp)
            } else {
                detailRow("받는 분", receiver)
                detailRow("보낸 계좌", "\(bank.displayName) ****-1234")
                detailRow("메모", memo)
                detailRow("거래 일시", stamp)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .padding(.horizontal, 16)
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(Color.black.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
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
            .background(TossColors.brandBlue)
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
    }
}

enum TossColors {
    static let brandBlue = Color(red: 0.0/255.0, green: 100.0/255.0, blue: 255.0/255.0) // #0064FF
}

enum TossMemoPool {
    static let memos: [String] = [
        "월세", "회식비", "용돈", "축의금", "여행 정산",
        "식비", "기프티콘", "공동구매", "이체 잔액"
    ]
}
