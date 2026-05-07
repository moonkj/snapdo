// Korean payment-amount pool — formats KRW values for receipts/push/transfer mocks.
// Source: classification spec v1 §3.4–3.6 (KakaoPay/Toss/Card), §4.1.
// Pure helper; no stored state.

import Foundation

public enum KoreanAmounts {
    /// Generates a realistic Korean payment amount string like "12,500원" or "1,234,567원".
    public static func amountString<R: RandomNumberGenerator>(rng: inout R) -> String {
        let won = Int.random(in: 1_000...500_000, using: &rng)
        return formatKRW(won)
    }

    /// Formats a raw integer KRW value with thousands separators and the 원 suffix.
    public static func formatKRW(_ won: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        return (f.string(from: NSNumber(value: won)) ?? "\(won)") + "원"
    }
}
