import XCTest
import SimpleObserver

final class FilterObservableTests: XCTestCase {
    private var passthroughSubject: PassthroughSubject<UUID>!

    override func setUp() {
        passthroughSubject = PassthroughSubject()
    }
    
    func testFilterArgumentIsReceived() {
        var argument: UUID?
        let uuid = UUID()
        
        let cancelable = passthroughSubject
            .filter {
                argument = $0
                return true
            }
            .observe { _ in }
        
        
        passthroughSubject.send(uuid)
        XCTAssertEqual(argument, uuid)
        
        cancelable.cancel()
    }
    
    func testFilterTrueProducesOutput() {
        var output: UUID?
        let uuid = UUID()
        
        let cancelable = passthroughSubject
            .filter { _ in true }
            .observe {
                output = $0
            }
        
        
        passthroughSubject.send(uuid)
        XCTAssertEqual(output, uuid)
        
        cancelable.cancel()
    }

    func testFilterFalseDoesNotProducesOutput() {
        var output: UUID?
        let uuid = UUID()
        
        let cancelable = passthroughSubject
            .filter { _ in false }
            .observe {
                output = $0
            }
        
        
        passthroughSubject.send(uuid)
        XCTAssertNil(output)
        
        cancelable.cancel()
    }
    
    func testIncludedNotCalledIfCancelled() {
        var includedCount = 0
        let uuid = UUID()

        let included: (UUID) -> Bool = { _ in
            includedCount += 1
            return true
        }
        
        _ = passthroughSubject
            .filter(included)
            .observe { _ in }
        
        passthroughSubject.send(uuid)
        XCTAssertEqual(includedCount, 0)
    }
    
    func testIncludedNotCalledAgainIfCancelled() {
        var includedCount = 0
        let uuid = UUID()

        let included: (UUID) -> Bool = { _ in
            includedCount += 1
            return true
        }
        
        let cancelable = passthroughSubject
            .filter(included)
            .observe { _ in }
        
        passthroughSubject.send(uuid)
        XCTAssertEqual(includedCount, 1)
        
        cancelable.cancel()
        
        passthroughSubject.send(uuid)
        XCTAssertEqual(includedCount, 1)

        cancelable.cancel()
    }
    
    func testSendingBeforeObservingDoesNotCallIncluded() {
        var includedCount = 0
        let uuid = UUID()

        let included: (UUID) -> Bool = { _ in
            includedCount += 1
            return true
        }

        passthroughSubject.send(uuid)
        
        let cancelable = passthroughSubject
            .filter(included)
            .observe { _ in }
        
        XCTAssertEqual(includedCount, 0)
                
        cancelable.cancel()
    }
    
    func testMultipleSendsCallsIncludedMultipleTimes() {
        var includedCount = 0
        let uuid = UUID()

        let included: (UUID) -> Bool = { _ in
            includedCount += 1
            return true
        }
        
        let cancelable = passthroughSubject
            .filter(included)
            .observe { _ in }
        
        passthroughSubject.send(uuid)
        XCTAssertEqual(includedCount, 1)
                
        passthroughSubject.send(uuid)
        XCTAssertEqual(includedCount, 2)

        cancelable.cancel()
    }
    
    func testTransformCallOrderMatchesSendOrder() {
        let passthroughSubject = PassthroughSubject<Int>()
        
        var values = [Int]()
        
        let included: (Int) -> Bool = {
            values.append($0)
            return true
        }
        
        let cancelable = passthroughSubject
            .filter(included)
            .observe { _ in }
        
        passthroughSubject.send(0)
        XCTAssertEqual(values, [0])

        passthroughSubject.send(1)
        XCTAssertEqual(values, [0, 1])
        
        cancelable.cancel()
    }
    
    func testFilterObservableIsDeallocatedWhenNoLongerNeeded() {
        let passthroughSubject = PassthroughSubject<Void>()
        weak var weakFilterObservable: FilterObservable<PassthroughSubject<Void>>?
        var cancelable: Cancelable
        do {
            let filterObservable = passthroughSubject
                .filter { _ in true  }
            
            cancelable = filterObservable
                .observe { _ in }
            
            weakFilterObservable = filterObservable
        }
        
        XCTAssertNil(weakFilterObservable)
        cancelable.cancel()
    }
    
    func testIncludedIsDeallocatedWhenCanceled() {
        class Object {}
        weak var weakObject: Object?
        
        let passthroughSubject = PassthroughSubject<Void>()
        var cancelable: Cancelable?
        
        autoreleasepool {
            let object = Object()
            
            let filterObservable = passthroughSubject
                .filter {
                    weakObject = object
                    return true
                }
            
            cancelable = filterObservable
                .observe { _ in }
            
            passthroughSubject.send(())
        }
        
        XCTAssertNotNil(weakObject)
        cancelable?.cancel()
        XCTAssertNil(weakObject)
    }
}
