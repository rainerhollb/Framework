import XCTest
@testable import Extensions

final class StringExtensionsTests: XCTestCase {
    
    func testUIDeviceModelname() throws {
       XCTAssertTrue(UIDevice.modelName().contains("iPhone") || UIDevice.modelName().contains("iPad") )
    }
   
   let LONG_TESTSTRING = "0123456789012345678901234567890123456789"
   let MODEL_TESTSTRING = "iPhone14,5"
   func testStringExtensionSubstring() throws {
      print("starting testStringExtensionSubstring")
      XCTAssertTrue(LONG_TESTSTRING.subString(from: 0, to: 40).elementsEqual(LONG_TESTSTRING))
      XCTAssertTrue(LONG_TESTSTRING.subString(from: 0, to: 10).elementsEqual("0123456789"))
      XCTAssertTrue(LONG_TESTSTRING.subString(from: 0).elementsEqual(LONG_TESTSTRING))
      
      XCTAssertTrue(MODEL_TESTSTRING.subString(from: 0, toSeparator: ",").elementsEqual("iPhone14"))
      XCTAssertTrue(MODEL_TESTSTRING.subString(previousStartString: "iPhone", toSeparator: ",").elementsEqual("14"))
      // not yet implemented: XCTAssertTrue(MODEL_TESTSTRING.subString(previousStartString: ",").elementsEqual("5"))

      print(LONG_TESTSTRING + ".wrapHardly(10) =")
      print(LONG_TESTSTRING.wrapHardly(charsPerLine: 10))
      XCTAssertTrue(LONG_TESTSTRING.wrapHardly(charsPerLine: 10)
         .elementsEqual("0123456789" + "\n"
                        + "0123456789" + "\n"
                        + "0123456789" + "\n"
                        + "0123456789"))

      print(LONG_TESTSTRING + ".wrapHardly(11) =")
      print(LONG_TESTSTRING.wrapHardly(charsPerLine: 11))
      XCTAssertTrue(LONG_TESTSTRING.wrapHardly(charsPerLine: 11)
         .elementsEqual("01234567890" + "\n"
                        + "12345678901" + "\n"
                        + "23456789012" + "\n"
                        + "3456789"))
      
   }
}
