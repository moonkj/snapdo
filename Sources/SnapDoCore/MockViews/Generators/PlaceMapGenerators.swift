// PlaceMapGenerators — KakaoMap / NaverMap / Apple Maps / Address-text mock views.
// Source: classification spec v1 §3.7 (place sub-patterns).
// Frame 390×844, deterministic from `seed`.
import SwiftUI

// MARK: - KakaoMap

public struct KakaoMapGenerator: MockGenerator {
    public let code: CategoryCode = .placeKakaomap
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(KakaoMapView(seed: seed))
    }
}

struct KakaoMapView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let useLandmarkSearch = rng.bool(0.5)
        let searchText = useLandmarkSearch ? rng.pick(KoreanPlaces.seoulLandmarks) : "검색하기"
        let labelCount = rng.int(in: 5...10)
        let labels: [(String, CGFloat, CGFloat)] = (0..<labelCount).map { _ in
            (rng.pick(KoreanPlaces.seoulLandmarks),
             CGFloat(rng.double(in: 20...340)),
             CGFloat(rng.double(in: 30...560)))
        }
        let pinCount = rng.int(in: 1...3)
        let pins: [(CGFloat, CGFloat)] = (0..<pinCount).map { _ in
            (CGFloat(rng.double(in: 60...320)),
             CGFloat(rng.double(in: 100...520)))
        }
        let showCard = rng.bool(0.5)
        let storeName = rng.pick(KoreanStores.cafes)
        let distance = rng.int(in: 50...980)

        return VStack(spacing: 0) {
            statusBar
            searchBar(text: searchText)
            mapArea(labels: labels, pins: pins)
                .overlay(alignment: .bottom) {
                    if showCard {
                        bottomCard(name: storeName, distanceM: distance)
                    }
                }
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

    private func searchBar(text: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Color(red: 1.0, green: 0.85, blue: 0.0))
                    .frame(width: 22, height: 22)
                Image(systemName: "mappin")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.black)
            }
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Color.black.opacity(0.6))
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Color.black.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.96, green: 0.96, blue: 0.94))
    }

    private func mapArea(labels: [(String, CGFloat, CGFloat)],
                         pins: [(CGFloat, CGFloat)]) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0xEF/255.0, green: 0xEB/255.0, blue: 0xE0/255.0),
                    Color(red: 0xDC/255.0, green: 0xDC/255.0, blue: 0xD0/255.0)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            // grid lines (streets)
            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    var x: CGFloat = 0
                    while x <= w { p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: h)); x += 48 }
                    var y: CGFloat = 0
                    while y <= h { p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: w, y: y)); y += 64 }
                }
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }

            ForEach(Array(labels.enumerated()), id: \.offset) { _, item in
                Text(item.0)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.black.opacity(0.55))
                    .position(x: item.1, y: item.2)
            }

            ForEach(Array(pins.enumerated()), id: \.offset) { _, pin in
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.red)
                    .position(x: pin.0, y: pin.1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func bottomCard(name: String, distanceM: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name).font(.system(size: 17, weight: .semibold))
            HStack(spacing: 8) {
                Text("카페").font(.system(size: 13)).foregroundStyle(Color.black.opacity(0.55))
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").font(.system(size: 11))
                        .foregroundStyle(Color(red: 1.0, green: 0.78, blue: 0.0))
                    Text("4.5").font(.system(size: 13))
                }
                Text("· \(distanceM)m").font(.system(size: 13)).foregroundStyle(Color.black.opacity(0.55))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            UnevenRoundedRectangle(cornerRadii: .init(
                topLeading: 16, bottomLeading: 0,
                bottomTrailing: 0, topTrailing: 16
            )).fill(Color.white)
        )
    }
}

// MARK: - NaverMap

public struct NaverMapGenerator: MockGenerator {
    public let code: CategoryCode = .placeNavermap
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(NaverMapView(seed: seed))
    }
}

struct NaverMapView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let useLandmarkSearch = rng.bool(0.5)
        let searchText = useLandmarkSearch ? rng.pick(KoreanPlaces.seoulLandmarks) : "검색하기"
        let labelCount = rng.int(in: 5...10)
        let labels: [(String, CGFloat, CGFloat)] = (0..<labelCount).map { _ in
            (rng.pick(KoreanPlaces.seoulLandmarks),
             CGFloat(rng.double(in: 20...340)),
             CGFloat(rng.double(in: 30...560)))
        }
        let pinCount = rng.int(in: 1...3)
        let pins: [(CGFloat, CGFloat)] = (0..<pinCount).map { _ in
            (CGFloat(rng.double(in: 60...320)),
             CGFloat(rng.double(in: 100...520)))
        }

        return VStack(spacing: 0) {
            statusBar
            searchBar(text: searchText)
            mapArea(labels: labels, pins: pins)
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

    private func searchBar(text: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(NaverColors.green)
                    .frame(width: 24, height: 24)
                Text("N")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(Color.white)
            }
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Color.black.opacity(0.6))
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Color.black.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(red: 0.96, green: 0.96, blue: 0.94))
    }

    private func mapArea(labels: [(String, CGFloat, CGFloat)],
                         pins: [(CGFloat, CGFloat)]) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0xEF/255.0, green: 0xEB/255.0, blue: 0xE0/255.0),
                    Color(red: 0xDC/255.0, green: 0xDC/255.0, blue: 0xD0/255.0)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                Path { p in
                    let w = geo.size.width, h = geo.size.height
                    var x: CGFloat = 0
                    while x <= w { p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: h)); x += 48 }
                    var y: CGFloat = 0
                    while y <= h { p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: w, y: y)); y += 64 }
                }
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
            }

            ForEach(Array(labels.enumerated()), id: \.offset) { _, item in
                Text(item.0)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.black.opacity(0.55))
                    .position(x: item.1, y: item.2)
            }

            ForEach(Array(pins.enumerated()), id: \.offset) { _, pin in
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(NaverColors.green)
                    .position(x: pin.0, y: pin.1)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("네이버지도")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.black.opacity(0.4))
                        .padding(6)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private enum NaverColors {
    static let green = Color(red: 0x03/255.0, green: 0xC7/255.0, blue: 0x5A/255.0)
}

// MARK: - Apple Maps

public struct AppleMapsGenerator: MockGenerator {
    public let code: CategoryCode = .placeAppleMaps
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(AppleMapsView(seed: seed))
    }
}

struct AppleMapsView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let labelCount = rng.int(in: 4...8)
        let labels: [(String, CGFloat, CGFloat)] = (0..<labelCount).map { _ in
            (rng.pick(KoreanPlaces.seoulLandmarks),
             CGFloat(rng.double(in: 20...340)),
             CGFloat(rng.double(in: 30...560)))
        }
        let pinX = CGFloat(rng.double(in: 120...260))
        let pinY = CGFloat(rng.double(in: 200...440))

        return VStack(spacing: 0) {
            statusBar
            searchField
            mapArea(labels: labels, pinX: pinX, pinY: pinY)
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

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.5))
            Text("장소 또는 주소 검색")
                .font(.system(size: 15))
                .foregroundStyle(Color.black.opacity(0.5))
            Spacer()
            Image(systemName: "mic.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.92))
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white)
    }

    private func mapArea(labels: [(String, CGFloat, CGFloat)],
                        pinX: CGFloat, pinY: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0xF0/255.0, green: 0xEC/255.0, blue: 0xE0/255.0),
                    Color(red: 0xE2/255.0, green: 0xDD/255.0, blue: 0xCC/255.0)
                ],
                startPoint: .top, endPoint: .bottom
            )

            // diagonal route line
            GeometryReader { geo in
                Path { p in
                    p.move(to: CGPoint(x: 30, y: geo.size.height * 0.85))
                    p.addLine(to: CGPoint(x: geo.size.width - 30, y: geo.size.height * 0.15))
                }
                .stroke(Color(red: 0.0, green: 0.48, blue: 1.0), lineWidth: 5)
            }

            ForEach(Array(labels.enumerated()), id: \.offset) { _, item in
                Text(item.0)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.black.opacity(0.55))
                    .position(x: item.1, y: item.2)
            }

            // Apple-style pin
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(Color.red).frame(width: 28, height: 28)
                    Circle().fill(Color.white).frame(width: 8, height: 8)
                }
                Triangle()
                    .fill(Color.red)
                    .frame(width: 12, height: 10)
            }
            .position(x: pinX, y: pinY)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Address Text (memo style)

public struct AddressTextGenerator: MockGenerator {
    public let code: CategoryCode = .placeAddressText
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(AddressTextView(seed: seed))
    }
}

struct AddressTextView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let landmark = rng.pick(KoreanPlaces.seoulLandmarks)
        let fragment = rng.pick(KoreanPlaces.addressFragments)
        let isMemoStyle = rng.bool(0.4)
        let memoLines: [String] = (0..<4).map { _ in rng.pick(KoreanPlaces.addressFragments) }

        return VStack(spacing: 0) {
            statusBar
            if isMemoStyle {
                memoBody(lines: memoLines)
            } else {
                centeredBody(landmark: landmark, fragment: fragment)
            }
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

    private func centeredBody(landmark: String, fragment: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer().frame(height: 180)
            Text("\(landmark) \(fragment)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("주소 복사")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func memoBody(lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주소 모음")
                .font(.system(size: 24, weight: .bold))
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.black)
            }
            Text("주소 복사")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
