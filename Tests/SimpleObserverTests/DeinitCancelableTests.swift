import XCTest
@testable import SimpleObserver

final class DeinitCancelableTests: XCTestCase {
    func testCancelCalledOnDeinit() {
        var cancelCalled = false
        _ = DeinitCancelable {
            cancelCalled = true
        }
        XCTAssertTrue(cancelCalled)
    }
    
    func testCancelCancelled() {
        var cancelCalled = false
        let cancelable = DeinitCancelable {
            cancelCalled = true
        }
        XCTAssertFalse(cancelCalled)
        cancelable.cancel()
        XCTAssertTrue(cancelCalled)
    }
}
