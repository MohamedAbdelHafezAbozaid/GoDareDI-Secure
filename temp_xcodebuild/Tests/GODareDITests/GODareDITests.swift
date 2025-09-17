import XCTest
@testable import GODareDI

final class GODareDITests: XCTestCase {
    func testVersion() throws {
        XCTAssertEqual(godare_version(), 206)
    }
    
    func testInit() throws {
        godare_init()
    }
}
