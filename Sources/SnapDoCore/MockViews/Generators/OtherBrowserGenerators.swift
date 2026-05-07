// OtherBrowserGenerators — Chrome, YouTube video, and shared link card mock views.
// Source: classification spec v1 §3.8 (link.chrome, link.youtube_video, link.shared_link_card).
// Frame 390×844, deterministic from `seed`.
import SwiftUI

// MARK: - Chrome

public struct ChromeGenerator: MockGenerator {
    public let code: CategoryCode = .linkChrome
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(ChromeView(seed: seed))
    }
}

struct ChromeView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let url = rng.pick(SafariPool.urls)
        let title = rng.pick(SafariPool.articleTitles)
        let byline = rng.pick(SafariPool.bylines)
        let lineCounts: [Int] = (0..<3).map { _ in rng.int(in: 4...6) }

        return VStack(spacing: 0) {
            statusBar
            tabsRow
            urlBar(url: url)
            article(title: title, byline: byline, lineCounts: lineCounts)
            Spacer(minLength: 0)
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
        .background(Color.white)
    }

    private var tabsRow: some View {
        HStack(spacing: 6) {
            tab("Naver", active: true)
            tab("뉴스", active: false)
            tab("YouTube", active: false)
            Spacer()
            Image(systemName: "plus")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(Color(white: 0.96))
    }

    private func tab(_ s: String, active: Bool) -> some View {
        HStack(spacing: 6) {
            Circle().fill(Color(white: 0.7)).frame(width: 10, height: 10)
            Text(s).font(.system(size: 12)).foregroundStyle(Color.black.opacity(0.7))
            Image(systemName: "xmark").font(.system(size: 9))
                .foregroundStyle(Color.black.opacity(0.5))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(active ? Color.white : Color(white: 0.92))
        )
    }

    private func urlBar(url: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.black.opacity(0.55))
            Text(url)
                .font(.system(size: 14))
                .foregroundStyle(Color.black)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.55))
            Image(systemName: "ellipsis")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.55))
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            Capsule().fill(Color(white: 0.92))
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
    }

    private func article(title: String, byline: String, lineCounts: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.black)
            Text(byline)
                .font(.system(size: 13))
                .foregroundStyle(Color.black.opacity(0.55))
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(white: 0.85))
                .frame(height: 160)
                .padding(.vertical, 4)
            ForEach(Array(lineCounts.enumerated()), id: \.offset) { _, count in
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<count, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.black.opacity(0.18))
                            .frame(height: 10)
                            .frame(maxWidth: idx == count - 1 ? 200 : .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - YouTube Video

public struct YoutubeVideoGenerator: MockGenerator {
    public let code: CategoryCode = .linkYoutubeVideo
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(YoutubeVideoView(seed: seed))
    }
}

struct YoutubeVideoView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let title = rng.pick(YoutubePool.videoTitles)
        let channel = rng.pick(YoutubePool.channels)
        let views = rng.int(in: 12000...3500000)
        let related: [(String, String)] = (0..<4).map { _ in
            (rng.pick(YoutubePool.videoTitles), rng.pick(YoutubePool.channels))
        }

        return VStack(spacing: 0) {
            statusBar
            videoPlayer
            videoMeta(title: title, channel: channel, views: views)
            relatedList(related)
            Spacer(minLength: 0)
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
        .foregroundStyle(Color.white)
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(Color.black)
    }

    private var videoPlayer: some View {
        ZStack {
            Color(red: 0x1C/255.0, green: 0x1C/255.0, blue: 0x1E/255.0)
            Image(systemName: "play.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.white)
        }
        .frame(height: 240)
    }

    private func videoMeta(title: String, channel: String, views: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.black)
                .lineLimit(2)
            HStack(spacing: 6) {
                Text(channel).font(.system(size: 13)).foregroundStyle(Color.black.opacity(0.6))
                Text("▪").font(.system(size: 9)).foregroundStyle(Color.black.opacity(0.4))
                Text("조회수 \(formatViews(views))회").font(.system(size: 13))
                    .foregroundStyle(Color.black.opacity(0.6))
            }
            HStack(spacing: 10) {
                Circle().fill(Color(white: 0.85)).frame(width: 32, height: 32)
                Text(channel).font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("구독")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 1.0, green: 0.0, blue: 0.0))
                    )
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func formatViews(_ v: Int) -> String {
        if v >= 10000 { return "\(v / 10000)만" }
        return "\(v)"
    }

    private func relatedList(_ items: [(String, String)]) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.82))
                        .frame(width: 120, height: 68)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.0)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.black)
                            .lineLimit(2)
                        Text(item.1)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.black.opacity(0.55))
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
            }
        }
    }
}

private enum YoutubePool {
    static let videoTitles: [String] = [
        "5분 안에 끝내는 SwiftUI 입문",
        "한강 야경 풀버전 4K",
        "2026 신차 리뷰 TOP10",
        "백종원 김치찌개 황금레시피",
        "초보도 따라하는 홈트 30분",
        "강남 맛집 베스트 5",
        "iPhone 18 첫인상",
        "직장인 재테크 입문",
        "ChatGPT 200% 활용법",
        "제주도 3박4일 브이로그",
        "주식 차트 분석 기초",
        "코딩 부트캠프 후기",
        "한국 드라마 다시보기",
        "맛있는 라면 끓이는 법"
    ]
    static let channels: [String] = [
        "테크유튜브", "쿠킹채널", "여행로그",
        "주식의신", "코딩하는개발자", "헬스코치김",
        "드림채널", "리뷰랩"
    ]
}

// MARK: - Shared Link Card (KakaoTalk-style)

public struct SharedLinkCardGenerator: MockGenerator {
    public let code: CategoryCode = .linkSharedLinkCard
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(SharedLinkCardView(seed: seed))
    }
}

struct SharedLinkCardView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let sender = rng.pick(["지영", "민수", "엄마", "팀장님", "현주", "수민", "지훈"])
        let title = rng.pick(SafariPool.articleTitles)
        let desc = rng.pick(SafariPool.subheads)
        let url = rng.pick(SafariPool.urls)

        return VStack(spacing: 0) {
            statusBar
            navBar
            chatBody(sender: sender, title: title, desc: desc, url: url)
            inputBar
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
        .background(KakaoChatColors.bg)
    }

    private var navBar: some View {
        HStack {
            Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
            Spacer()
            Text("지영").font(.system(size: 17, weight: .semibold))
            Spacer()
            Image(systemName: "line.3.horizontal").font(.system(size: 17, weight: .semibold))
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(KakaoChatColors.bg)
    }

    private func chatBody(sender: String, title: String, desc: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer().frame(height: 20)
            HStack(alignment: .top, spacing: 8) {
                Circle().fill(Color(white: 0.78)).frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text(sender)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.black.opacity(0.7))
                    linkCard(title: title, desc: desc, url: url)
                }
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 12)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(KakaoChatColors.bg)
    }

    private func linkCard(title: String, desc: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(white: 0.78))
                .frame(width: 240, height: 120)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.black)
                    .lineLimit(2)
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.black.opacity(0.6))
                    .lineLimit(1)
                Text(url)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.black.opacity(0.45))
                    .lineLimit(1)
            }
            .padding(10)
            .frame(width: 240, alignment: .leading)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(white: 0.95))
                .frame(height: 36)
            Image(systemName: "face.smiling")
            Image(systemName: "mic.fill")
        }
        .font(.system(size: 18))
        .foregroundStyle(Color.black.opacity(0.6))
        .padding(.horizontal, 14)
        .frame(height: 64)
        .background(Color.white)
    }
}

private enum KakaoChatColors {
    static let bg = Color(red: 0xB2/255.0, green: 0xC7/255.0, blue: 0xDA/255.0)
}
