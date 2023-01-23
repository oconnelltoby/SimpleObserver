public class MergeObservable<A, B>: Observable where A: Observable, B: Observable, A.Output == B.Output {
    private let a: A
    private let b: B

    public init(a: A, b: B) {
        self.a = a
        self.b = b
    }
    
    public func observe(_ action: @escaping (A.Output) -> Void) -> Cancelable {
        let cancelableA = a.observe { output in
            action(output)
        }
        let cancelableB = b.observe { output in
            action(output)
        }
        
        return DeinitCancelable {
            cancelableA.cancel()
            cancelableB.cancel()
        }
    }
}

public extension Observable {
    func merge<Upstream>(_ upstream: Upstream) -> MergeObservable<Self, Upstream> where Upstream: Observable, Upstream.Output == Output {
        MergeObservable(a: self, b: upstream)
    }
}
