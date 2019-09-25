let nameTableFirst: UInt16 = 0x2000
let attributeTableFirst: UInt16 = 0x23C0

let tileHeight: UInt16 = 8

struct Tile {
    var pattern = TilePattern()
    var attribute = PalleteAttribute()

    @inline(__always)
    subscript(x: UInt8) -> (pattern: UInt16, pallete: UInt16) {
        // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
        let patternX = 15 &- x
        let pixel = (pattern.high[patternX] &<< 1) | pattern.low[patternX]

        let attributeX = 7 &- x
        let attr = (attribute.high[attributeX] &<< 1) | attribute.low[attributeX]

        return (pixel, attr.u16)
    }

    @inline(__always)
    mutating func shift() {
        pattern.low &<<= 1
        pattern.high &<<= 1

        attribute.low = (attribute.low &<< 1) | unsafeBitCast(attribute.lowLatch, to: UInt8.self)
        attribute.high = (attribute.high &<< 1) | unsafeBitCast(attribute.highLatch, to: UInt8.self)
    }

    @inline(__always)
    mutating func reload(for next: TilePattern, attribute attrEntry: UInt8) {
        pattern.low = (pattern.low & 0xFF00) | next.low
        pattern.high = (pattern.high & 0xFF00) | next.high
        attribute.lowLatch = attrEntry[0] == 1
        attribute.highLatch = attrEntry[1] == 1
    }
}

struct TilePattern {
    var low: UInt16 = 0x00
    var high: UInt16 = 000

    @inline(__always)
    subscript(n: UInt8) -> UInt16 {
        return (high[n] &<< 1) | low[n]
    }
}

struct PalleteAttribute {
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
