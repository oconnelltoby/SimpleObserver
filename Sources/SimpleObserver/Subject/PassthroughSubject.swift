public class PassthroughSubject<Output>: Subject, Observable {
    public typealias Output = Output
    
    private var bag = Bag<(Output) -> Void>()
    
    public init() {}
    
    public func observe(_ action: @escaping (Output) -> Void) -> Cancelable {
        let key = bag.insert(action)
        return DeinitCancelable { [weak self] in
            self?.bag.remove(key)
        }
    }
    
    public func send(_ value: Output) {
        bag.dictionary.values.forEach { $0(value) }
    }
}
