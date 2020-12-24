public let maxDot = 340
public let maxLine = 261

public let height = 240
public let width = 256

let startVerticalBlank = 241

let nameTableFirst: UInt16 = 0x2000
let attributeTableFirst: UInt16 = 0x23C0
let tileHeight: UInt16 = 8

let spriteCount: Int = 64
let spriteLimit: Int = 8
let oamSize = 4 * spriteCount

struct PPURegister {
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

struct PPUMemory {
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

    // http://wiki.nesdev.com/w/index.php/PPU_registers#Ports
    var internalDataBus: UInt8 = 0x00

    var nameTable = [UInt8](repeating: 0x00, count: 0x1000)
    var paletteRAMIndexes = [UInt8](repeating: 0x00, count: 0x0020)

    struct Tile {
        struct Pattern {
            var low: UInt16 = 0x00
            var high: UInt16 = 000
        }
        struct Attribute {
            var low: UInt8 = 0x00
            var high: UInt8 = 0x00

            /// 1 quadrant of attrTableEntry
            var lowLatch: Bool = false
            var highLatch: Bool = false
        }
        var currentPattern = Pattern()
        var currentAttribute = Attribute()
    }

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
    }
}

struct Scan {
    enum Update: Equatable {
        case dot
        case line(lastLine: Int)
        case frame(lastLine: Int)
    }

    var dot: Int = 0
    var line: Int = 0

    mutating func clear() {
        dot = 0
        line = 0
    }

    mutating func skip() {
        dot &+= 1
    }

    mutating func nextDot() -> Update {
        dot &+= 1
        if maxDot <= dot {
            dot %= maxDot

            let last = line

            line &+= 1
            if maxLine < line {
                line = 0
                return .frame(lastLine: last)
            } else {
                return .line(lastLine: last)
            }
        } else {
            return .dot
        }
    }
}
