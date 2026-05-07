// SafariGenerators — Safari URL-bar (top) and Safari Article mock views.
// Source: classification spec v1 §3.8 (link.safari_top, link.safari_article).
// Frame 390×844, deterministic from `seed`.
import SwiftUI

// MARK: - Safari Top (URL bar emphasis)

public struct SafariTopGenerator: MockGenerator {
    public let code: CategoryCode = .linkSafariTop
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(SafariTopView(seed: seed))
    }
}

struct SafariTopView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let url = rng.pick(SafariPool.urls)
        let headline = rng.pick(SafariPool.headlines)
        let sub = rng.pick(SafariPool.subheads)
        let paragraphLineCounts: [Int] = (0..<3).map { _ in rng.int(in: 4...6) }

        return VStack(spacing: 0) {
            statusBar
            urlBar(url: url)
            content(headline: headline, sub: sub, lineCounts: paragraphLineCounts)
            Spacer(minLength: 0)
            bottomToolbar
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    private var statusBar: some View {
        HStack {
            Text("9:41").font(.system(size: 15, weight: .semibold))
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF7/255.0))
    }

    private func urlBar(url: String) -> some View {
        HStack(spacing: 8) {
            Text("aA")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.6))
            Spacer()
            Text(url)
                .font(.system(size: 15))
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF7/255.0))
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xFA/255.0))
    }

    private func content(headline: String, sub: String, lineCounts: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(headline)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.leading)
            Text(sub)
                .font(.system(size: 15))
                .foregroundStyle(Color.black.opacity(0.6))
            ForEach(Array(lineCounts.enumerated()), id: \.offset) { _, count in
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<count, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.black.opacity(0.18))
                            .frame(height: 10)
                            .frame(maxWidth: idx == count - 1 ? 220 : .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomToolbar: some View {
        HStack {
            Image(systemName: "chevron.left")
            Spacer()
            Image(systemName: "chevron.right")
            Spacer()
            Image(systemName: "square.and.arrow.up")
            Spacer()
            Image(systemName: "book")
            Spacer()
            Image(systemName: "square.on.square")
        }
        .font(.system(size: 20))
        .foregroundStyle(Color(red: 0.0, green: 0.48, blue: 1.0))
        .padding(.horizontal, 24)
        .frame(height: 50)
        .background(Color.white)
    }
}

// MARK: - Safari Article

public struct SafariArticleGenerator: MockGenerator {
    public let code: CategoryCode = .linkSafariArticle
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(SafariArticleView(seed: seed))
    }
}

struct SafariArticleView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let url = rng.pick(SafariPool.urls)
        let title = rng.pick(SafariPool.articleTitles)
        let byline = rng.pick(SafariPool.bylines)
        let lineCounts: [Int] = (0..<3).map { _ in rng.int(in: 4...6) }

        return VStack(spacing: 0) {
            statusBar
            urlBar(url: url)
            articleBody(title: title, byline: byline, lineCounts: lineCounts)
            Spacer(minLength: 0)
            bottomToolbar
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    private var statusBar: some View {
        HStack {
            Text("9:41").font(.system(size: 15, weight: .semibold))
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF7/255.0))
    }

    private func urlBar(url: String) -> some View {
        HStack(spacing: 8) {
            Text("aA")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.6))
            Spacer()
            Text(url)
                .font(.system(size: 15))
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0xF2/255.0, green: 0xF2/255.0, blue: 0xF7/255.0))
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xFA/255.0))
    }

    private func articleBody(title: String, byline: String, lineCounts: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.leading)
            Text(byline)
                .font(.system(size: 13))
                .foregroundStyle(Color.black.opacity(0.55))
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.85))
                .frame(height: 180)
                .padding(.vertical, 6)
            ForEach(Array(lineCounts.enumerated()), id: \.offset) { _, count in
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<count, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.black.opacity(0.18))
                            .frame(height: 10)
                            .frame(maxWidth: idx == count - 1 ? 200 : .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom, 2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomToolbar: some View {
        HStack {
            Image(systemName: "chevron.left")
            Spacer()
            Image(systemName: "chevron.right")
            Spacer()
            Image(systemName: "square.and.arrow.up")
            Spacer()
            Image(systemName: "book")
            Spacer()
            Image(systemName: "square.on.square")
        }
        .font(.system(size: 20))
        .foregroundStyle(Color(red: 0.0, green: 0.48, blue: 1.0))
        .padding(.horizontal, 24)
        .frame(height: 50)
        .background(Color.white)
    }
}

// MARK: - Pool

enum SafariPool {
    static let urls: [String] = [
        "techcrunch.com",
        "https://news.naver.com/article/...",
        "github.com/swift",
        "blog.medium.com",
        "youtube.com/watch?v=...",
        "namu.wiki/w/...",
        "velog.io/@...",
        "brunch.co.kr/..."
    ]

    static let headlines: [String] = [
        "Apple Vision Pro 한국 출시 임박",
        "삼성, 새로운 AI 모델 공개",
        "OpenAI 차세대 모델 GPT-5 베타 시작",
        "테슬라 로보택시 서울 시범 운행",
        "쿠팡, 신선식품 새벽배송 확대",
        "카카오, 모빌리티 사업 재편 발표",
        "네이버 클라우드 글로벌 확장",
        "한국 스타트업 IPO 러시"
    ]

    static let subheads: [String] = [
        "업계 관계자에 따르면 다음 주 공식 발표 예정",
        "기술 시장에 미칠 파장에 주목",
        "사용자 100만 명 돌파 임박",
        "투자 업계의 평가는 엇갈려",
        "정부 규제와의 충돌 가능성"
    ]

    static let articleTitles: [String] = [
        "AI 시대, 우리는 어떻게 일해야 하는가",
        "한국 부동산 시장의 새로운 변곡점",
        "Z세대가 선택한 올해의 트렌드 10",
        "테크 거인들의 다음 한 수",
        "전기차 충전 인프라, 어디까지 왔나",
        "구독 경제, 끝나지 않은 진화",
        "한국 콘텐츠가 세계로 가는 길"
    ]

    static let bylines: [String] = [
        "김지영 기자 · 2026.05.07",
        "박민수 칼럼 · 5월 7일",
        "테크인사이트 편집부 · 2시간 전",
        "이정현 객원기자 · 어제",
        "조선비즈 · 1일 전"
    ]
}
