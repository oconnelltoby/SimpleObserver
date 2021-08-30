import Foundation

public protocol DispatchQueuing {
    func asyncAfter(deadline: DispatchTime, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @escaping @convention(block) () -> Void)
}

extension DispatchQueue: DispatchQueuing {}

public class DelayObservable<Upstream, Output>: Observable where Upstream: Observable, Output == Upstream.Output {
    private let upstream: Upstream
    private let execute: (_ work: @escaping () -> Void) -> Void
    
    public init(
        upstream: Upstream, 
        dispatchQueue: DispatchQueuing,
        deadline: DispatchTime,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = []
    ) {
        self.upstream = upstream
        self.execute = { work in
            dispatchQueue.asyncAfter(deadline: deadline, qos: qos, flags: flags, execute: work)
        }
    }
    
    public func observe(_ action: @escaping (Output) -> Void) -> Cancelable {
        upstream.observe { [execute] output in
            execute {
                action(output)
            }
        }
    }
}

public extension Observable {
    func delay(
        dispatchQueue: DispatchQueuing,
        deadline: DispatchTime,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = []
    ) -> DelayObservable<Self, Output> {
        DelayObservable(upstream: self, dispatchQueue: dispatchQueue, deadline: deadline, qos: qos, flags: flags)
    }
}
