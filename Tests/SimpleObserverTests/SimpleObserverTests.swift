import XCTest
@testable import SimpleObserver

final class SimpleObserverTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SimpleObserver().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
