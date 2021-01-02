import XCTest
import SimpleObserver

final class MapObservableTests: XCTestCase {
    private var passthroughSubject: PassthroughSubject<Void>!

    override func setUp() {
        passthroughSubject = PassthroughSubject()
    }
    
    func testMapTransformsOutput() {
        var output: UUID?
        let uuid = UUID()
        let transform = { uuid }
        
        let cancelable = passthroughSubject
            .map(transform)
            .observe {
                output = $0
            }
        
        passthroughSubject.send(())
        XCTAssertEqual(output, uuid)
        
        cancelable.cancel()
    }
    
    func testTransformNotCalledIfCancelled() {
        var transformCount = 0
        
        let transform: () -> UUID = {
            transformCount += 1
            return UUID()
        }
        
        _ = passthroughSubject
            .map(transform)
            .observe { _ in }
        
        passthroughSubject.send(())
        XCTAssertEqual(transformCount, 0)
    }
    
    func testTransformNotCalledAgainIfCancelled() {
        var transformCount = 0
        
        let transform: () -> UUID = {
            transformCount += 1
            return UUID()
        }
        
        let cancelable = passthroughSubject
            .map(transform)
            .observe { _ in }
        
        passthroughSubject.send(())
        XCTAssertEqual(transformCount, 1)
        
        cancelable.cancel()
        
        passthroughSubject.send(())
        XCTAssertEqual(transformCount, 1)

        cancelable.cancel()
    }
    
    func testSendingBeforeObservingDoesNotCallTransform() {
        var transformCount = 0
        
        let transform: () -> UUID = {
            transformCount += 1
            return UUID()
        }

        passthroughSubject.send(())
        
        let cancelable = passthroughSubject
            .map(transform)
            .observe { _ in }
        
        XCTAssertEqual(transformCount, 0)
                
        cancelable.cancel()
    }
    
    func testMultipleSendsCallsTransformMultipleTimes() {
        var transformCount = 0
        
        let transform: () -> UUID = {
            transformCount += 1
            return UUID()
        }
        
        let cancelable = passthroughSubject
            .map(transform)
            .observe { _ in }
        
        passthroughSubject.send(())
        XCTAssertEqual(transformCount, 1)
                
        passthroughSubject.send(())
        XCTAssertEqual(transformCount, 2)

        cancelable.cancel()
    }
    
    func testTransformCallOrderMatchesSendOrder() {
        let passthroughSubject = PassthroughSubject<Int>()
        
        var values = [Int]()
        
        let transform: (Int) -> Int = {
            values.append($0)
            return $0
        }
        
        let cancelable = passthroughSubject
            .map(transform)
            .observe { _ in }
        
        passthroughSubject.send(0)
        XCTAssertEqual(values, [0])

        passthroughSubject.send(1)
        XCTAssertEqual(values, [0, 1])
        
        cancelable.cancel()
    }
    
    func testMapObservableIsDeallocatedWhenNoLongerNeeded() {
        let passthroughSubject = PassthroughSubject<Void>()
        weak var weakMapObservable: MapObservable<PassthroughSubject<Void>, Void>?
        var cancelable: Cancelable
        do {
            let mapObservable = passthroughSubject
                .map { _ in  }
            
            cancelable = mapObservable
                .observe { _ in }
            
            weakMapObservable = mapObservable
        }
        
        XCTAssertNil(weakMapObservable)
        cancelable.cancel()
    }
    
    func testTransformIsDeallocatedWhenCanceled() {
        class Object {}
        weak var weakObject: Object?
        
        let passthroughSubject = PassthroughSubject<Void>()
        var cancelable: Cancelable?
        
        autoreleasepool {
            let object = Object()
            
            let mapObservable = passthroughSubject
                .map {
                    weakObject = object
                }
            
            cancelable = mapObservable
                .observe { _ in }
            
            passthroughSubject.send(())
        }
        
        XCTAssertNotNil(weakObject)
        cancelable?.cancel()
        XCTAssertNil(weakObject)
    }
}
