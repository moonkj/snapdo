// OtherTodoGenerators — Apple Reminders, checklist text, imperative text mock views.
// Source: classification spec v1 §3.9 (todo.reminders / checklist_text / imperative_text).
// Frame 390×844, deterministic from `seed`.
import SwiftUI

// MARK: - Reminders

public struct RemindersGenerator: MockGenerator {
    public let code: CategoryCode = .todoReminders
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(RemindersView(seed: seed))
    }
}

struct RemindersView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let todayCount = rng.int(in: 2...5)
        let upcomingCount = rng.int(in: 2...5)
        let todayItems: [(String, String)] = (0..<todayCount).map { _ in
            (rng.pick(KoreanMessages.memoLines), rng.pick(ReminderPool.subtitles))
        }
        let upcomingItems: [(String, String)] = (0..<upcomingCount).map { _ in
            (rng.pick(KoreanMessages.memoLines), rng.pick(ReminderPool.subtitles))
        }

        return VStack(spacing: 0) {
            statusBar
            navBar
            list(today: todayItems, upcoming: upcomingItems)
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
    }

    private var navBar: some View {
        HStack {
            Text("미리 알림")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.black)
            Spacer()
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
    }

    private func list(today: [(String, String)],
                      upcoming: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            section(title: "오늘", color: .red, items: today)
            section(title: "예정", color: Color(red: 1.0, green: 0.6, blue: 0.0), items: upcoming)
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func section(title: String, color: Color, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.black.opacity(0.35))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.system(size: 17))
                            .foregroundStyle(Color.black)
                        Text(item.1)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

private enum ReminderPool {
    static let subtitles: [String] = [
        "오늘 오후 3시", "내일 오전 9시", "금요일 오후 6시",
        "오후 8시", "오전 10시", "내일 오후 2시",
        "이번 주 토요일", "다음 주 월요일", "오늘 저녁",
        "내일 까지", "이번 주 금요일"
    ]
}

// MARK: - Checklist Text

public struct ChecklistTextGenerator: MockGenerator {
    public let code: CategoryCode = .todoChecklistText
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(ChecklistTextView(seed: seed))
    }
}

struct ChecklistTextView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let useSquare = rng.bool(0.5)
        let bullet = useSquare ? "☐" : "○"
        let count = rng.int(in: 8...15)
        let items: [String] = (0..<count).map { i in
            // mix memo lines and imperatives
            if i.isMultiple(of: 3) {
                return rng.pick(KoreanMessages.imperatives)
            }
            return rng.pick(KoreanMessages.memoLines)
        }

        return VStack(spacing: 0) {
            statusBar
            list(bullet: bullet, items: items)
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
    }

    private func list(bullet: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, line in
                Text("\(bullet) \(line)")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Imperative Text

public struct ImperativeTextGenerator: MockGenerator {
    public let code: CategoryCode = .todoImperativeText
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(ImperativeTextView(seed: seed))
    }
}

private struct ImperativeLine {
    let text: String
    let size: CGFloat
    let bold: Bool
    let centered: Bool
}

struct ImperativeTextView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let count = rng.int(in: 6...10)
        let lines: [ImperativeLine] = (0..<count).map { _ in
            let combo = rng.bool(0.6)
            let imp = rng.pick(KoreanMessages.imperatives)
            let memo = rng.pick(KoreanMessages.memoLines)
            let text = combo ? "\(memo) - \(imp)" : imp
            let size: CGFloat = [15.0, 17.0, 19.0, 22.0][rng.int(in: 0...3)]
            let bold = rng.bool(0.4)
            let centered = !rng.bool(0.85)
            return ImperativeLine(text: text, size: size, bold: bold, centered: centered)
        }

        return VStack(spacing: 0) {
            statusBar
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line.text)
                        .font(.system(size: line.size, weight: line.bold ? .bold : .regular))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity, alignment: line.centered ? .center : .leading)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
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
    }
}
