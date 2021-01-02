public class CombineLatestObservable<A, B>: Observable where A: Observable, B: Observable {
    public typealias Output = (A.Output, B.Output)
    
    private let a: A
    private let b: B

    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
    
    public func observe(_ action: @escaping (Output) -> Void) -> Cancelable {
        var values: (a: A.Output?, b: B.Output?)
        let cancellableA = a.observe { a in
            values.a = a
            guard let b = values.b else { return }
            action((a, b))
        }
        let cancellableB = b.observe { b in
            values.b = b
            guard let a = values.a else { return }
            action((a, b))
        }
        return DeinitCancelable {
            cancellableA.cancel()
            cancellableB.cancel()
        }
    }
}

public extension Observable {
    func combineLatest<Other: Observable>(_ other: Other) -> CombineLatestObservable<Self, Other> {
        CombineLatestObservable(self, other)
    }
}
