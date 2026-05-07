// Token unit tests. Make sure spec values aren't accidentally drifted.
// Source: docs/design-tokens-spec.md.
import XCTest
@testable import SnapDoCore

final class DesignTokensTests: XCTestCase {

    // MARK: Spacing — 8pt grid (spec §3.1)
    func testSpacingValues() {
        XCTAssertEqual(Spacing.xs,    4)
        XCTAssertEqual(Spacing.sm,    8)
        XCTAssertEqual(Spacing.md,   12)
        XCTAssertEqual(Spacing.lg,   16)
        XCTAssertEqual(Spacing.xl,   24)
        XCTAssertEqual(Spacing.xxl,  32)
        XCTAssertEqual(Spacing.xxxl, 48)
        XCTAssertEqual(Spacing.huge, 64)
    }

    // MARK: Radius (spec §3.2)
    func testRadiusValues() {
        XCTAssertEqual(Radius.xs,  4)
        XCTAssertEqual(Radius.sm,  8)
        XCTAssertEqual(Radius.md, 12)
        XCTAssertEqual(Radius.lg, 16)
        XCTAssertEqual(Radius.xl, 24)
    }

    // MARK: Icon (spec §6.6)
    func testIconSizes() {
        XCTAssertEqual(IconSize.xs,    16)
        XCTAssertEqual(IconSize.sm,    20)
        XCTAssertEqual(IconSize.md,    24)
        XCTAssertEqual(IconSize.lg,    32)
        XCTAssertEqual(IconSize.xl,    40)
        XCTAssertEqual(IconSize.empty, 60)
    }

    // MARK: Stagger (spec §4.2) — 50ms cap at index 5
    func testStaggerCappedAtFive() {
        XCTAssertEqual(sdStagger(index: 0), 0.00)
        XCTAssertEqual(sdStagger(index: 1), 0.05)
        XCTAssertEqual(sdStagger(index: 5), 0.25)
        // Items beyond 5 saturate at 0.25, so item 7 lands with item 6.
        XCTAssertEqual(sdStagger(index: 7), 0.25)
        // Reduced motion zeroes everything.
        XCTAssertEqual(sdStagger(index: 7, reduceMotion: true), 0.0)
    }

    func testCoreVersionPresent() {
        XCTAssertFalse(SnapDoCore.version.isEmpty)
    }
}
