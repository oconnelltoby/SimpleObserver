import XCTest
import SimpleObserver

final class PassthroughSubjectTests: XCTestCase {
    private var passthroughSubject: PassthroughSubject<Void>!
    
    override func setUp() {
        passthroughSubject = PassthroughSubject()
    }
    
    func testActionCalledAfterSend() {
        var actionCalled = false
        let cancelable = passthroughSubject.observe {
            actionCalled = true
        }
        
        passthroughSubject.send(())
        XCTAssertTrue(actionCalled)
        
        cancelable.cancel()
    }
    
    func testActionNotCalledIfCancelled() {
        var actionCalled = false
        _ = passthroughSubject.observe {
            actionCalled = true
        }
        
        passthroughSubject.send(())
        XCTAssertFalse(actionCalled)
    }
    
    func testActionNotCalledAgainIfCancelled() {
        var actionCalled = false
        let cancelable = passthroughSubject.observe {
            actionCalled = true
        }
        
        passthroughSubject.send(())
        XCTAssertTrue(actionCalled)
        
        actionCalled = false
        cancelable.cancel()
        passthroughSubject.send(())
        XCTAssertFalse(actionCalled)
    }
    
    func testSendingBeforeObservingDoesNotCallAction() {
        passthroughSubject.send(())
        
        var actionCalled = false
        let cancelable = passthroughSubject.observe {
            actionCalled = true
        }
        
        XCTAssertFalse(actionCalled)
        
        cancelable.cancel()
    }
    
    func testMultipleSendsCallsActionMultipleTimes() {
        var actionCallCount = 0
        let cancelable = passthroughSubject.observe {
            actionCallCount += 1
        }
        
        XCTAssertEqual(actionCallCount, 0)

        passthroughSubject.send(())
        XCTAssertEqual(actionCallCount, 1)

        passthroughSubject.send(())
        XCTAssertEqual(actionCallCount, 2)
        
        cancelable.cancel()
    }
    
    func testActionCallOrderMatchesSendOrder() {
        let passthroughSubject = PassthroughSubject<Int>()
        
        var values = [Int]()
        let cancelable = passthroughSubject.observe { index in
            values.append(index)
        }
        
        passthroughSubject.send(0)
        XCTAssertEqual(values, [0])

        passthroughSubject.send(1)
        XCTAssertEqual(values, [0, 1])
        
        cancelable.cancel()
    }
}
