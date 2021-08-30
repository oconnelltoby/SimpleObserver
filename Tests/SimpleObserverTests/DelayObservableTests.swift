import XCTest
import SimpleObserver

final class DelayObservableTests: XCTestCase {
    private var passthroughSubject: PassthroughSubject<Void>!
    private var mockDispatchQueue: MockDispatchQueue!

    override func setUp() {
        passthroughSubject = PassthroughSubject()
        mockDispatchQueue = MockDispatchQueue { _, _, _, work in
            work()
        }
    }
    
    func testPassthroughOutput() {
        var output: Void?
        
        let cancelable = passthroughSubject
            .delay(dispatchQueue: mockDispatchQueue, deadline: .now())
            .observe {
                output = $0
            }
        
        passthroughSubject.send(())
        XCTAssertNotNil(output)
        
        cancelable.cancel()
    }
    
    func testPassthroughDelayedOutput() {
        var output: Void?
        var delayedWork: (@convention(block) () -> Void)?
        
        mockDispatchQueue.mockAsyncAfter = { _, _, _, work in
            delayedWork = work
        }
        
        let cancelable = passthroughSubject
            .delay(dispatchQueue: mockDispatchQueue, deadline: .now())
            .observe {
                output = $0
            }
        
        passthroughSubject.send(())
        XCTAssertNil(output)
        
        delayedWork?()
        
        XCTAssertNotNil(output)

        cancelable.cancel()
    }
    
    func testQueueDeallocation() {
        weak var weakDispatchQueue: MockDispatchQueue?
        
        do {
            let disatchQueue = MockDispatchQueue { _, _, _, _ in }
            weakDispatchQueue = disatchQueue
            
            _ = passthroughSubject
                .delay(dispatchQueue: disatchQueue, deadline: .now())
            
            XCTAssertNotNil(weakDispatchQueue)
        }
        
        XCTAssertNil(weakDispatchQueue)
    }
}

private class MockDispatchQueue: DispatchQueuing {
    var mockAsyncAfter: (DispatchTime, DispatchQoS, DispatchWorkItemFlags, @escaping @convention(block) () -> Void) -> Void
    
    init(mockAsyncAfter: @escaping (DispatchTime, DispatchQoS, DispatchWorkItemFlags, @escaping @convention(block) () -> Void) -> Void) {
        self.mockAsyncAfter = mockAsyncAfter
    }
    
    func asyncAfter(deadline: DispatchTime, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @escaping @convention(block) () -> Void) {
        mockAsyncAfter(deadline, qos, flags, work)
    }
}
