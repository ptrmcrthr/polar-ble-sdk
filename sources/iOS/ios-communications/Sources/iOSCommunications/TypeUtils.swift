//  Copyright © 2022 Polar. All rights reserved.

import Foundation

class TypeUtils {
    
    static func convertArrayToSignedInt(_ data: Data, offset: Int, size: Int) -> Int32 {
        return convertArrayToSignedInt(data.subdata(in: offset..<(offset+size)))
    }
    
    static func convertArrayToSignedInt(_ data: Data) -> Int32 {
        assert(data.count <= 4)
        var value: Int32 = 0
        memcpy(&value, (data as NSData).bytes, data.count)
        let mask = (Int32.max << ((data.count * 8) - 1))
        if (value & mask) != 0 {
            value |= mask
        }
        return value
    }
    
    static func convertArrayToUnsignedInt(_ data: Data, offset: Int, size: Int) -> UInt {
        return convertArrayToUnsignedInt(data.subdata(in: offset..<(offset+size)))
    }
    
    static func convertArrayToUnsignedInt(_ data: Data) -> UInt {
        assert(data.count <= 4)
        // Plain little-endian assemble with no sign extension, matching the
        // Android SDK, which reads this correctly. The previous implementation
        // was copy-pasted from the signed variant and wrongly sign-extended, so
        // any value of 32768 or greater became a huge UInt that then overflowed
        // the Int(...) conversion in OfflineRecordingData.parsePacketSize().
        return data.reversed().reduce(0) { ($0 << 8) + UInt($1) }
    }

    static func convertArrayToUnsignedInt64(_ data: Data, offset: Int, size: Int) -> UInt64 {
        return convertArrayToUnsignedInt64(data.subdata(in: offset..<(offset+size)))
    }

    static func convertArrayToUnsignedInt64(_ data: Data) -> UInt64 {
        assert(data.count <= 8)
        var value: UInt64 = 0
        value = data.reversed().reduce(0) { $0 << 8 + UInt64($1) }
        return value
    }
}
