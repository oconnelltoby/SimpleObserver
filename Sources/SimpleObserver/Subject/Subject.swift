public protocol Subject {
    associatedtype Output
    func send(_ value: Output)
}
