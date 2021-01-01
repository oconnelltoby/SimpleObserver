import XCTest
@testable import SimpleObserver

final class BagTests: XCTestCase {
    var bag: Bag<Void>!
    
    override func setUp() {
        bag = Bag<Void>()
    }
    
    func testFirstInsertionReturnsZerothKey() {
        let key = bag.insert(())
        XCTAssertEqual(key.rawValue, 0)
    }
    
    func testMultipleInsertionsIncrementsKey() {
        (UInt64(0) ..< 100).forEach {
            let key = bag.insert(())
            XCTAssertEqual(key.rawValue, $0)
        }
    }
    
    func testRemovalFreesKey() {
        let key = bag.insert(())
        XCTAssertEqual(bag.freedKeys.count, 0)
        
        bag.remove(key)
        XCTAssertEqual(bag.freedKeys.count, 1)
    }
    
    func testFreedKeyIsUsedAfterRemoval() {
        let firstKey = bag.insert(())
        XCTAssertEqual(bag.freedKeys.count, 0)
        
        bag.remove(firstKey)
        XCTAssertEqual(bag.freedKeys.count, 1)
        
        let secondKey = bag.insert(())
        XCTAssertEqual(bag.freedKeys.count, 0)
        XCTAssertEqual(secondKey.rawValue, firstKey.rawValue)
    }
    
    func testRemovingUnusedKeyDoesNothing() {
        XCTAssertTrue(bag.dictionary.isEmpty)
        XCTAssertTrue(bag.freedKeys.isEmpty)

        let key = Bag<Void>.Key(rawValue: UInt64.random(in: .min ... .max))
        bag.remove(key)
        
        XCTAssertTrue(bag.dictionary.isEmpty)
        XCTAssertTrue(bag.freedKeys.isEmpty)
    }
    
    func testRemovingDuplicateKeyDoesNothing() {
        XCTAssertTrue(bag.dictionary.isEmpty)
        XCTAssertTrue(bag.freedKeys.isEmpty)
        
        let key = bag.insert(())

        bag.remove(key)
        
        XCTAssertTrue(bag.dictionary.isEmpty)
        XCTAssertEqual(bag.freedKeys.count, 1)
        
        bag.remove(key)
        
        XCTAssertTrue(bag.dictionary.isEmpty)
        XCTAssertEqual(bag.freedKeys.count, 1)
    }
    
    func testDictionaryMatchesInsertions() {
        (1 ... 100).forEach {
            _ = bag.insert(())
            XCTAssertEqual(bag.dictionary.count, $0)
        }
    }
    
    func testFreedKeysMathesRemovals() {
        let count = 100
        let keys = (1 ... count).map { _ in
            bag.insert(())
        }
        XCTAssertEqual(bag.dictionary.count, count)
        
        keys.forEach {
            bag.remove($0)
        }
        XCTAssertEqual(bag.dictionary.count, 0)
        XCTAssertEqual(bag.freedKeys.count, count)
    }
}
