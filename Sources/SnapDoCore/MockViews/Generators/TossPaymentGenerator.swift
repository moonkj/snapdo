// TossPaymentGenerator — Toss 결제 완료 payment-receipt mock view.
// Source: classification spec §3.5 (Toss payment screen variant — same shell
// as transfer with 가맹점/카드 rows and no 메모).
import SwiftUI

public struct TossPaymentGenerator: MockGenerator {
    public let code: CategoryCode = .receiptTossPayment

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(TossReceiptView(seed: seed, isPayment: true))
    }
}
