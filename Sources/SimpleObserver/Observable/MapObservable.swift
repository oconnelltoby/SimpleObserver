public class MapObservable<Upstream, Output>: Observable where Upstream: Observable {
    private let transform: (Upstream.Output) -> Output
    private let upstream: Upstream
    
    public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
        self.upstream = upstream
        self.transform = transform
    }
    
    public func observe(_ action: @escaping (Output) -> Void) -> Cancelable {
        upstream.observe { [transform] output in
            action(transform(output))
        }
    }
}

public extension Observable {
    func map<Output>(_ transform: @escaping (Self.Output) -> Output) -> MapObservable<Self, Output> {
        MapObservable(upstream: self, transform: transform)
    }
}
