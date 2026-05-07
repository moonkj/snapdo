import XCTest
@testable import SnapDoCore

final class SnapDoCoreTests: XCTestCase {
    func testCoreVersionPresent() {
        XCTAssertFalse(SnapDoCore.version.isEmpty)
    }
}
