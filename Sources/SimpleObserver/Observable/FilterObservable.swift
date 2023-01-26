public class FilterObservable<Upstream>: Observable where Upstream: Observable {
    public typealias Output = Upstream.Output
    
    private let include: (Upstream.Output) -> Bool
    private let upstream: Upstream
    
    public init(upstream: Upstream, include: @escaping (Upstream.Output) -> Bool) {
        self.upstream = upstream
        self.include = include
    }
    
    public func observe(_ action: @escaping (Output) -> Void) -> Cancelable {
        upstream.observe { [include] output in
            if include(output) {
                action(output)
            }
        }
    }
}

public extension Observable {
    func filter(_ include: @escaping (Self.Output) -> Bool) -> FilterObservable<Self> {
        FilterObservable(upstream: self, include: include)
    }
}
