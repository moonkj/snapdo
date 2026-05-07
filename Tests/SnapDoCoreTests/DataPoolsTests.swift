// DataPools sanity tests. Asserts each pool meets minimum size promised in spec §4.1.
// Source: classification spec v1 §3.4–3.7, §4.1 (한국어 사전 200+ 어휘 요건).
import XCTest
@testable import SnapDoCore

final class DataPoolsTests: XCTestCase {

    // MARK: KoreanNames
    func testKoreanNamesSizes() {
        XCTAssertGreaterThanOrEqual(KoreanNames.givenNames.count,    50)
        XCTAssertGreaterThanOrEqual(KoreanNames.familyNames.count,   20)
        XCTAssertGreaterThanOrEqual(KoreanNames.displayLabels.count, 30)
    }

    // MARK: KoreanStores
    func testKoreanStoresSizes() {
        XCTAssertGreaterThanOrEqual(KoreanStores.cafes.count,        10)
        XCTAssertGreaterThanOrEqual(KoreanStores.convenience.count,   5)
        XCTAssertGreaterThanOrEqual(KoreanStores.fastFood.count,     15)
        XCTAssertGreaterThanOrEqual(KoreanStores.restaurants.count,  15)
        XCTAssertGreaterThanOrEqual(KoreanStores.general.count,      15)
        XCTAssertGreaterThanOrEqual(KoreanStores.all.count,          60)
        // Uniqueness sanity check.
        XCTAssertEqual(Set(KoreanStores.all).count, KoreanStores.all.count)
    }

    // MARK: KoreanBanks
    func testKoreanBanksSizes() {
        XCTAssertGreaterThanOrEqual(KoreanBanks.all.count, 8)
    }

    // MARK: KoreanCards
    func testKoreanCardsSizes() {
        XCTAssertGreaterThanOrEqual(KoreanCards.all.count, 5)
    }

    // MARK: KoreanMessages
    func testKoreanMessagesSizes() {
        XCTAssertGreaterThanOrEqual(KoreanMessages.templates.count,  80)
        XCTAssertGreaterThanOrEqual(KoreanMessages.memoLines.count,  30)
        XCTAssertGreaterThanOrEqual(KoreanMessages.imperatives.count, 20)
    }

    // MARK: KoreanPlaces
    func testKoreanPlacesSizes() {
        XCTAssertGreaterThanOrEqual(KoreanPlaces.seoulLandmarks.count,   30)
        XCTAssertGreaterThanOrEqual(KoreanPlaces.addressFragments.count, 20)
    }

    // MARK: KoreanMemos
    func testKoreanMemosSizes() {
        XCTAssertGreaterThanOrEqual(KoreanMemos.titles.count, 25)
    }

    // MARK: KoreanAmounts
    func testKoreanAmountsFormatting() {
        XCTAssertEqual(KoreanAmounts.formatKRW(12_500),   "12,500원")
        XCTAssertEqual(KoreanAmounts.formatKRW(1_234_567), "1,234,567원")

        var rng = SeededRNG(seed: 42)
        let s = KoreanAmounts.amountString(rng: &rng)
        XCTAssertTrue(s.hasSuffix("원"))
    }

    // MARK: KoreanTimestamps
    func testKoreanTimestampsShape() {
        var rng = SeededRNG(seed: 7)
        let chat = KoreanTimestamps.chatTime(rng: &rng)
        XCTAssertTrue(chat.hasPrefix("오전") || chat.hasPrefix("오후"))
        XCTAssertTrue(chat.contains(":"))

        let receipt = KoreanTimestamps.receiptStamp(rng: &rng)
        XCTAssertTrue(receipt.hasPrefix("2026."))
        XCTAssertEqual(receipt.count, 16) // YYYY.MM.DD HH:MM
    }
}
