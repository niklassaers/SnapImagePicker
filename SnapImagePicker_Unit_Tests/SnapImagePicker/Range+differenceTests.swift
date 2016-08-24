import XCTest
@testable import SnapImagePicker

class Range_differenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExpandRangeWithValidNumberShouldExpandRange() {
        let range = 10..<30
        let amount = 5
        let targetRange = range.startIndex - amount..<range.endIndex + amount
        
        XCTAssertEqual(targetRange, expandRange(range, byAmount: amount, withLowerBound: 0, andUpperBound: 100))
    }
    
    func testExpandRangeShouldHitBottomBound() {
        let range = 3..<30
        let amount = 5
        let lowerBound = 0
        let targetRange = lowerBound..<range.endIndex + amount
        
        XCTAssertEqual(targetRange, expandRange(range, byAmount: amount, withLowerBound: lowerBound, andUpperBound: 100))
    }
    
    func testExpandRangeShouldHitUpperBound() {
        let range = 10..<30
        let amount = 5
        let upperBound = 32
        let targetRange = range.startIndex - amount..<upperBound
        
        XCTAssertEqual(targetRange, expandRange(range, byAmount: amount, withLowerBound: 0, andUpperBound: upperBound))
    }
    
    func testExpandRangeShouldHitBothBounds() {
        let range = 3..<30
        let amount = 5
        let lowerBound = 0
        let upperBound = 32
        let targetRange = lowerBound..<upperBound
        
        XCTAssertEqual(targetRange, expandRange(range, byAmount: amount, withLowerBound: lowerBound, andUpperBound: upperBound))
    }
}
