extension Bag {
    public struct Key: Hashable {
        let rawValue: UInt64
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
        
        func next() -> Key {
            Key(rawValue: rawValue + 1)
        }
    }
}

public struct Bag<T> {
    private var key = Key(rawValue: 0)
    private(set) var dictionary = [Key: T]()
    private(set) var freedKeys = [Key]()
    
    public init() {}
    
    public mutating func insert(_ element: T) -> Key {
        if let key = freedKeys.popLast() {
            dictionary[key] = element
            return key
        }
        
        defer {
            key = key.next()
        }
        
        dictionary[key] = element
        return key
    }
    
    public mutating func remove(_ key: Key) {
        if dictionary.removeValue(forKey: key) != nil {
            freedKeys.append(key)
        }
    }
}
