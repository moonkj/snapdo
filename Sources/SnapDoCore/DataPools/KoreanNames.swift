// Korean name pool — given/family/display labels for mock contact lists.
// Source: classification spec v1 §4.1 (DataPools / 한국어 사전 200+ 어휘 요건).
// Pure data; consumed by Phase B2 mock-view generators.

public enum KoreanNames {
    /// 50+ Korean given names (mix of common male/female names plus relational labels).
    public static let givenNames: [String] = [
        "지영", "민수", "현주", "수민", "지훈", "혜진", "동훈", "윤서", "재민", "다은",
        "준호", "예린", "성민", "서윤", "도윤", "시우", "하준", "주원", "지호", "우진",
        "선우", "건우", "현우", "민준", "예준", "서준", "유준", "시윤", "은우", "지안",
        "하윤", "서아", "하은", "지유", "하린", "지우", "윤아", "채원", "수아", "다인",
        "예원", "시아", "유나", "지원", "지민", "사랑", "별", "봄", "가을", "겨울",
        "이슬", "보검", "수현"
    ]

    /// 20+ Korean family names (top surnames by frequency).
    public static let familyNames: [String] = [
        "김", "이", "박", "최", "정", "강", "조", "윤", "장", "임",
        "한", "오", "서", "신", "권", "황", "안", "송", "류", "전",
        "홍", "고", "문", "양", "손"
    ]

    /// 30+ contact-list display strings (relational labels, nicknames, parenthesised tags).
    public static let displayLabels: [String] = [
        "엄마", "아빠", "팀장님", "지영 ❤️", "지호 (회사)", "민수 (대학)",
        "혜진 언니", "동훈 오빠", "수민 누나", "재민 형", "윤서 (동아리)",
        "준호 선배", "예린 (스터디)", "성민 (헬스장)", "서윤 (요가)",
        "도윤 (회사)", "시우 (고등학교)", "하준 (중학교)", "주원 (초등학교)",
        "지호 (모임)", "우진 (영어회화)", "선우 차장님", "건우 과장님",
        "현우 대리님", "민준 사장님", "할머니", "할아버지", "이모", "삼촌",
        "고모", "큰아빠", "작은엄마", "사촌 동생", "옆집 아주머니", "지영 ♥",
        "엄마 ❤️", "여보", "자기"
    ]
}
