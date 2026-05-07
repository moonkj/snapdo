// OCRReader — Vision text recognition wrapper. Spec §6.1, §6.2.
// Phase E1 implements with VNRecognizeTextRequest, languages ["ko-KR","en-US"],
// recognitionLevel .accurate, customWords from KoreanLexicon.
//
// This file declares the abstract surface; concrete VisionOCRReader lands in Phase E.
import Foundation
import CoreGraphics

public protocol OCRReader: Sendable {
    func read(_ image: CGImage) async throws -> [String]
}

/// No-op for tests; returns empty.
public struct NoOCRReader: OCRReader {
    public init() {}
    public func read(_ image: CGImage) async throws -> [String] { [] }
}

// MARK: - Korean lexicon for VNRecognizeTextRequest.customWords (spec §6.2)

public enum KoreanLexicon {
    public static let payment: [String] = [
        "원", "결제완료", "송금완료", "승인", "취소", "환불",
        "카드", "계좌", "입금", "출금", "이체", "입금완료"
    ]
    public static let cardBrands: [String] = [
        "KB", "국민", "신한", "Shinhan", "삼성", "Samsung",
        "현대", "Hyundai", "우리", "WOORI", "하나", "Hana",
        "Liiv", "M-Card"
    ]
    public static let banksAndPay: [String] = [
        "토스", "Toss", "카카오뱅크", "카카오페이", "카카오톡",
        "네이버페이", "NaverPay", "삼성페이", "Apple Pay"
    ]
    public static let storesPopular: [String] = [
        "스타벅스", "Starbucks", "투썸", "맥도날드",
        "BBQ", "올리브영", "다이소", "GS25", "CU",
        "배민", "쿠팡이츠", "이마트24", "세븐일레븐"
    ]
    public static let messengers: [String] = [
        "카카오톡", "오픈채팅", "단톡", "DM",
        "이모티콘", "선물하기"
    ]
    public static let timeWords: [String] = [
        "오전", "오후", "어제", "오늘", "방금",
        "월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"
    ]

    /// All custom words combined for VNRecognizeTextRequest.customWords.
    public static var all: [String] {
        payment + cardBrands + banksAndPay + storesPopular + messengers + timeWords
    }
}

// MARK: - Keyword classifier (§6.3)

public struct OCRKeywordClassifier: Sendable {
    public init() {}

    /// Returns weighted scores per top category from OCR text. Spec §6.3 weights.
    public func classify(_ ocrText: String) -> [TopCategory: Double] {
        var scores: [TopCategory: Double] = [:]

        // Receipt
        if ocrText.contains("결제완료") || ocrText.contains("승인") {
            scores[.receipt, default: 0] += 0.4
        }
        if ocrText.range(of: #"\d{1,3}(,\d{3})*원"#, options: .regularExpression) != nil {
            scores[.receipt, default: 0] += 0.3
        }
        // Place
        if ocrText.contains("길찾기") || ocrText.contains("도착") || ocrText.contains("위치") {
            scores[.place, default: 0] += 0.3
        }
        // Conversation — chat times + bulk text
        if ocrText.range(of: #"\d{2}:\d{2}"#, options: .regularExpression) != nil
           && ocrText.count > 50 {
            scores[.conversation, default: 0] += 0.2
        }
        // Link
        if ocrText.contains("https://") || ocrText.contains("www.") {
            scores[.link, default: 0] += 0.4
        }
        // Todo
        if ocrText.contains("할 일") || ocrText.contains("잊지말기") || ocrText.contains("해야") {
            scores[.todo, default: 0] += 0.3
        }
        return scores
    }
}
