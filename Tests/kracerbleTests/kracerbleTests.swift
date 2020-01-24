import XCTest
@testable import kracerble

final class kracerbleTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(kracerble().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
