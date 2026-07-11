//  Copyright © 2022 Polar. All rights reserved.

import XCTest
@testable import iOSCommunications

final class TypeUtilsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testArrayConversionToSignedIntMaxValue() throws {
        // Arrange
        let byteArray = Data([0xFF, 0xFF, 0xFF, 0xFF])
        let expectedValue:Int32 = -1

        // Act
        let result = TypeUtils.convertArrayToSignedInt(byteArray)

        // Assert
        XCTAssertEqual(expectedValue, result)
    }
    
    func testArrayConversionToSignedIntMinValue() throws {
        // Arrange
        let byteArray = Data([0x00, 0x00, 0x00, 0x00])
        let expectedValue:Int32 = 0

        // Act
        let result = TypeUtils.convertArrayToSignedInt(byteArray)

        // Assert
        XCTAssertEqual(expectedValue, result)
    }
    
    func testArrayConversionToSignedIntMaxPositiveInt() throws {
        // Arrange
        let byteArray = Data([0xFF, 0xFF, 0xFF, 0x7F])
        let expectedValue = Int32.max

        // Act
        let result = TypeUtils.convertArrayToSignedInt(byteArray)

        // Assert
        XCTAssertEqual(expectedValue, result)
    }

    func testArrayConversionToSignedIntSmallArray() throws {
        // Arrange
        let byteArray = Data([0xFF])
        let expectedValue:Int32 = -1

        // Act
        let result = TypeUtils.convertArrayToSignedInt(byteArray)

        // Assert
        XCTAssertEqual(expectedValue, result)
    }

    // MARK: - convertArrayToUnsignedInt (little-endian, no sign extension)
    //
    // Regression coverage for the offline-recording import crash: the previous
    // implementation sign-extended, so any 2-byte value with the top bit set
    // (>= 0x8000) became a huge UInt and OfflineRecordingData.parsePacketSize()'s
    // Int(...) wrapper trapped with "Not enough bits to represent the passed value".
    // These assert the plain little-endian value, matching the Android SDK.

    func testArrayConversionToUnsignedIntZero() throws {
        XCTAssertEqual(0, TypeUtils.convertArrayToUnsignedInt(Data([0x00, 0x00])))
    }

    func testArrayConversionToUnsignedIntBelowSignBoundary() throws {
        // 0x7FFF little-endian == 32767, the largest value the old code handled.
        XCTAssertEqual(32767, TypeUtils.convertArrayToUnsignedInt(Data([0xFF, 0x7F])))
    }

    func testArrayConversionToUnsignedIntAtSignBoundary() throws {
        // 0x8000 little-endian == 32768. The old sign-extending code returned
        // ~0xFFFF_FFFF_FFFF_8000 here, which then trapped in Int(...). This is
        // the exact packet size that crashed the import.
        XCTAssertEqual(32768, TypeUtils.convertArrayToUnsignedInt(Data([0x00, 0x80])))
    }

    func testArrayConversionToUnsignedIntMaxTwoBytes() throws {
        // 0xFFFF little-endian == 65535, the largest 2-byte packet size.
        XCTAssertEqual(65535, TypeUtils.convertArrayToUnsignedInt(Data([0xFF, 0xFF])))
    }

    func testArrayConversionToUnsignedIntFourByteHeaderMagic() throws {
        // The offline-recording header magic 0x3D7C4C2B, stored little-endian.
        let magic = Data([0x2B, 0x4C, 0x7C, 0x3D])
        XCTAssertEqual(0x3D7C4C2B, TypeUtils.convertArrayToUnsignedInt(magic))
    }

    func testArrayConversionToUnsignedIntOffsetSizeOverload() throws {
        // The (offset:size:) overload delegates to the same function; make sure
        // it slices correctly and is likewise free of sign extension.
        let buffer = Data([0xAA, 0x00, 0x80, 0xBB])
        XCTAssertEqual(32768, TypeUtils.convertArrayToUnsignedInt(buffer, offset: 1, size: 2))
    }
}
