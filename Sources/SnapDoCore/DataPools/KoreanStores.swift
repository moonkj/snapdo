// Korean store/brand pool — for KakaoPay/Toss/card-alert/receipt mock generators.
// Source: classification spec v1 §3.4–3.6, §4.1; concept §22 (KR brand names).
// Pure data; consumed by Phase B2 mock-view generators.

public enum KoreanStores {
    /// Cafe brands (10+).
    public static let cafes: [String] = [
        "스타벅스", "투썸플레이스", "이디야", "빽다방", "폴 바셋",
        "컴포즈커피", "메가커피", "할리스", "엔제리너스", "더벤티",
        "커피빈", "탐앤탐스", "공차"
    ]

    /// Convenience-store chains.
    public static let convenience: [String] = [
        "GS25", "CU", "이마트24", "세븐일레븐", "미니스톱"
    ]

    /// Fast-food / chain restaurants (15).
    public static let fastFood: [String] = [
        "맥도날드", "버거킹", "롯데리아", "맘스터치", "서브웨이",
        "배스킨라빈스", "KFC", "BBQ", "BHC", "교촌치킨",
        "굽네치킨", "도미노피자", "피자헛", "미스터피자", "노브랜드 버거"
    ]

    /// Sit-down / casual restaurants (15+).
    public static let restaurants: [String] = [
        "김밥천국", "한솥", "본죽", "죠스떡볶이", "더진국설렁탕",
        "강남교자", "명동교자", "본가", "놀부부대찌개", "원조 할머니 보쌈",
        "투다리", "이삭토스트", "신전떡볶이", "엽기떡볶이", "두끼떡볶이",
        "백종원의 원조쌈밥집", "마포갈매기", "새마을식당"
    ]

    /// General retail / e-commerce / drugstore (15+).
    public static let general: [String] = [
        "올리브영", "다이소", "교보문고", "영풍문고", "무신사",
        "29CM", "ABC마트", "이마트", "홈플러스", "롯데마트",
        "코스트코", "네이버 스마트스토어", "쿠팡", "11번가", "G마켓",
        "옥션", "위메프", "티몬", "마켓컬리", "SSG닷컴"
    ]

    /// Combined for random pick.
    public static let all: [String] = cafes + convenience + fastFood + restaurants + general
}
