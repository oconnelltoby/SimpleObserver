public class DeinitCancelable: Cancelable {
    public let cancel: () -> Void
    
    public init(_ cancel: @escaping () -> Void) {
        self.cancel = cancel
    }
    
    deinit {
        cancel()
    }
}
