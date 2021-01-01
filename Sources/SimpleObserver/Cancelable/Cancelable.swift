public protocol Cancelable {
    var cancel: () -> Void { get }
}
