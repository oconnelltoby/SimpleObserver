import XCTest
import SimpleObserver

final class CombineLatestObservableTests: XCTestCase {
    private var passthroughSubjectA: PassthroughSubject<UUID>!
    private var passthroughSubjectB: PassthroughSubject<UUID>!

    override func setUp() {
        passthroughSubjectA = PassthroughSubject()
        passthroughSubjectB = PassthroughSubject()
    }
        
    func testCombineLatestCombinesOutput() {
        var output: (a: UUID, b: UUID)?
        let a = UUID()
        let b = UUID()
        
        let cancelable = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
            .observe {
                output = $0
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        
        XCTAssertEqual(output?.a, a)
        XCTAssertEqual(output?.b, b)

        cancelable.cancel()
    }

    func testActionNotCalledIfCancelled() {
        var output: (a: UUID, b: UUID)?
        let a = UUID()
        let b = UUID()
        
        _ = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
            .observe {
                output = $0
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        
        XCTAssertNil(output)
    }

    func testActionNotCalledAgainIfCancelled() {
        var output: (a: UUID, b: UUID)?
        let a = UUID()
        let b = UUID()
        
        let cancelable = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
            .observe {
                output = $0
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        XCTAssertNotNil(output)
        
        output = nil
        cancelable.cancel()
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        XCTAssertNil(output)
    }

    func testSendingBeforeObservingDoesNotCallAction() {
        var output: (a: UUID, b: UUID)?
        let a = UUID()
        let b = UUID()

        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        
        let cancellable = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
            .observe {
                output = $0
            }
        
        
        XCTAssertNil(output)
        
        cancellable.cancel()
    }

    func testNewInputTriggersSameOtherOutput() {
        var output: (a: UUID, b: UUID)?
        let a = UUID()
        let b = UUID()
        let newA = UUID()
        
        let cancelable = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
            .observe {
                output = $0
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        XCTAssertEqual(output?.a, a)
        XCTAssertEqual(output?.b, b)
        
        passthroughSubjectA.send(newA)
        XCTAssertEqual(output?.a, newA)
        XCTAssertEqual(output?.b, b)
        
        cancelable.cancel()
    }

    func testOutputOrderMatchesSendOrder() {
        var output = [(a: UUID, b: UUID)]()
        let a = UUID()
        let b = UUID()
        let newA = UUID()
        let newB = UUID()

        let cancelable = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
            .observe {
                output.append($0)
            }
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        XCTAssertEqual(output[0].a, a)
        XCTAssertEqual(output[0].b, b)
        
        passthroughSubjectA.send(newA)
        passthroughSubjectB.send(newB)
        XCTAssertEqual(output[0].a, a)
        XCTAssertEqual(output[0].b, b)
        XCTAssertEqual(output[1].a, newA)
        XCTAssertEqual(output[1].b, b)
        XCTAssertEqual(output[2].a, newA)
        XCTAssertEqual(output[2].b, newB)
        
        cancelable.cancel()
    }
    
    func testCombineLatestObservableIsDeallocatedWhenNoLongerNeeded() {
        typealias Observable = CombineLatestObservable<PassthroughSubject<UUID>, PassthroughSubject<UUID>>
        weak var weakCombineLatestObservable: Observable?
        var cancelable: Cancelable
        do {
            let combineLatestObservable = passthroughSubjectA
                .combineLatest(passthroughSubjectB)

            cancelable = combineLatestObservable
                .observe { _ in }

            weakCombineLatestObservable = combineLatestObservable
        }

        XCTAssertNil(weakCombineLatestObservable)
        cancelable.cancel()
    }
    
    func testValuesAreNotCachedBeforeObservation() {
        var output: (a: UUID, b: UUID)?
        let a = UUID()
        let b = UUID()
        
        let observable = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
        
        passthroughSubjectA.send(a)
        passthroughSubjectB.send(b)
        
        let cancelable = observable.observe {
            output = $0
        }
        
        XCTAssertNil(output)
        
        cancelable.cancel()
    }
    
    func testNoOutputUntilAllInputsSent() {
        var output: (a: UUID, b: UUID)?
        let a = UUID()
        
        let cancelable = passthroughSubjectA
            .combineLatest(passthroughSubjectB)
            .observe {
                output = $0
            }
        
        passthroughSubjectA.send(a)
        
        XCTAssertNil(output)

        cancelable.cancel()
    }
}
