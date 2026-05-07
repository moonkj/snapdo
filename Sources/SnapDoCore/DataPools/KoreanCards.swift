// Korean credit-card pool — for card-alert push notification mock generators.
// Source: classification spec v1 §3.6, §4.1; concept §22 (KR brand names).
// Pure data; consumed by Phase B2 mock-view generators.

public enum KoreanCards {
    public struct Card: Sendable {
        public let displayName: String
        public let romanized: String
        public let pushPrefix: String

        public init(displayName: String, romanized: String, pushPrefix: String) {
            self.displayName = displayName
            self.romanized = romanized
            self.pushPrefix = pushPrefix
        }
    }

    public static let all: [Card] = [
        Card(displayName: "KB국민카드", romanized: "KB",      pushPrefix: "[KB체크]"),
        Card(displayName: "신한카드",   romanized: "Shinhan", pushPrefix: "[Shinhan]"),
        Card(displayName: "삼성카드",   romanized: "Samsung", pushPrefix: "[삼성카드]"),
        Card(displayName: "현대카드",   romanized: "Hyundai", pushPrefix: "[현대카드]"),
        Card(displayName: "우리카드",   romanized: "WOORI",   pushPrefix: "[우리카드]")
    ]
}
