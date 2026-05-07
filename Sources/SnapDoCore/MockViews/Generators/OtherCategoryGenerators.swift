// OtherCategoryGenerators — negative-class mocks (meme, product, food, scenery, selfie, app-unknown).
// Source: classification spec v1 §3 (other.* sub-patterns; 'not classifiable' negatives).
// Frame 390×844, deterministic from `seed`.
import SwiftUI

// MARK: - Meme

public struct MemeGenerator: MockGenerator {
    public let code: CategoryCode = .otherMeme
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(MemeView(seed: seed))
    }
}

struct MemeView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let top = rng.pick(MemePool.lines)
        let bottom = rng.pick(MemePool.lines)
        let palette = MemePool.palettes[rng.int(in: 0...MemePool.palettes.count - 1)]

        return ZStack {
            LinearGradient(
                colors: [palette.0, palette.1],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack {
                memeText(top)
                    .padding(.top, 70)
                Spacer()
                memeText(bottom)
                    .padding(.bottom, 90)
            }
        }
        .frame(width: 390, height: 844)
    }

    private func memeText(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 38, weight: .black))
            .foregroundStyle(Color.white)
            .multilineTextAlignment(.center)
            .shadow(color: Color.black, radius: 1, x: 2, y: 2)
            .shadow(color: Color.black, radius: 1, x: -2, y: -2)
            .shadow(color: Color.black, radius: 1, x: 2, y: -2)
            .shadow(color: Color.black, radius: 1, x: -2, y: 2)
            .padding(.horizontal, 24)
    }
}

private enum MemePool {
    static let lines: [String] = [
        "나만 어렵나?", "이거 실화냐", "ㅋㅋㅋ", "응 아니야",
        "이게 맞나?", "오늘도 평화롭다", "월요일이 또?", "퇴근하고싶다",
        "맥주 한잔", "주말은 짧다", "야근 그만!", "치맥의 시간",
        "잠이 부족하다", "내가 이걸 왜?", "그건 내알바아니지", "회식거절각",
        "버스 놓침", "지금이라도", "퇴근하면 운동", "내 카드 살려"
    ]
    static let palettes: [(Color, Color)] = [
        (Color(red: 1.0, green: 0.5, blue: 0.5), Color(red: 1.0, green: 0.85, blue: 0.4)),
        (Color(red: 0.4, green: 0.7, blue: 1.0), Color(red: 0.6, green: 0.4, blue: 1.0)),
        (Color(red: 0.2, green: 0.8, blue: 0.6), Color(red: 0.9, green: 0.95, blue: 0.4)),
        (Color(red: 0.2, green: 0.2, blue: 0.3), Color(red: 0.5, green: 0.2, blue: 0.6)),
        (Color(red: 1.0, green: 0.4, blue: 0.7), Color(red: 1.0, green: 0.7, blue: 0.4))
    ]
}

// MARK: - Product Photo

public struct ProductPhotoGenerator: MockGenerator {
    public let code: CategoryCode = .otherProductPhoto
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(ProductPhotoView(seed: seed))
    }
}

struct ProductPhotoView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let bg: Color = rng.bool(0.5) ? Color.white : Color(white: 0.94)
        let prodColor = ProductPool.colors[rng.int(in: 0...ProductPool.colors.count - 1)]
        let brand = rng.pick(ProductPool.brands)
        let price = rng.int(in: 12000...249000)
        let caption = rng.pick(ProductPool.captions)

        return VStack(spacing: 0) {
            ZStack {
                bg
                RoundedRectangle(cornerRadius: 28)
                    .fill(prodColor)
                    .frame(width: 220, height: 280)
                    .shadow(color: Color.black.opacity(0.15), radius: 12, y: 6)
            }
            .frame(height: 520)

            VStack(alignment: .leading, spacing: 8) {
                Text(brand)
                    .font(.system(size: 18, weight: .bold))
                Text("₩\(formatPrice(price))")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.black.opacity(0.7))
                Text(caption)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black.opacity(0.6))
                    .lineLimit(3)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    private func formatPrice(_ p: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: p)) ?? "\(p)"
    }
}

private enum ProductPool {
    static let colors: [Color] = [
        Color(red: 0.95, green: 0.85, blue: 0.7),
        Color(red: 0.4, green: 0.55, blue: 0.7),
        Color(red: 0.2, green: 0.2, blue: 0.25),
        Color(red: 0.85, green: 0.4, blue: 0.4),
        Color(red: 0.6, green: 0.75, blue: 0.6),
        Color(red: 0.95, green: 0.95, blue: 0.95)
    ]
    static let brands: [String] = [
        "MUSE", "노르딕웨어", "아크네", "코스", "유니클로",
        "29CM", "무신사 스탠다드", "마뗑킴"
    ]
    static let captions: [String] = [
        "이번 시즌 인기 아이템 ✨ #신상",
        "데일리룩 추천! 어디에나 잘 어울려요",
        "한정 수량으로 만나보세요",
        "리뷰 평점 4.9 ⭐️",
        "신상 입고 안내 #오오티디"
    ]
}

// MARK: - Food Photo

public struct FoodPhotoGenerator: MockGenerator {
    public let code: CategoryCode = .otherFoodPhoto
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(FoodPhotoView(seed: seed))
    }
}

struct FoodPhotoView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let plateColor = Color(white: rng.double(in: 0.85...0.98))
        let bg = Color(red: rng.double(in: 0.6...0.9),
                       green: rng.double(in: 0.5...0.85),
                       blue: rng.double(in: 0.4...0.7))
        let shapeCount = rng.int(in: 4...8)
        let shapes: [(Color, CGFloat, CGFloat, CGFloat)] = (0..<shapeCount).map { _ in
            let c = Color(red: rng.double(in: 0.3...1.0),
                          green: rng.double(in: 0.2...0.9),
                          blue: rng.double(in: 0.1...0.6))
            return (c,
                    CGFloat(rng.double(in: 30...60)),
                    CGFloat(rng.double(in: -90...90)),
                    CGFloat(rng.double(in: -90...90)))
        }

        return VStack(spacing: 0) {
            ZStack {
                bg
                Circle()
                    .fill(plateColor)
                    .frame(width: 320, height: 320)
                    .shadow(color: Color.black.opacity(0.18), radius: 14, y: 6)
                ForEach(Array(shapes.enumerated()), id: \.offset) { _, item in
                    Circle()
                        .fill(item.0)
                        .frame(width: item.1, height: item.1)
                        .offset(x: item.2, y: item.3)
                }
            }
            .frame(height: 600)

            Text("오늘 점심 #식스타그램")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.black)
                .padding(.top, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
            Spacer(minLength: 0)
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }
}

// MARK: - Scenery

public struct SceneryGenerator: MockGenerator {
    public let code: CategoryCode = .otherScenery
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(SceneryView(seed: seed))
    }
}

struct SceneryView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let showCaption = rng.bool(0.6)
        let caption = rng.pick(["한강에서", "남산에서", "제주도", "부산 광안리", "서울숲", "북악산 근처", "오늘의 풍경"])
        let skyTop = Color(red: rng.double(in: 0.4...0.7),
                           green: rng.double(in: 0.6...0.85),
                           blue: rng.double(in: 0.85...1.0))
        let skyBot = Color(red: rng.double(in: 0.95...1.0),
                           green: rng.double(in: 0.55...0.8),
                           blue: rng.double(in: 0.3...0.55))
        let groundColor = Color(red: rng.double(in: 0.25...0.45),
                                green: rng.double(in: 0.5...0.7),
                                blue: rng.double(in: 0.25...0.4))

        return ZStack {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [skyTop, skyBot],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 540)
                groundColor.frame(height: 304)
            }

            // sun
            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 80, height: 80)
                .offset(x: 90, y: -200)

            if showCaption {
                VStack {
                    Spacer()
                    Text(caption)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.4))
                        )
                        .padding(.bottom, 36)
                }
            }
        }
        .frame(width: 390, height: 844)
    }
}

// MARK: - Selfie / Portrait

public struct SelfiePortraitGenerator: MockGenerator {
    public let code: CategoryCode = .otherSelfiePortrait
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(SelfiePortraitView(seed: seed))
    }
}

struct SelfiePortraitView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let bg = Color(red: rng.double(in: 0.4...0.95),
                       green: rng.double(in: 0.4...0.95),
                       blue: rng.double(in: 0.4...0.95))
        let face = Color(red: rng.double(in: 0.95...1.0),
                         green: rng.double(in: 0.8...0.9),
                         blue: rng.double(in: 0.7...0.8))
        let caption = rng.pick(["오늘의 출근룩 ✨", "기분 좋은 하루 ☀️", "셀카 한 장 📷", "오늘도 화이팅", "주말 무드 🤍"])

        return ZStack {
            bg
            VStack(spacing: 0) {
                Spacer().frame(height: 140)
                ZStack {
                    Ellipse().fill(face).frame(width: 240, height: 300)
                    HStack(spacing: 40) {
                        Circle().fill(Color.black).frame(width: 14, height: 14)
                        Circle().fill(Color.black).frame(width: 14, height: 14)
                    }
                    .offset(y: -20)
                    // smile
                    Path { p in
                        p.addArc(center: CGPoint(x: 120, y: 180),
                                 radius: 40,
                                 startAngle: .degrees(20),
                                 endAngle: .degrees(160),
                                 clockwise: false)
                    }
                    .stroke(Color.black, lineWidth: 4)
                    .frame(width: 240, height: 300)
                }
                Spacer()
                Text(caption)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.4))
                    )
                    .padding(.bottom, 60)
            }
        }
        .frame(width: 390, height: 844)
    }
}

// MARK: - App Unknown

public struct AppUnknownGenerator: MockGenerator {
    public let code: CategoryCode = .otherAppUnknown
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(AppUnknownView(seed: seed))
    }
}

struct AppUnknownView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let isSettingsStyle = rng.bool(0.5)
        let symbols: [String] = (0..<4).map { _ in rng.pick(AppUnknownPool.tabSymbols) }
        let title = rng.pick(AppUnknownPool.titles)
        let settingsRows: [(String, String)] = (0..<8).map { _ in
            (rng.pick(AppUnknownPool.tabSymbols),
             rng.pick(AppUnknownPool.settingsRows))
        }

        return VStack(spacing: 0) {
            statusBar
            navBar(title: title)
            if isSettingsStyle {
                settingsList(rows: settingsRows)
            } else {
                emptyState
            }
            Spacer(minLength: 0)
            tabBar(symbols: symbols)
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
    }

    private func navBar(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.black)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 18))
                .foregroundStyle(Color.black.opacity(0.55))
        }
        .padding(.horizontal, 18)
        .frame(height: 50)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 240)
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundStyle(Color.black.opacity(0.25))
            Text("데이터 없음")
                .font(.system(size: 16))
                .foregroundStyle(Color.black.opacity(0.5))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func settingsList(rows: [(String, String)]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack {
                    Image(systemName: row.0)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.black.opacity(0.6))
                        .frame(width: 28)
                    Text(row.1)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.black.opacity(0.3))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                Divider()
            }
        }
        .padding(.top, 6)
    }

    private func tabBar(symbols: [String]) -> some View {
        HStack {
            ForEach(Array(symbols.enumerated()), id: \.offset) { _, name in
                Spacer()
                Image(systemName: name)
                    .font(.system(size: 22))
                    .foregroundStyle(Color.black.opacity(0.55))
                Spacer()
            }
        }
        .frame(height: 56)
        .background(Color(white: 0.97))
    }
}

private enum AppUnknownPool {
    static let tabSymbols: [String] = [
        "house", "magnifyingglass", "bell", "person",
        "gearshape", "star", "chart.bar", "calendar",
        "envelope", "bookmark", "heart", "folder"
    ]
    static let titles: [String] = [
        "홈", "설정", "내 정보", "알림", "활동",
        "메뉴", "더보기", "마이페이지"
    ]
    static let settingsRows: [String] = [
        "계정", "알림", "개인정보", "언어", "도움말",
        "버전 정보", "데이터 관리", "보안", "테마",
        "백업 및 복원", "약관 및 정책", "로그아웃"
    ]
}
