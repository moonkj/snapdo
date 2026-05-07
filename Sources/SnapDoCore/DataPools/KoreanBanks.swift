// Korean bank pool — for Toss/KakaoPay-style transfer mock generators.
// Source: classification spec v1 §3.4–3.5, §4.1; concept §22 (KR brand names).
// Pure data; consumed by Phase B2 mock-view generators.

public enum KoreanBanks {
    public struct Bank: Sendable {
        public let displayName: String
        public let romanized: String
        public let appName: String?

        public init(displayName: String, romanized: String, appName: String?) {
            self.displayName = displayName
            self.romanized = romanized
            self.appName = appName
        }
    }

    public static let all: [Bank] = [
        Bank(displayName: "국민",     romanized: "KB",        appName: "KB스타뱅킹"),
        Bank(displayName: "신한",     romanized: "Shinhan",   appName: "신한 SOL"),
        Bank(displayName: "하나",     romanized: "Hana",      appName: "하나원큐"),
        Bank(displayName: "우리",     romanized: "WOORI",     appName: "우리WON뱅킹"),
        Bank(displayName: "농협",     romanized: "NH",        appName: "NH올원뱅크"),
        Bank(displayName: "기업",     romanized: "IBK",       appName: "i-ONE Bank"),
        Bank(displayName: "토스뱅크", romanized: "Toss",      appName: "토스뱅크"),
        Bank(displayName: "카카오뱅크", romanized: "KakaoBank", appName: "카카오뱅크")
    ]
}
