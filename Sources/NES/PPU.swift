extension Emulator {
    mutating func ppuRegisterClear() {
        nes.ppu.controller = []
        nes.ppu.mask = []
        nes.ppu.status = []
        nes.ppu.data = 0x00
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

extension NES {
    mutating func readPPURegister<M: MemoryMap>(from address: UInt16, by: M.Type) -> UInt8 {
        var result: UInt8

        switch address {
        case 0x2002:
            result = ppu.readStatus() | (ppu.internalDataBus & 0b11111)
            // Race Condition
            if ppu.scan.line == startVerticalBlank && ppu.scan.dot < 2 {
                result &= ~0x80
            }
        case 0x2004:
            // https://wiki.nesdev.com/w/index.php/PPU_sprite_evaluation
            if ppu.scan.line < 240 && 1 <= ppu.scan.dot && ppu.scan.dot <= 64 {
                // during sprite evaluation
                result = 0xFF
            } else {
                result = ppu.primaryOAM[Int(ppu.objectAttributeMemoryAddress)]
            }
        case 0x2007:
            if ppu.v <= 0x3EFF {
                result = ppu.data
                ppu.data = M.ppuRead(at: ppu.v, from: &self)
            } else {
                result = M.ppuRead(at: ppu.v, from: &self)
            }
            ppu.incrV()
        default:
            result = 0x00
        }

        ppu.internalDataBus = result
        return result
    }

    mutating func writePPURegister<M: MemoryMap>(_ value: UInt8, to address: UInt16, by: M.Type) {
        switch address {
        case 0x2000:
            ppu.writeController(value)
        case 0x2001:
            ppu.mask = PPUMask(rawValue: value)
        case 0x2003:
            ppu.objectAttributeMemoryAddress = value
        case 0x2004:
            ppu.primaryOAM[Int(ppu.objectAttributeMemoryAddress)] = value
            ppu.objectAttributeMemoryAddress &+= 1
        case 0x2005:
            ppu.writeScroll(position: value)
        case 0x2006:
            ppu.writeVRAMAddress(addr: value)
        case 0x2007:
            M.ppuWrite(value, at: ppu.v, to: &self)
            ppu.incrV()
        default:
            break
        // NOP
        }
    }
}

extension Emulator {
    mutating func ppuStep() {
        switch scan.line {
        case 261:
            // Pre Render
            defer {
                if scan.dot == 1 {
                    nes.ppu.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
                }
                if scan.dot == 341 && nes.ppu.renderingEnabled && currentFrames.isOdd {
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
                nes.ppu.status.formUnion(.vblank)
                if nes.ppu.controller.contains(.nmi) {
                    sendInterrupt(.NMI)
                }
            }
        default:
            break
        }
    }

    mutating func renderPixel() {
        let x = scan.dot &- 2

        let bg = getBackgroundPixel(x: x)
        let sprite = getSpritePixel(x: x, background: bg)

        if nes.ppu.renderingEnabled {
            fetchBackgroundPixel()
            fetchSpritePixel()
        }

        guard scan.line < maxLine && 0 <= x && x < width else {
            return
        }

        let pixel = nes.ppu.renderingEnabled ? selectPixel(bg: bg, sprite: sprite) : 0
        lineBuffer.write(pixel, bg.color, sprite.color, at: x)
    }

    mutating func selectPixel(bg: BackgroundPixel, sprite: SpritePixel) -> Int {
        switch (bg.enabled, sprite.enabled) {
        case (false, false):
            return Int(M.ppuRead(at: 0x3F00, from: &nes))
        case (false, true):
            return sprite.color
        case (true, false):
            return bg.color
        case (true, true):
            return sprite.priority ? bg.color : sprite.color
        }
    }

    // swiftlint:disable cyclomatic_complexity
    mutating func fetchBackgroundPixel() {
        switch scan.dot {
        case 321:
            // No reload shift
            nes.ppu.bgTempAddr = nameTableFirst | nes.ppu.v.nameTableAddressIndex
        case 1...255, 322...336:
            switch scan.dot % 8 {
            case 1:
                // Fetch nametable byte : step 1
                nes.ppu.bgTempAddr = nameTableFirst | nes.ppu.v.nameTableAddressIndex
                nes.ppu.tile.reload(for: nes.ppu.nextPattern, with: nes.ppu.attrTableEntry)
            case 2:
                // Fetch nametable byte : step 2
                nes.ppu.nameTableEntry = M.ppuRead(at: nes.ppu.bgTempAddr, from: &nes)
            case 3:
                // Fetch attribute table byte : step 1
                nes.ppu.bgTempAddr = attributeTableFirst | nes.ppu.v.attributeAddressIndex
            case 4:
                // Fetch attribute table byte : step 2
                nes.ppu.attrTableEntry = M.ppuRead(at: nes.ppu.bgTempAddr, from: &nes)
                // select area
                if nes.ppu.v.coarseXScroll[1] == 1 {
                    nes.ppu.attrTableEntry &>>= 2
                }
                if nes.ppu.v.coarseYScroll[1] == 1 {
                    nes.ppu.attrTableEntry &>>= 4
                }
            case 5:
                // Fetch tile bitmap low byte : step 1
                let base: UInt16 = nes.ppu.controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
                let index = nes.ppu.nameTableEntry.u16 &* tileHeight &* 2
                nes.ppu.bgTempAddr = base &+ index &+ nes.ppu.v.fineYScroll.u16
            case 6:
                // Fetch tile bitmap low byte : step 2
                nes.ppu.nextPattern.low = M.ppuRead(at: nes.ppu.bgTempAddr, from: &nes).u16
            case 7:
                // Fetch tile bitmap high byte : step 1
                nes.ppu.bgTempAddr &+= tileHeight
            case 0:
                // Fetch tile bitmap high byte : step 2
                nes.ppu.nextPattern.high = M.ppuRead(at: nes.ppu.bgTempAddr, from: &nes).u16
                if nes.ppu.renderingEnabled {
                    nes.ppu.incrCoarseX()
                }
            default:
                break
            }
        case 256:
            nes.ppu.nextPattern.high = M.ppuRead(at: nes.ppu.bgTempAddr, from: &nes).u16
            if nes.ppu.renderingEnabled {
                nes.ppu.incrY()
            }
        case 257:
            nes.ppu.tile.reload(for: nes.ppu.nextPattern, with: nes.ppu.attrTableEntry)
            if nes.ppu.renderingEnabled {
                nes.ppu.copyX()
            }
        case 280...304:
            if scan.line == 261 && nes.ppu.renderingEnabled {
                nes.ppu.copyY()
            }
        // Unused name table fetches
        case 337, 339:
            nes.ppu.bgTempAddr = nameTableFirst | nes.ppu.v.nameTableAddressIndex
        case 338, 340:
            nes.ppu.nameTableEntry = M.ppuRead(at: nes.ppu.bgTempAddr, from: &nes)
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity
    /// Returns pallete index for fine X
    mutating func getBackgroundPixel(x: Int) -> BackgroundPixel {
        let (pixel, pallete) = nes.ppu.tile[nes.ppu.fineX]

        if (1 <= scan.dot && scan.dot <= 256) || (321 <= scan.dot && scan.dot <= 336) {
            nes.ppu.tile.shift()
        }

        guard nes.ppu.isEnabledBackground(at: x) else {
            return .zero
        }
        return BackgroundPixel(
            enabled: pixel != 0,
            color: Int(M.ppuRead(at: 0x3F00 &+ pallete &* 4 &+ pixel, from: &nes)))
    }

    mutating func fetchSpritePixel() {
        switch scan.dot {
        case 0:
            nes.ppu.secondaryOAM = [UInt8](repeating: 0xFF, count: nes.ppu.secondaryOAM.count)
            nes.ppu.spriteZeroOnLine = false

            // the sprite evaluation phase
            let spriteSize = nes.ppu.controller.contains(.spriteSize) ? 16 : 8
            var n = 0

            let oamIterator = NESIterator(limit: nes.ppu.secondaryOAM.count)
            for i in 0..<spriteCount {
                let first = i &* 4
                let y = nes.ppu.primaryOAM[first]

                if oamIterator.hasNext {
                    let row = scan.line &- Int(nes.ppu.primaryOAM[first])
                    guard 0 <= row && row < spriteSize else {
                        continue
                    }
                    if n == 0 {
                        nes.ppu.spriteZeroOnLine = true
                    }
                    nes.ppu.secondaryOAM[oamIterator] = y
                    nes.ppu.secondaryOAM[oamIterator] = nes.ppu.primaryOAM[first &+ 1]
                    nes.ppu.secondaryOAM[oamIterator] = nes.ppu.primaryOAM[first &+ 2]
                    nes.ppu.secondaryOAM[oamIterator] = nes.ppu.primaryOAM[first &+ 3]
                    n &+= 1
                }
            }
            if spriteLimit <= n && nes.ppu.renderingEnabled {
                nes.ppu.status.formUnion(.spriteOverflow)
            }
        case 257...320:
            // the sprite fetch phase
            let i = (scan.dot &- 257) / 8
            let n = i &* 4
            nes.ppu.sprites[i] = PPUSprite(
                y: nes.ppu.secondaryOAM[n],
                tileIndex: nes.ppu.secondaryOAM[n &+ 1],
                attr: PPUSprite.Attribute(rawValue: nes.ppu.secondaryOAM[n &+ 2]),
                x: nes.ppu.secondaryOAM[n &+ 3]
            )
        default:
            break
        }
    }

    mutating func getSpritePixel(x: Int, background bg: BackgroundPixel) -> SpritePixel {
        guard nes.ppu.isEnabledSprite(at: x) else {
            return .zero
        }

        let y = scan.line
        for (i, sprite) in nes.ppu.sprites.enumerated() {
            guard sprite.valid else {
                break
            }
            guard x &- 7 <= sprite.x && sprite.x <= x else {
                continue
            }

            var row = sprite.row(lineNumber: y, spriteHeight: nes.ppu.spriteSize)
            let col = sprite.col(x: UInt16(x))
            var tileIndex = sprite.tileIndex.u16

            let base: UInt16
            if nes.ppu.controller.sprite8x16pixels {
                tileIndex &= 0xFE
                if 7 < row {
                    tileIndex += 1
                    row -= 8
                }
                base = tileIndex & 1
            } else {
                base = nes.ppu.controller.baseSpriteTableAddr
            }

            let tileAddr = base &+ tileIndex &* 16 &+ row
            let low = M.ppuRead(at: tileAddr, from: &nes)
            let high = M.ppuRead(at: tileAddr &+ 8, from: &nes)

            let pixel = low[col] &+ (high[col] &<< 1)
            if pixel == 0 {  // transparent
                continue
            }

            if i == 0
                && nes.ppu.spriteZeroOnLine
                && nes.ppu.renderingEnabled
                && !nes.ppu.status.contains(.spriteZeroHit)
                && sprite.x != 0xFF && x < 0xFF
                && bg.enabled
            {
                nes.ppu.status.formUnion(.spriteZeroHit)
            }

            return SpritePixel(
                enabled: pixel != 0,
                color: Int(M.ppuRead(at: 0x3F10 &+ sprite.attr.pallete.u16 &* 4 &+ pixel.u16, from: &nes)),
                priority: sprite.attr.contains(.behindBackground))
        }
        return .zero
    }
}

extension NES.PPU {

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

extension BinaryInteger {
    @inline(__always)
    fileprivate var isOdd: Bool { return self.magnitude % 2 != 0 }
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

extension PPUBgTile {
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

extension PPUSprite {
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
