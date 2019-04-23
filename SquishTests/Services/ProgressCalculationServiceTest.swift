import XCTest
@testable import Squish

class ProgressCalculationServiceTest: XCTestCase {

    let validString32 = "size=     256kB time=00:00:32.57 bitrate=  64.4kbits/s speed=65.1x"
    let validString3632 = "size=     256kB time=01:00:32.57 bitrate=  64.4kbits/s speed=65.1x"
    

    func testCalculation() {
        let result = ProgressCalculationService.call(validString32)
        let result2 = ProgressCalculationService.call(validString3632)
    
        XCTAssert(try! result.get() == 32)
        XCTAssert(try! result2.get() == 3632)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
