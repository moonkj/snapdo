// NotesLightGenerator — Apple Notes (light mode) mock view.
// Source: classification spec §3.9 (Apple 메모).
//
// Layout (top → bottom):
//   1. Status bar (47pt) — white bg, black text
//   2. NavBar — white bg, "<" 메모 left, share/more right
//   3. Note body — title 24pt Bold first line, then body 17pt Regular.
//      ~30% of notes are checklists ([ ] ... pattern).
//
// Randomisation:
//   - Title from a small pool of common Korean note headings.
//   - 8-15 lines of body. 30% checklist, 70% free-form.
import SwiftUI

public struct NotesLightGenerator: MockGenerator {
    public let code: CategoryCode = .todoNotesLight

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(NotesLightView(seed: seed, dark: false))
    }
}

public struct NotesDarkGenerator: MockGenerator {
    public let code: CategoryCode = .todoNotesDark
    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(NotesLightView(seed: seed, dark: true))
    }
}

// MARK: - View

struct NotesLightView: View {
    let seed: UInt64
    let dark: Bool

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let title = rng.pick(NotesPool.titles)
        let isChecklist = rng.bool(0.30)
        let lineCount = rng.int(in: 6...12)
        let lines: [String] = (0..<lineCount).map { _ in rng.pick(NotesPool.bodyLines) }
        let timeStr = rng.pick(NotesPool.timestamps)

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            navBar
            noteBody(title: title, lines: lines, isChecklist: isChecklist)
            Spacer(minLength: 0)
        }
        .background(bgColor)
        .foregroundStyle(textColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: components

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time).font(.system(size: 17, weight: .semibold))
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
    }

    private var navBar: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(yellowOrAccent)
                Text("메모")
                    .font(.system(size: 17))
                    .foregroundStyle(yellowOrAccent)
            }
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: "square.and.pencil").foregroundStyle(yellowOrAccent)
                Image(systemName: "ellipsis.circle").foregroundStyle(yellowOrAccent)
            }
            .font(.system(size: 18))
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }

    private func noteBody(title: String, lines: [String], isChecklist: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("작성 \(Calendar.current.component(.month, from: .now))월").font(.system(size: 13))
                .foregroundStyle(secondaryText)

            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                if isChecklist {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Image(systemName: "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(secondaryText)
                        Text(line).font(.system(size: 17))
                    }
                } else {
                    Text(line).font(.system(size: 17))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: colours

    private var bgColor: Color {
        dark ? Color(white: 0.10) : Color.white
    }
    private var textColor: Color {
        dark ? Color.white : Color.black
    }
    private var secondaryText: Color {
        dark ? Color.white.opacity(0.55) : Color.black.opacity(0.45)
    }
    /// Notes uses a yellow tint for actionable controls (chevron, edit, more).
    private var yellowOrAccent: Color {
        Color(red: 0.95, green: 0.74, blue: 0.18)
    }
}

// MARK: - Pool

enum NotesPool {
    static let titles: [String] = [
        "할 일 정리", "쇼핑 목록", "회의 메모", "여행 계획",
        "아이디어", "독서 목록", "주간 회고", "이번 달 목표",
        "새해 다짐", "프로젝트 노트", "운동 루틴", "강의 정리",
        "면접 질문", "연봉 협상", "이사 체크리스트", "결혼 준비"
    ]
    static let bodyLines: [String] = [
        "오전에 운동하기",
        "회의 자료 준비",
        "엄마한테 전화 드리기",
        "냉장고 정리",
        "세탁소 들르기",
        "택배 받기",
        "월세 입금",
        "은행 가서 통장 정리",
        "건강검진 예약",
        "보고서 마감 19일",
        "기획서 초안 작성",
        "팀장님 일정 확인",
        "주말 여행 숙소 알아보기",
        "주차장 등록 갱신",
        "아이 등하원 시간 변경",
        "친구 결혼식 5월 18일",
        "전세 계약 만료 확인",
        "병원 처방전 받기",
        "정수기 필터 교체",
        "가스점검 신청",
        "신용카드 결제일 25일",
        "운전면허 갱신 잊지말기",
        "내일 회식 7시 강남역",
        "온라인 강의 끝까지 듣기",
        "포트폴리오 업데이트",
        "이메일 답장 보내기",
        "집중 시간 2시간 확보",
        "새 책 읽기 시작",
        "자기 전 5분 명상",
        "물 8잔 마시기"
    ]
    static let timestamps: [String] = [
        "9:41", "10:23", "11:07", "12:14", "13:32",
        "14:51", "15:09", "16:28", "17:45", "18:02",
        "19:18", "20:34", "21:50"
    ]
}
