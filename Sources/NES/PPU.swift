let startVerticalBlank = 241

let nameTableFirst: UInt16 = 0x2000
let attributeTableFirst: UInt16 = 0x23C0
let tileHeight: UInt16 = 8

let spriteCount: Int = 64
let spriteLimit: Int = 8
let oamSize = 4 * spriteCount

let maxDot = 340
let maxLine = 261

let height = 240
let width = 256

struct PPU {
    var registers = PPURegisters()

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

    // http://wiki.nesdev.com/w/index.php/PPU_registers#Ports
    var internalDataBus: UInt8 = 0x00

    let lineBuffer = LineBuffer()

    var interruptLine: InterruptLine

    var readMemory: (UInt16) -> UInt8 = { _ in return 0x00 }
    var writeMemory: (UInt8, UInt16) -> () = { _, _ in }

    var line: Int {
        return scan.line
    }

    mutating func read(at address: UInt16) -> UInt8 {
        var result: UInt8

        switch address {
        case 0x2002:
            result = registers.readStatus() | (internalDataBus & 0b11111)
            // Race Condition
            if scan.line == startVerticalBlank && scan.dot < 2 {
                result &= ~0x80
            }
        case 0x2004:
            // https://wiki.nesdev.com/w/index.php/PPU_sprite_evaluation
            if scan.line < 240 && 1 <= scan.dot && scan.dot <= 64 {
                // during sprite evaluation
                result = 0xFF
            } else {
                result = primaryOAM[Int(registers.objectAttributeMemoryAddress)]
            }
        case 0x2007:
            if registers.v <= 0x3EFF {
                result = registers.data
                registers.data = readMemory(registers.v)
            } else {
                result = readMemory(registers.v)
            }
            registers.incrV()
        default:
            result = 0x00
        }

        internalDataBus = result
        return result
    }

    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x2000:
            registers.writeController(value)
        case 0x2001:
            registers.mask = PPUMask(rawValue: value)
        case 0x2003:
            registers.objectAttributeMemoryAddress = value
        case 0x2004:
            primaryOAM[Int(registers.objectAttributeMemoryAddress)] = value
            registers.objectAttributeMemoryAddress &+= 1
        case 0x2005:
            registers.writeScroll(position: value)
        case 0x2006:
            registers.writeVRAMAddress(addr: value)
        case 0x2007:
            writeMemory(value, registers.v)
            registers.incrV()
        default:
            break
        // NOP
        }
    }
}

public class LineBuffer {
    public var buffer = [UInt32](repeating: 0x00, count: maxDot)
    public var backgroundBuffer = [UInt32](repeating: 0x00, count: maxDot)
    public var spriteBuffer = [UInt32](repeating: 0x00, count: maxDot)

    func clear() {
        buffer = [UInt32](repeating: 0x00, count: maxDot)
        backgroundBuffer = [UInt32](repeating: 0x00, count: maxDot)
        spriteBuffer = [UInt32](repeating: 0x00, count: maxDot)
    }

    func write(_ pixel: Int, _ background: Int, _ sprite: Int, at x: Int) {
        buffer[x] = palletes[pixel]
        backgroundBuffer[x] = palletes[background]
        spriteBuffer[x] = palletes[sprite]
    }
}

extension BinaryInteger {
    @inline(__always)
    fileprivate var isOdd: Bool { return self.magnitude % 2 != 0 }
}

// MARK: Render
extension PPU {

    mutating func step() {
        switch scan.line {
        case 261:
            // Pre Render
            defer {
                if scan.dot == 1 {
                    registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
                }
                if scan.dot == 341 && registers.renderingEnabled && frames.isOdd {
                    // Skip 0 cycle on visible frame
                    scan.skip()
                }
            }

            fallthrough
        case 0...239:
            // Visible
            renderPixel()
        case 240:
            // Post Render
            break
        case startVerticalBlank:
            // begin VBLANK
            if scan.dot == 1 {
                registers.status.formUnion(.vblank)
                if registers.controller.contains(.nmi) {
                    interruptLine.send(.NMI)
                }
            }
        default:
            break
        }

        switch scan.nextDot() {
        case .frame:
            frames += 1
        default:
            break
        }
    }

    mutating func renderPixel() {
        let x = scan.dot &- 2

        let bg = getBackgroundPixel(x: x)
        let sprite = getSpritePixel(x: x, background: bg)

        if registers.renderingEnabled {
            fetchBackgroundPixel()
            fetchSpritePixel()
        }

        guard scan.line < maxLine && 0 <= x && x < width else {
            return
        }

        let pixel = registers.renderingEnabled ? selectPixel(bg: bg, sprite: sprite) : 0
        lineBuffer.write(pixel, bg.color, sprite.color, at: x)
    }

    func selectPixel(bg: BackgroundPixel, sprite: SpritePixel) -> Int {
        switch (bg.enabled, sprite.enabled) {
        case (false, false):
            return Int(readMemory(0x3F00))
        case (false, true):
            return sprite.color
        case (true, false):
            return bg.color
        case (true, true):
            return sprite.priority ? bg.color : sprite.color
        }
    }
}

struct PPURegisters {
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

    mutating func clear() {
        controller = []
        mask = []
        status = []
        data = 0x00
    }

    var spriteSize: Int {
        return controller.contains(.spriteSize) ? 16 : 8
    }

    var renderingEnabled: Bool {
        return mask.contains(.sprite) || mask.contains(.background)
    }

    func isEnabledBackground(at x: Int) -> Bool {
        return mask.contains(.background) && !(x < 8 && !mask.contains(.backgroundLeft))
    }

    func isEnabledSprite(at x: Int) -> Bool {
        return mask.contains(.sprite) && !(x < 8 && !mask.contains(.spriteLeft))
    }

    mutating func incrV() {
        v &+= controller.vramIncrement
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242000_write
    mutating func writeController(_ d: UInt8) {
        controller = PPUController(rawValue: d)
        // t: ...BA.. ........ = d: ......BA
        t = (t & ~0b0001100_00000000) | (controller.nameTableSelect << 10)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242002_read
    mutating func readStatus() -> UInt8 {
        let s = status
        status.remove(.vblank)
        writeToggle = false
        return s.rawValue
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242005_first_write_.28w_is_0.29
    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242005_second_write_.28w_is_1.29
    mutating func writeScroll(position d: UInt8) {
        if !writeToggle {
            // first write
            // t: ....... ...HGFED = d: HGFED...
            // x:              CBA = d: .....CBA
            t = (t & ~0b0000000_00011111) | ((d & 0b11111000).u16 >> 3)
            fineX = d & 0b111
            writeToggle = true
        } else {
            // second write
            // t: CBA..HG FED..... = d: HGFEDCBA
            t = (t & ~0b1110011_11100000) | ((d & 0b111).u16 << 12) | ((d & 0b11111000).u16 << 2)
            writeToggle = false
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242006_first_write_.28w_is_0.29
    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242006_second_write_.28w_is_1.29
    mutating func writeVRAMAddress(addr d: UInt8) {
        if !writeToggle {
            // first write
            // t: .FEDCBA ........ = d: ..FEDCBA
            // t: X...... ........ = 0
            t = (t & ~0b0111111_00000000) | ((d & 0b111111).u16 << 8)
            writeToggle = true
        } else {
            // second write
            // t: ....... HGFEDCBA = d: HGFEDCBA
            // v                   = t
            t = (t & ~0b0000000_11111111) | d.u16
            v = t
            writeToggle = false
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#Coarse_X_increment
    mutating func incrCoarseX() {
        if v.coarseXScroll == 31 {
            v &= ~0b11111  // coarse X = 0
            v ^= 0x0400  // switch horizontal nametable
        } else {
            v &+= 1
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#Y_increment
    mutating func incrY() {
        if v.fineYScroll < 7 {
            v &+= 0x1000
        } else {
            v &= ~0x7000  // fine Y = 0

            var y = v.coarseYScroll
            if y == 29 {
                y = 0
                v ^= 0x0800  // switch vertical nametable
            } else if y == 31 {
                y = 0
            } else {
                y &+= 1
            }

            v = (v & ~0x03E0) | (y &<< 5)
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#At_dot_257_of_each_scanline
    mutating func copyX() {
        // v: ....F.. ...EDCBA = t: ....F.. ...EDCBA
        v = (v & ~0b100_00011111) | (t & 0b100_00011111)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#During_dots_280_to_304_of_the_pre-render_scanline_.28end_of_vblank.29
    mutating func copyY() {
        // v: IHGF.ED CBA..... = t: IHGF.ED CBA.....
        v = (v & ~0b1111011_11100000) | (t & 0b1111011_11100000)
    }

    var backgroundPatternTableAddrBase: UInt16 {
        return controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
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


/// Extensions for VRAM address
///
/// https://wiki.nesdev.com/w/index.php/PPU_scrolling#PPU_internal_registers
///
/// yyy NN YYYYY XXXXX
/// ||| || ||||| +++++-- coarse X scroll
/// ||| || +++++-------- coarse Y scroll
/// ||| ++-------------- nametable select
/// +++----------------- fine Y scroll
extension UInt16 {

    var coarseX: UInt16 {
        return self & 0b11111
    }

    var coarseXScroll: UInt16 {
        return self & 0b11111
    }

    var coarseY: UInt16 {
        return self & 0b11_11100000
    }

    var coarseYScroll: UInt16 {
        return coarseY >> 5
    }

    var fineY: UInt16 {
        return self & 0b1110000_00000000
    }

    var fineYScroll: UInt8 {
        return UInt8((self & 0b1110000_00000000) >> 12)
    }

    var nameTableAddressIndex: UInt16 {
        return self & 0b1111_11111111
    }

    var nameTableSelect: UInt16 {
        return self & 0b1100_00000000
    }

    var nameTableNo: UInt16 {
        return nameTableSelect >> 10
    }

    var descriptionAsVRAMAddress: String {
        return "fY=\(fineYScroll.radix16) NT=\(nameTableNo) cY=\(coarseYScroll) cX=\(coarseXScroll)"
    }
}

/// Tile and attribute fetching
/// https://wiki.nesdev.com/w/index.php/PPU_scrolling#Tile_and_attribute_fetching
///
/// NN 1111 YYY XXX
/// || |||| ||| +++-- high 3 bits of coarse X (x/4)
/// || |||| +++------ high 3 bits of coarse Y (y/4)
/// || ++++---------- attribute offset (960 bytes)
/// ++--------------- nametable select
extension UInt16 {

    var coarseXHigh: UInt16 {
        return (self &>> 2) & 0b000111
    }

    var coarseYHigh: UInt16 {
        return (self &>> 4) & 0b111000
    }

    var attributeAddressIndex: UInt16 {
        return nameTableSelect | coarseYHigh | coarseXHigh
    }

    var descriptionAsVRAMTile: String {
        return "NT=\(nameTableNo) cY=\(coarseYHigh >> 3) cX=\(coarseXHigh)"
    }
}


// MARK: Background
extension PPU {

    struct BackgroundPixel {
        var enabled: Bool
        var color: Int

        static let zero = BackgroundPixel(enabled: false, color: 0x00)
    }

    // swiftlint:disable cyclomatic_complexity
    mutating func fetchBackgroundPixel() {
        switch scan.dot {
        case 321:
            // No reload shift
            bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
        case 1...255, 322...336:
            switch scan.dot % 8 {
            case 1:
                // Fetch nametable byte : step 1
                bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
                tile.reload(for: nextPattern, with: attrTableEntry)
            case 2:
                // Fetch nametable byte : step 2
                nameTableEntry = readMemory(bgTempAddr)
            case 3:
                // Fetch attribute table byte : step 1
                bgTempAddr = attributeTableFirst | registers.v.attributeAddressIndex
            case 4:
                // Fetch attribute table byte : step 2
                attrTableEntry = readMemory(bgTempAddr)
                // select area
                if registers.v.coarseXScroll[1] == 1 {
                    attrTableEntry &>>= 2
                }
                if registers.v.coarseYScroll[1] == 1 {
                    attrTableEntry &>>= 4
                }
            case 5:
                // Fetch tile bitmap low byte : step 1
                let base: UInt16 = registers.controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
                let index = nameTableEntry.u16 &* tileHeight &* 2
                bgTempAddr = base &+ index &+ registers.v.fineYScroll.u16
            case 6:
                // Fetch tile bitmap low byte : step 2
                nextPattern.low = readMemory(bgTempAddr).u16
            case 7:
                // Fetch tile bitmap high byte : step 1
                bgTempAddr &+= tileHeight
            case 0:
                // Fetch tile bitmap high byte : step 2
                nextPattern.high = readMemory(bgTempAddr).u16
                if registers.renderingEnabled {
                    registers.incrCoarseX()
                }
            default:
                break
            }
        case 256:
            nextPattern.high = readMemory(bgTempAddr).u16
            if registers.renderingEnabled {
                registers.incrY()
            }
        case 257:
            tile.reload(for: nextPattern, with: attrTableEntry)
            if registers.renderingEnabled {
                registers.copyX()
            }
        case 280...304:
            if scan.line == 261 && registers.renderingEnabled {
                registers.copyY()
            }
        // Unused name table fetches
        case 337, 339:
            bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
        case 338, 340:
            nameTableEntry = readMemory(bgTempAddr)
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    /// Returns pallete index for fine X
    mutating func getBackgroundPixel(x: Int) -> BackgroundPixel {
        let (pixel, pallete) = tile[registers.fineX]

        if (1 <= scan.dot && scan.dot <= 256) || (321 <= scan.dot && scan.dot <= 336) {
            tile.shift()
        }

        guard registers.isEnabledBackground(at: x) else {
            return .zero
        }
        return BackgroundPixel(
            enabled: pixel != 0,
            color: Int(readMemory(0x3F00 &+ pallete &* 4 &+ pixel)))
    }
}

struct Tile {
    struct Pattern {
        var low: UInt16 = 0x00
        var high: UInt16 = 000

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

//MARK: Sprites

extension PPU {
    struct SpritePixel {
        var enabled: Bool
        var color: Int
        var priority: Bool

        static let zero = SpritePixel(enabled: false, color: 0x00, priority: true)
    }

    mutating func fetchSpritePixel() {
        switch scan.dot {
        case 0:
            secondaryOAM = [UInt8](repeating: 0xFF, count: secondaryOAM.count)
            spriteZeroOnLine = false

            // the sprite evaluation phase
            let spriteSize = registers.controller.contains(.spriteSize) ? 16 : 8
            var n = 0

            let oamIterator = Iter(limit: secondaryOAM.count)
            for i in 0..<spriteCount {
                let first = i &* 4
                let y = primaryOAM[first]

                if oamIterator.hasNext {
                    let row = scan.line &- Int(primaryOAM[first])
                    guard 0 <= row && row < spriteSize else {
                        continue
                    }
                    if n == 0 {
                        spriteZeroOnLine = true
                    }
                    secondaryOAM[oamIterator] = y
                    secondaryOAM[oamIterator] = primaryOAM[first &+ 1]
                    secondaryOAM[oamIterator] = primaryOAM[first &+ 2]
                    secondaryOAM[oamIterator] = primaryOAM[first &+ 3]
                    n &+= 1
                }
            }
            if spriteLimit <= n && registers.renderingEnabled {
                registers.status.formUnion(.spriteOverflow)
            }
        case 257...320:
            // the sprite fetch phase
            let i = (scan.dot &- 257) / 8
            let n = i &* 4
            sprites[i] = Sprite(
                y: secondaryOAM[n],
                tileIndex: secondaryOAM[n &+ 1],
                attr: Sprite.Attribute(rawValue: secondaryOAM[n &+ 2]),
                x: secondaryOAM[n &+ 3]
            )
        default:
            break
        }
    }

    mutating func getSpritePixel(x: Int, background bg: BackgroundPixel) -> SpritePixel {
        guard registers.isEnabledSprite(at: x) else {
            return .zero
        }

        let y = scan.line
        for (i, sprite) in sprites.enumerated() {
            guard sprite.valid else {
                break
            }
            guard x &- 7 <= sprite.x && sprite.x <= x else {
                continue
            }

            var row = sprite.row(lineNumber: y, spriteHeight: registers.spriteSize)
            let col = sprite.col(x: UInt16(x))
            var tileIndex = sprite.tileIndex.u16

            let base: UInt16
            if registers.controller.sprite8x16pixels {
                tileIndex &= 0xFE
                if 7 < row {
                    tileIndex += 1
                    row -= 8
                }
                base = tileIndex & 1
            } else {
                base = registers.controller.baseSpriteTableAddr
            }

            let tileAddr = base &+ tileIndex &* 16 &+ row
            let low = readMemory(tileAddr)
            let high = readMemory(tileAddr &+ 8)

            let pixel = low[col] &+ (high[col] &<< 1)
            if pixel == 0 {  // transparent
                continue
            }

            if i == 0
                && spriteZeroOnLine
                && registers.renderingEnabled
                && !registers.status.contains(.spriteZeroHit)
                && sprite.x != 0xFF && x < 0xFF
                && bg.enabled
            {
                registers.status.formUnion(.spriteZeroHit)
            }

            return SpritePixel(
                enabled: pixel != 0,
                color: Int(readMemory(0x3F10 &+ sprite.attr.pallete.u16 &* 4 &+ pixel.u16)),
                priority: sprite.attr.contains(.behindBackground))
        }
        return .zero
    }
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

final class Iter {
    fileprivate var pointer = 0

    private let limit: Int

    init(limit: Int) {
        self.limit = limit
    }

    @inline(__always)
    var hasNext: Bool {
        return pointer < limit
    }
}

extension Array where Element == UInt8 {

    @inline(__always)
    subscript(iterator: Iter) -> UInt8 {
        get {
            let value = self[iterator.pointer]
            iterator.pointer += 1
            return value
        }
        set {
            self[iterator.pointer] = newValue
            iterator.pointer += 1
        }
    }
}

struct Scan: CustomDebugStringConvertible {
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

    var debugDescription: String {
        return "dot:\(dot), line:\(line)"
    }
}

let palletes: [UInt32] = [
    0x7C7C7C, 0x0000FC, 0x0000BC, 0x4428BC, 0x940084, 0xA80020, 0xA81000, 0x881400,
    0x503000, 0x007800, 0x006800, 0x005800, 0x004058, 0x000000, 0x000000, 0x000000,
    0xBCBCBC, 0x0078F8, 0x0058F8, 0x6844FC, 0xD800CC, 0xE40058, 0xF83800, 0xE45C10,
    0xAC7C00, 0x00B800, 0x00A800, 0x00A844, 0x008888, 0x000000, 0x000000, 0x000000,
    0xF8F8F8, 0x3CBCFC, 0x6888FC, 0x9878F8, 0xF878F8, 0xF85898, 0xF87858, 0xFCA044,
    0xF8B800, 0xB8F818, 0x58D854, 0x58F898, 0x00E8D8, 0x787878, 0x000000, 0x000000,
    0xFCFCFC, 0xA4E4FC, 0xB8B8F8, 0xD8B8F8, 0xF8B8F8, 0xF8A4C0, 0xF0D0B0, 0xFCE0A8,
    0xF8D878, 0xD8F878, 0xB8F8B8, 0xB8F8D8, 0x00FCFC, 0xF8D8F8, 0x000000, 0x000000,
]
