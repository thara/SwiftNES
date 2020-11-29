protocol PPU {
    mutating func ppuStep()

    var internalDataBus: UInt8 { get set }
}

protocol PPURegisters {
    var controller: PPUController { get set }
    var mask: PPUMask { get set }
    var status: PPUStatus { get set }
    var data: UInt8 { get set }
    var objectAttributeMemoryAddress: UInt8 { get set }

    var v: UInt16 { get set }
    var t: UInt16 { get set }
    var fineX: UInt8 { get set }
    var writeToggle: Bool { get set }
}

extension PPURegisters {
    mutating func ppuRegisterClear() {
        controller = []
        mask = []
        status = []
        data = 0x00
    }
}

protocol PPUMemory {
    func ppuRead(at address: UInt16) -> UInt8
    mutating func ppuWrite(_ value: UInt8, at address: UInt16)
}

protocol PPUBackground {
    var nameTableEntry: UInt8 { get set }
    var attrTableEntry: UInt8 { get set }
    var bgTempAddr: UInt16 { get set }

    var tile: PPUBgTile { get set }
    var nextPattern: PPUBgTilePattern { get set }
}

protocol PPUSpriteOAM {
    var primaryOAM: [UInt8] { get set }
    var secondaryOAM: [UInt8] { get set }
    var sprites: [PPUSprite] { get set }
    var spriteZeroOnLine: Bool { get set }
}

enum ScanUpdate: Equatable {
    case dot
    case line(lastLine: Int)
    case frame(lastLine: Int)
}

protocol Scanline {
    var currentLine: Int { get set }
    var currentDot: Int { get set }
    var currentFrames: UInt { get set }

    mutating func skipDot()
    mutating func nextDot() -> ScanUpdate
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

//FIXME Separate protocols better
extension PPU where Self: Scanline & PPURegisters & InterruptLine & PixelRederer & PPUMemory & PPUBackground & PPUSpriteOAM {
    mutating func ppuStep() {
        switch currentLine {
        case 261:
            // Pre Render
            defer {
                if currentDot == 1 {
                    status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
                }
                if currentDot == 341 && renderingEnabled && currentFrames.isOdd {
                    // Skip 0 cycle on visible frame
                    skipDot()
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
            if currentDot == 1 {
                status.formUnion(.vblank)
                if controller.contains(.nmi) {
                    sendInterrupt(.NMI)
                }
            }
        default:
            break
        }

        switch nextDot() {
        case .frame:
            currentFrames += 1
        default:
            break
        }
    }

    mutating func renderPixel() {
        let x = currentDot &- 2

        let bg = getBackgroundPixel(x: x)
        let sprite = getSpritePixel(x: x, background: bg)

        if renderingEnabled {
            fetchBackgroundPixel()
            fetchSpritePixel()
        }

        guard currentLine < maxLine && 0 <= x && x < width else {
            return
        }

        let pixel = renderingEnabled ? selectPixel(bg: bg, sprite: sprite) : 0
        writePixel(pixel, bg.color, sprite.color, at: x)
    }

    func selectPixel(bg: BackgroundPixel, sprite: SpritePixel) -> Int {
        switch (bg.enabled, sprite.enabled) {
        case (false, false):
            return Int(ppuRead(at: 0x3F00))
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
        switch currentDot {
        case 321:
            // No reload shift
            bgTempAddr = nameTableFirst | v.nameTableAddressIndex
        case 1...255, 322...336:
            switch currentDot % 8 {
            case 1:
                // Fetch nametable byte : step 1
                bgTempAddr = nameTableFirst | v.nameTableAddressIndex
                tile.reload(for: nextPattern, with: attrTableEntry)
            case 2:
                // Fetch nametable byte : step 2
                nameTableEntry = ppuRead(at: bgTempAddr)
            case 3:
                // Fetch attribute table byte : step 1
                bgTempAddr = attributeTableFirst | v.attributeAddressIndex
            case 4:
                // Fetch attribute table byte : step 2
                attrTableEntry = ppuRead(at: bgTempAddr)
                // select area
                if v.coarseXScroll[1] == 1 {
                    attrTableEntry &>>= 2
                }
                if v.coarseYScroll[1] == 1 {
                    attrTableEntry &>>= 4
                }
            case 5:
                // Fetch tile bitmap low byte : step 1
                let base: UInt16 = controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
                let index = nameTableEntry.u16 &* tileHeight &* 2
                bgTempAddr = base &+ index &+ v.fineYScroll.u16
            case 6:
                // Fetch tile bitmap low byte : step 2
                nextPattern.low = ppuRead(at: bgTempAddr).u16
            case 7:
                // Fetch tile bitmap high byte : step 1
                bgTempAddr &+= tileHeight
            case 0:
                // Fetch tile bitmap high byte : step 2
                nextPattern.high = ppuRead(at: bgTempAddr).u16
                if renderingEnabled {
                    incrCoarseX()
                }
            default:
                break
            }
        case 256:
            nextPattern.high = ppuRead(at: bgTempAddr).u16
            if renderingEnabled {
                incrY()
            }
        case 257:
            tile.reload(for: nextPattern, with: attrTableEntry)
            if renderingEnabled {
                copyX()
            }
        case 280...304:
            if currentLine == 261 && renderingEnabled {
                copyY()
            }
        // Unused name table fetches
        case 337, 339:
            bgTempAddr = nameTableFirst | v.nameTableAddressIndex
        case 338, 340:
            nameTableEntry = ppuRead(at: bgTempAddr)
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    /// Returns pallete index for fine X
    mutating func getBackgroundPixel(x: Int) -> BackgroundPixel {
        let (pixel, pallete) = tile[fineX]

        if (1 <= currentDot && currentDot <= 256) || (321 <= currentDot && currentDot <= 336) {
            tile.shift()
        }

        guard isEnabledBackground(at: x) else {
            return .zero
        }
        return BackgroundPixel(
            enabled: pixel != 0,
            color: Int(ppuRead(at: 0x3F00 &+ pallete &* 4 &+ pixel)))
    }

    mutating func fetchSpritePixel() {
        switch currentDot {
        case 0:
            secondaryOAM = [UInt8](repeating: 0xFF, count: secondaryOAM.count)
            spriteZeroOnLine = false

            // the sprite evaluation phase
            let spriteSize = controller.contains(.spriteSize) ? 16 : 8
            var n = 0

            let oamIterator = NESIterator(limit: secondaryOAM.count)
            for i in 0..<spriteCount {
                let first = i &* 4
                let y = primaryOAM[first]

                if oamIterator.hasNext {
                    let row = currentLine &- Int(primaryOAM[first])
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
            if spriteLimit <= n && renderingEnabled {
                status.formUnion(.spriteOverflow)
            }
        case 257...320:
            // the sprite fetch phase
            let i = (currentDot &- 257) / 8
            let n = i &* 4
            sprites[i] = PPUSprite(
                y: secondaryOAM[n],
                tileIndex: secondaryOAM[n &+ 1],
                attr: PPUSprite.Attribute(rawValue: secondaryOAM[n &+ 2]),
                x: secondaryOAM[n &+ 3]
            )
        default:
            break
        }
    }

    mutating func getSpritePixel(x: Int, background bg: BackgroundPixel) -> SpritePixel {
        guard isEnabledSprite(at: x) else {
            return .zero
        }

        let y = currentLine
        for (i, sprite) in sprites.enumerated() {
            guard sprite.valid else {
                break
            }
            guard x &- 7 <= sprite.x && sprite.x <= x else {
                continue
            }

            var row = sprite.row(lineNumber: y, spriteHeight: spriteSize)
            let col = sprite.col(x: UInt16(x))
            var tileIndex = sprite.tileIndex.u16

            let base: UInt16
            if controller.sprite8x16pixels {
                tileIndex &= 0xFE
                if 7 < row {
                    tileIndex += 1
                    row -= 8
                }
                base = tileIndex & 1
            } else {
                base = controller.baseSpriteTableAddr
            }

            let tileAddr = base &+ tileIndex &* 16 &+ row
            let low = ppuRead(at: tileAddr)
            let high = ppuRead(at: tileAddr &+ 8)

            let pixel = low[col] &+ (high[col] &<< 1)
            if pixel == 0 {  // transparent
                continue
            }

            if i == 0
                && spriteZeroOnLine
                && renderingEnabled
                && !status.contains(.spriteZeroHit)
                && sprite.x != 0xFF && x < 0xFF
                && bg.enabled
            {
                status.formUnion(.spriteZeroHit)
            }

            return SpritePixel(
                enabled: pixel != 0,
                color: Int(ppuRead(at: 0x3F10 &+ sprite.attr.pallete.u16 &* 4 &+ pixel.u16)),
                priority: sprite.attr.contains(.behindBackground))
        }
        return .zero
    }

    mutating func readPPURegister(from address: UInt16) -> UInt8 {
        var result: UInt8

        switch address {
        case 0x2002:
            result = readStatus() | (internalDataBus & 0b11111)
            // Race Condition
            if currentLine == startVerticalBlank && currentDot < 2 {
                result &= ~0x80
            }
        case 0x2004:
            // https://wiki.nesdev.com/w/index.php/PPU_sprite_evaluation
            if currentLine < 240 && 1 <= currentDot && currentDot <= 64 {
                // during sprite evaluation
                result = 0xFF
            } else {
                result = primaryOAM[Int(objectAttributeMemoryAddress)]
            }
        case 0x2007:
            if v <= 0x3EFF {
                result = data
                data = ppuRead(at: v)
            } else {
                result = ppuRead(at: v)
            }
            incrV()
        default:
            result = 0x00
        }

        internalDataBus = result
        return result
    }

    mutating func writePPURegister(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x2000:
            writeController(value)
        case 0x2001:
            mask = PPUMask(rawValue: value)
        case 0x2003:
            objectAttributeMemoryAddress = value
        case 0x2004:
            primaryOAM[Int(objectAttributeMemoryAddress)] = value
            objectAttributeMemoryAddress &+= 1
        case 0x2005:
            writeScroll(position: value)
        case 0x2006:
            writeVRAMAddress(addr: value)
        case 0x2007:
            ppuWrite(value, at: v)
            incrV()
        default:
            break
        // NOP
        }
    }
}

extension PPURegisters {

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
