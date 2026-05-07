// Korean places pool — for KakaoMap-style mock generators and address fields.
// Source: classification spec v1 §3.7 (KakaoMap), §4.1 (한국어 사전 200+ 어휘 요건).
// Pure data; consumed by Phase B2 mock-view generators.

public enum KoreanPlaces {
    /// 30+ Seoul metro stations and well-known neighbourhoods.
    public static let seoulLandmarks: [String] = [
        "강남역", "홍대입구", "광화문", "서울역", "잠실",
        "여의도", "신촌", "명동", "압구정", "종로3가",
        "을지로", "한강진", "이태원", "가로수길", "성수동",
        "망원동", "연남동", "익선동", "북촌", "서촌",
        "동대문", "청담동", "삼성동", "잠실새내", "사당",
        "신림", "노원", "수유", "강서", "마곡",
        "건대입구", "왕십리", "용산", "여의나루", "합정"
    ]

    /// 20+ generic-style addresses (street/dong-level fragments).
    public static let addressFragments: [String] = [
        "서울시 강남구 역삼동 123-45",
        "서울시 서초구 서초대로 77길 12",
        "서울시 마포구 양화로 45",
        "서울시 종로구 종로 1가 24",
        "서울시 송파구 올림픽로 300",
        "서울시 영등포구 여의대로 24",
        "서울시 용산구 한강대로 405",
        "서울시 성동구 성수이로 22길 7",
        "서울시 광진구 능동로 120",
        "서울시 강서구 마곡중앙로 161",
        "경기도 성남시 분당구 판교역로 235",
        "경기도 수원시 영통구 광교로 145",
        "경기도 고양시 일산동구 정발산로 30",
        "경기도 용인시 기흥구 강남로 40",
        "경기도 안양시 동안구 시민대로 235",
        "경기도 부천시 원미구 길주로 73",
        "인천시 연수구 송도과학로 32",
        "부산시 해운대구 우동 1467",
        "대구시 중구 동성로2가 88",
        "광주시 동구 충장로 50",
        "대전시 유성구 대학로 99",
        "울산시 남구 삼산로 282",
        "제주시 노형동 925-13"
    ]
}
