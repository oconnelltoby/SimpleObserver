public protocol Observable {
    associatedtype Output
    func observe(_ action: @escaping (Output) -> Void) -> Cancelable
}
