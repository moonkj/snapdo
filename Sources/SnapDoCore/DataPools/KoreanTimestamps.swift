// Korean timestamp pool — formats chat-style and receipt-style stamps.
// Source: classification spec v1 §3.4–3.6 + motion guide §3.4 (timestamps).
// Pure helper; no stored state.

import Foundation

public enum KoreanTimestamps {
    /// Random "오전 9:23" / "오후 2:54" style timestamp for chat mocks.
    public static func chatTime<R: RandomNumberGenerator>(rng: inout R) -> String {
        let h = Int.random(in: 1...12, using: &rng)
        let m = Int.random(in: 0...59, using: &rng)
        let prefix = Bool.random(using: &rng) ? "오전" : "오후"
        return "\(prefix) \(h):" + String(format: "%02d", m)
    }

    /// "2026.05.04 14:32" style date+time for receipts/push notifications.
    public static func receiptStamp<R: RandomNumberGenerator>(rng: inout R) -> String {
        let mo = Int.random(in: 1...12, using: &rng)
        let d  = Int.random(in: 1...28, using: &rng)
        let h  = Int.random(in: 8...22, using: &rng)
        let m  = Int.random(in: 0...59, using: &rng)
        return String(format: "2026.%02d.%02d %02d:%02d", mo, d, h, m)
    }
}
