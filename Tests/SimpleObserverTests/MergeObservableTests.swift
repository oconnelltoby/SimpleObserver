import XCTest
import SimpleObserver

final class MergeObservableTests: XCTestCase {
    private var passthroughSubjectA: PassthroughSubject<UUID>!
    private var passthroughSubjectB: PassthroughSubject<UUID>!

    override func setUp() {
        passthroughSubjectA = PassthroughSubject()
        passthroughSubjectB = PassthroughSubject()
    }
        
    func testMergeMergesOutput() {
        var outputs = [UUID]()
        let a = UUID()
        let b = UUID()
        
        let cancelable = passthroughSubjectA
            .merge(passthroughSubjectB)
            .observe {
                outputs.append($0)
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        
        XCTAssertEqual(outputs[0], a)
        XCTAssertEqual(outputs[1], b)

        cancelable.cancel()
    }

    func testActionNotCalledIfCancelled() {
        var outputs = [UUID]()
        let a = UUID()
        let b = UUID()
        
        _ = passthroughSubjectA
            .merge(passthroughSubjectB)
            .observe {
                outputs.append($0)
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        
        XCTAssertTrue(outputs.isEmpty)
    }

    func testActionNotCalledAgainIfCancelled() {
        var outputs = [UUID]()
        let a = UUID()
        let b = UUID()
        
        let cancelable = passthroughSubjectA
            .merge(passthroughSubjectB)
            .observe {
                outputs.append($0)
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        XCTAssertFalse(outputs.isEmpty)
        
        outputs.removeAll()
        cancelable.cancel()
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        XCTAssertTrue(outputs.isEmpty)
    }

    func testSendingBeforeObservingDoesNotCallAction() {
        var outputs = [UUID]()
        let a = UUID()
        let b = UUID()

        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        
        let cancellable = passthroughSubjectA
            .merge(passthroughSubjectB)
            .observe {
                outputs.append($0)
            }
        
        
        XCTAssertTrue(outputs.isEmpty)

        cancellable.cancel()
    }
    
    func testMergeObservableIsDeallocatedWhenNoLongerNeeded() {
        typealias Observable = MergeObservable<PassthroughSubject<UUID>, PassthroughSubject<UUID>>
        weak var weakMergeObservable: Observable?
        var cancelable: Cancelable
        do {
            let mergeObservable = passthroughSubjectA
                .merge(passthroughSubjectB)

            cancelable = mergeObservable
                .observe { _ in }

            weakMergeObservable = mergeObservable
        }

        XCTAssertNil(weakMergeObservable)
        cancelable.cancel()
    }
}
