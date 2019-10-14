let nameTableFirst: UInt16 = 0x2000
let attributeTableFirst: UInt16 = 0x23C0

let tileHeight: UInt16 = 8

struct Tile {
    var currentPattern = BackgroundTileShiftRegisters()
    var currentAttribute = BackgroundAttributeShiftRegisters()

    @inline(__always)
    subscript(x: UInt8) -> (pattern: UInt16, pallete: UInt16) {
        // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
        let patternX = 15 &- x
        let pixel = (currentPattern.high[patternX] &<< 1) | currentPattern.low[patternX]

        let attributeX = 7 &- x
        let attr = (currentAttribute.high[attributeX] &<< 1) | currentAttribute.low[attributeX]

        return (pixel, attr.u16)
    }

    @inline(__always)
    mutating func shift() {
        currentPattern.low &<<= 1
        currentPattern.high &<<= 1

        currentAttribute.low = (currentAttribute.low &<< 1) | unsafeBitCast(currentAttribute.lowLatch, to: UInt8.self)
        currentAttribute.high = (currentAttribute.high &<< 1) | unsafeBitCast(currentAttribute.highLatch, to: UInt8.self)
    }

    @inline(__always)
    mutating func reload(for next: BackgroundTileShiftRegisters, with nextAttribute: UInt8) {
        currentPattern.low = (currentPattern.low & 0xFF00) | next.low
        currentPattern.high = (currentPattern.high & 0xFF00) | next.high
        currentAttribute.lowLatch = nextAttribute[0] == 1
        currentAttribute.highLatch = nextAttribute[1] == 1
    }
}

struct BackgroundTileShiftRegisters {
    var low: UInt16 = 0x00
    var high: UInt16 = 000

    @inline(__always)
    subscript(n: UInt8) -> UInt16 {
        return (high[n] &<< 1) | low[n]
    }
}

struct BackgroundAttributeShiftRegisters {
    var low: UInt8 = 0x00
    var high: UInt8 = 0x00

    /// 1 quadrant of attrTableEntry
    var lowLatch: Bool = false
    var highLatch: Bool = false

    @inline(__always)
    subscript(n: UInt8) -> UInt8 {
        return (high[n] &<< 1) | low[n]
    }
}
