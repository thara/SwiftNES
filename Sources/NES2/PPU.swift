protocol PPUBus {
    func read(at address: UInt16) -> UInt8
    mutating func write(_: UInt8, at address: UInt16)
}

struct PPU {
    var scan = Scan()
    var currentFrames: UInt = 0

    var lineBuffer = LineBuffer()

    mutating func ppuStep<B: PPUBus>(register: inout PPURegister, memory: inout PPUMemory, bus: inout B, nes: inout NES) {
        switch scan.line {
        case 261:
            // Pre Render
            defer {
                if scan.dot == 1 {
                    register.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
                }
                if scan.dot == 341 && register.renderingEnabled && currentFrames.isOdd {
                    // Skip 0 cycle on visible frame
                    scan.skip()
                }
            }

            fallthrough
        case 0...239:
            // Visible
            renderPixel(register: &register, memory: &memory, bus: &bus)
        case 240:
            // Post Render
            break
        case startVerticalBlank:
            // begin VBLANK
            if scan.dot == 1 {
                register.status.formUnion(.vblank)
                if register.controller.contains(.nmi) {
                    nes.sendInterrupt(.NMI)
                }
            }
        default:
            break
        }
    }

    mutating func renderPixel<B: PPUBus>(register: inout PPURegister, memory: inout PPUMemory, bus: inout B) {
        let x = scan.dot &- 2

        let bg = getBackgroundPixel(x: x, register: &register, memory: &memory, bus: &bus)
        let sprite = getSpritePixel(x: x, background: bg, register: &register, memory: &memory, bus: &bus)

        if register.renderingEnabled {
            fetchBackgroundPixel(register: &register, memory: &memory, bus: &bus)
            fetchSpritePixel(register: &register, memory: &memory, bus: &bus)
        }

        guard scan.line < maxLine && 0 <= x && x < width else {
            return
        }

        let pixel = register.renderingEnabled ? selectPixel(bg: bg, sprite: sprite, bus: &bus) : 0
        lineBuffer.write(pixel, bg.color, sprite.color, at: x)
    }

    mutating func selectPixel<B: PPUBus>(bg: BackgroundPixel, sprite: SpritePixel, bus: inout B) -> Int {
        switch (bg.enabled, sprite.enabled) {
        case (false, false):
            return Int(bus.read(at: 0x3F00))
        case (false, true):
            return sprite.color
        case (true, false):
            return bg.color
        case (true, true):
            return sprite.priority ? bg.color : sprite.color
        }
    }

    // swiftlint:disable cyclomatic_complexity
    mutating func fetchBackgroundPixel<B: PPUBus>(register: inout PPURegister, memory: inout PPUMemory, bus: inout B) {
        switch scan.dot {
        case 321:
            // No reload shift
            memory.bgTempAddr = nameTableFirst | register.v.nameTableAddressIndex
        case 1...255, 322...336:
            switch scan.dot % 8 {
            case 1:
                // Fetch nametable byte : step 1
                memory.bgTempAddr = nameTableFirst | register.v.nameTableAddressIndex
                memory.tile.reload(for: memory.nextPattern, with: memory.attrTableEntry)
            case 2:
                // Fetch nametable byte : step 2
                memory.nameTableEntry = bus.read(at: memory.bgTempAddr)
            case 3:
                // Fetch attribute table byte : step 1
                memory.bgTempAddr = attributeTableFirst | register.v.attributeAddressIndex
            case 4:
                // Fetch attribute table byte : step 2
                memory.attrTableEntry = bus.read(at: memory.bgTempAddr)
                // select area
                if register.v.coarseXScroll[1] == 1 {
                    memory.attrTableEntry &>>= 2
                }
                if register.v.coarseYScroll[1] == 1 {
                    memory.attrTableEntry &>>= 4
                }
            case 5:
                // Fetch tile bitmap low byte : step 1
                let base: UInt16 = register.controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
                let index = memory.nameTableEntry.u16 &* tileHeight &* 2
                memory.bgTempAddr = base &+ index &+ register.v.fineYScroll.u16
            case 6:
                // Fetch tile bitmap low byte : step 2
                memory.nextPattern.low = bus.read(at: memory.bgTempAddr).u16
            case 7:
                // Fetch tile bitmap high byte : step 1
                memory.bgTempAddr &+= tileHeight
            case 0:
                // Fetch tile bitmap high byte : step 2
                memory.nextPattern.high = bus.read(at: memory.bgTempAddr).u16
                if register.renderingEnabled {
                    register.incrCoarseX()
                }
            default:
                break
            }
        case 256:
            memory.nextPattern.high = bus.read(at: memory.bgTempAddr).u16
            if register.renderingEnabled {
                register.incrY()
            }
        case 257:
            memory.tile.reload(for: memory.nextPattern, with: memory.attrTableEntry)
            if register.renderingEnabled {
                register.copyX()
            }
        case 280...304:
            if scan.line == 261 && register.renderingEnabled {
                register.copyY()
            }
        // Unused name table fetches
        case 337, 339:
            memory.bgTempAddr = nameTableFirst | register.v.nameTableAddressIndex
        case 338, 340:
            memory.nameTableEntry = bus.read(at: memory.bgTempAddr)
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity
    /// Returns pallete index for fine X
    mutating func getBackgroundPixel<B: PPUBus>(x: Int, register: inout PPURegister, memory: inout PPUMemory, bus: inout B) -> BackgroundPixel {
        let (pixel, pallete) = memory.tile[register.fineX]

        if (1 <= scan.dot && scan.dot <= 256) || (321 <= scan.dot && scan.dot <= 336) {
            memory.tile.shift()
        }

        guard register.isEnabledBackground(at: x) else {
            return .zero
        }
        return BackgroundPixel(
            enabled: pixel != 0,
            color: Int(bus.read(at: 0x3F00 &+ pallete &* 4 &+ pixel)))
    }

    mutating func fetchSpritePixel<B: PPUBus>(register: inout PPURegister, memory: inout PPUMemory, bus: inout B) {
        switch scan.dot {
        case 0:
            memory.secondaryOAM = [UInt8](repeating: 0xFF, count: memory.secondaryOAM.count)
            memory.spriteZeroOnLine = false

            // the sprite evaluation phase
            let spriteSize = register.controller.contains(.spriteSize) ? 16 : 8
            var n = 0

            let oamIterator = NESIterator(limit: memory.secondaryOAM.count)
            for i in 0..<spriteCount {
                let first = i &* 4
                let y = memory.primaryOAM[first]

                if oamIterator.hasNext {
                    let row = scan.line &- Int(memory.primaryOAM[first])
                    guard 0 <= row && row < spriteSize else {
                        continue
                    }
                    if n == 0 {
                        memory.spriteZeroOnLine = true
                    }
                    memory.secondaryOAM[oamIterator] = y
                    memory.secondaryOAM[oamIterator] = memory.primaryOAM[first &+ 1]
                    memory.secondaryOAM[oamIterator] = memory.primaryOAM[first &+ 2]
                    memory.secondaryOAM[oamIterator] = memory.primaryOAM[first &+ 3]
                    n &+= 1
                }
            }
            if spriteLimit <= n && register.renderingEnabled {
                register.status.formUnion(.spriteOverflow)
            }
        case 257...320:
            // the sprite fetch phase
            let i = (scan.dot &- 257) / 8
            let n = i &* 4
            memory.sprites[i] = PPUMemory.Sprite(
                y: memory.secondaryOAM[n],
                tileIndex: memory.secondaryOAM[n &+ 1],
                attr: PPUMemory.Sprite.Attribute(rawValue: memory.secondaryOAM[n &+ 2]),
                x: memory.secondaryOAM[n &+ 3]
            )
        default:
            break
        }
    }

    mutating func getSpritePixel<B: PPUBus>(x: Int, background bg: BackgroundPixel, register: inout PPURegister, memory: inout PPUMemory, bus: inout B) -> SpritePixel {
        guard register.isEnabledSprite(at: x) else {
            return .zero
        }

        let y = scan.line
        for (i, sprite) in memory.sprites.enumerated() {
            guard sprite.valid else {
                break
            }
            guard x &- 7 <= sprite.x && sprite.x <= x else {
                continue
            }

            var row = sprite.row(lineNumber: y, spriteHeight: register.spriteSize)
            let col = sprite.col(x: UInt16(x))
            var tileIndex = sprite.tileIndex.u16

            let base: UInt16
            if register.controller.sprite8x16pixels {
                tileIndex &= 0xFE
                if 7 < row {
                    tileIndex += 1
                    row -= 8
                }
                base = tileIndex & 1
            } else {
                base = register.controller.baseSpriteTableAddr
            }

            let tileAddr = base &+ tileIndex &* 16 &+ row
            let low = bus.read(at: tileAddr)
            let high = bus.read(at: tileAddr &+ 8)

            let pixel = low[col] &+ (high[col] &<< 1)
            if pixel == 0 {  // transparent
                continue
            }

            if i == 0
                && memory.spriteZeroOnLine
                && register.renderingEnabled
                && !register.status.contains(.spriteZeroHit)
                && sprite.x != 0xFF && x < 0xFF
                && bg.enabled
            {
                register.status.formUnion(.spriteZeroHit)
            }

            return SpritePixel(
                enabled: pixel != 0,
                color: Int(bus.read(at: 0x3F10 &+ sprite.attr.pallete.u16 &* 4 &+ pixel.u16)),
                priority: sprite.attr.contains(.behindBackground))
        }
        return .zero
    }
}

protocol PixelRederer {
    mutating func writePixel(_ pixel: Int, _ background: Int, _ sprite: Int, at x: Int)
}

struct BackgroundPixel {
    var enabled: Bool
    var color: Int

    static let zero = BackgroundPixel(enabled: false, color: 0x00)
}

struct SpritePixel {
    var enabled: Bool
    var color: Int
    var priority: Bool

    static let zero = SpritePixel(enabled: false, color: 0x00, priority: true)
}

public struct LineBuffer {
    public var buffer = [UInt32](repeating: 0x00, count: maxDot)
    public var backgroundBuffer = [UInt32](repeating: 0x00, count: maxDot)
    public var spriteBuffer = [UInt32](repeating: 0x00, count: maxDot)

    mutating func clear() {
        buffer = [UInt32](repeating: 0x00, count: maxDot)
        backgroundBuffer = [UInt32](repeating: 0x00, count: maxDot)
        spriteBuffer = [UInt32](repeating: 0x00, count: maxDot)
    }

    mutating func write(_ pixel: Int, _ background: Int, _ sprite: Int, at x: Int) {
        buffer[x] = palletes[pixel]
        backgroundBuffer[x] = palletes[background]
        spriteBuffer[x] = palletes[sprite]
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

extension PPURegister {

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


extension PPUController {
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

extension PPUMemory.Tile {
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

extension PPUMemory.Sprite {
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

extension BinaryInteger {
    @inline(__always)
    fileprivate var isOdd: Bool { return self.magnitude % 2 != 0 }
}


final class NESIterator {
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
    subscript(iterator: NESIterator) -> UInt8 {
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
