struct PPU {
    /// PPUCTRL
    var controller: PPUController = []
    /// PPUMASK
    var mask: PPUMask = []
    /// PPUSTATUS
    var status: PPUStatus = []
    /// PPUDATA
    var data: UInt8 = 0x00
    /// OAMADDR
    var objectAttributeMemoryAddress: UInt8 = 0x00

    /// current VRAM address
    var v: UInt16 = 0x00
    /// temporary VRAM address
    var t: UInt16 = 0x00
    /// Fine X scroll
    var fineX: UInt8 = 0x00
    var writeToggle: Bool = false

    var nameTable = [UInt8](repeating: 0x00, count: 0x1000)
    var paletteRAMIndexes = [UInt8](repeating: 0x00, count: 0x0020)

    // Background registers
    var nameTableEntry: UInt8 = 0x00
    var attrTableEntry: UInt8 = 0x00
    var bgTempAddr: UInt16 = 0x00

    /// Background tiles
    var tile = Tile()
    var nextPattern = Tile.Pattern()

    // Sprite OAM
    var primaryOAM = [UInt8](repeating: 0x00, count: oamSize)
    var secondaryOAM = [UInt8](repeating: 0x00, count: 32)
    var sprites = [Sprite](repeating: .defaultValue, count: spriteLimit)

    var spriteZeroOnLine = false

    var frames: UInt = 0

    var scan = Scan()
    public var lineBuffer = LineBuffer()

    // http://wiki.nesdev.com/w/index.php/PPU_registers#Ports
    var internalDataBus: UInt8 = 0x00

    var renderingEnabled: Bool {
        return mask.contains(.sprite) || mask.contains(.background)
    }

    mutating func reset() {
        controller = []
        mask = []
        status = []
        data = 0x00

        nameTable.fill(0x00)
        paletteRAMIndexes.fill(0x00)
        scan.clear()
        lineBuffer.clear()
        frames = 0
    }
}

struct PPUController: OptionSet {
    let rawValue: UInt8

    /// NMI
    static let nmi = PPUController(rawValue: 1 << 7)
    /// PPU master/slave (0: master, 1: slave)
    static let slave = PPUController(rawValue: 1 << 6)
    /// Sprite size
    static let spriteSize = PPUController(rawValue: 1 << 5)
    /// Background pattern table address
    static let bgTableAddr = PPUController(rawValue: 1 << 4)
    /// Sprite pattern table address for 8x8 sprites
    static let spriteTableAddr = PPUController(rawValue: 1 << 3)
    /// VRAM address increment
    static let vramAddrIncr = PPUController(rawValue: 1 << 2)
    /// Base nametable address
    static let nameTableAddrHigh = PPUController(rawValue: 1 << 1)
    static let nameTableAddrLow = PPUController(rawValue: 1)

    var nameTableSelect: UInt16 {
        return (rawValue & 0b11).u16
    }

    var bgPatternTableAddrBase: UInt16 {
        return contains(.bgTableAddr) ? 0x1000 : 0x0000
    }

    var baseNameTableAddr: UInt16 {
        switch nameTableSelect {
        case 0:
            return 0x2000
        case 1:
            return 0x2400
        case 2:
            return 0x2800
        case 3:
            return 0x2C00
        default:
            fatalError("PPUController.baseNameTableAddr - unexpected bits: \(nameTableSelect)")
        }
    }

    var baseSpriteTableAddr: UInt16 {
        return contains(.spriteTableAddr) ? 0x1000 : 0x0000
    }

    var sprite8x16pixels: Bool {
        return contains(.spriteSize)
    }

    var vramIncrement: UInt16 {
        return contains(.vramAddrIncr) ? 32 : 1
    }
}

struct PPUMask: OptionSet {
    let rawValue: UInt8

    /// Emphasize blue
    static let blue = PPUMask(rawValue: 1 << 7)
    /// Emphasize green
    static let green = PPUMask(rawValue: 1 << 6)
    /// Emphasize red
    static let red = PPUMask(rawValue: 1 << 5)
    /// Show sprite
    static let sprite = PPUMask(rawValue: 1 << 4)
    /// Show background
    static let background = PPUMask(rawValue: 1 << 3)
    /// Show sprite in leftmost 8 pixels
    static let spriteLeft = PPUMask(rawValue: 1 << 2)
    /// Show background in leftmost 8 pixels
    static let backgroundLeft = PPUMask(rawValue: 1 << 1)
    /// Greyscale
    static let greyscale = PPUMask(rawValue: 1)
}

struct PPUStatus: OptionSet {
    let rawValue: UInt8

    /// In vblank?
    static let vblank = PPUStatus(rawValue: 1 << 7)
    /// Sprite 0 Hit
    static let spriteZeroHit = PPUStatus(rawValue: 1 << 6)
    /// Sprite overflow
    static let spriteOverflow = PPUStatus(rawValue: 1 << 5)
}

let nameTableFirst: UInt16 = 0x2000
let attributeTableFirst: UInt16 = 0x23C0

let tileHeight: UInt16 = 8

struct Tile {
    struct Pattern {
        var low: UInt16 = 0x00
        var high: UInt16 = 000

        //TODO Use protocol extension
        @inline(__always)
        subscript(n: UInt8) -> UInt16 {
            return (high[n] &<< 1) | low[n]
        }
    }
    struct Attribute {
        var low: UInt8 = 0x00
        var high: UInt8 = 0x00
        /// 1 quadrant of attrTableEntry
        var lowLatch: Bool = false
        var highLatch: Bool = false

        //TODO Use protocol extension
        @inline(__always)
        subscript(n: UInt8) -> UInt8 {
            return (high[n] &<< 1) | low[n]
        }
    }

    var currentPattern = Pattern()
    var currentAttribute = Attribute()

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
    mutating func reload(for next: Pattern, with nextAttribute: UInt8) {
        currentPattern.low = (currentPattern.low & 0xFF00) | next.low
        currentPattern.high = (currentPattern.high & 0xFF00) | next.high
        currentAttribute.lowLatch = nextAttribute[0] == 1
        currentAttribute.highLatch = nextAttribute[1] == 1
    }
}

let spriteCount: Int = 64
let spriteLimit: Int = 8
let oamSize = 4 * spriteCount

struct Sprite {
    struct Attribute: OptionSet {
        let rawValue: UInt8

        static let flipVertically = Attribute(rawValue: 1 << 7)
        static let flipHorizontally = Attribute(rawValue: 1 << 6)
        /// Priority
        static let behindBackground = Attribute(rawValue: 1 << 5)

        /// Palette
        static let pallete2 = Attribute(rawValue: 1 << 1)
        static let pallete1 = Attribute(rawValue: 1)

        var pallete: UInt8 {
            return rawValue & 0b11
        }
    }

    /// Y position of top
    let y: UInt8
    /// Tile index number
    let tileIndex: UInt8
    /// Attributes
    let attr: Attribute
    /// X position of left
    let x: UInt8

    static let defaultValue = Sprite(y: 0x00, tileIndex: 0x00, attr: [], x: 0x00)

    var valid: Bool {
        return !(x == 0xFF && y == 0xFF && tileIndex == 0xFF && attr.rawValue == 0xFF)
    }

    func row(lineNumber: Int, spriteHeight: Int) -> UInt16 {
        var row = UInt16(lineNumber) &- y.u16 &- 1
        if attr.contains(.flipVertically) {
            row = UInt16(spriteHeight) &- 1 &- row
        }
        return row
    }

    func col(x: UInt16) -> UInt8 {
        var col = 7 &- (x &- self.x.u16)
        if attr.contains(.flipHorizontally) {
            col = 8 &- 1 &- col
        }
        return UInt8(col)
    }
}
