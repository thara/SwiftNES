let startVerticalBlank = 241

final class PPU {
    var registers = PPURegisters()
    var memory: Memory

    // Background registers
    var nameTableEntry: UInt8 = 0x00
    var attrTableEntry: UInt8 = 0x00
    var bgTempAddr: UInt16 = 0x00

    /// Background tiles
    var tile = Tile()
    var nextPattern = TilePattern()

    // Sprite OAM
    var primaryOAM = [UInt8](repeating: 0x00, count: oamSize)
    var secondaryOAM = [UInt8](repeating: 0x00, count: oamSize)
    var sprites = [Sprite](repeating: .defaultValue, count: spriteLimit)

    private(set) var frames: UInt = 0

    private let interruptLine: InterruptLine

    var scan = Scan()

    var lineBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)
    let renderer: Renderer

    // http://wiki.nesdev.com/w/index.php/PPU_registers#Ports
    var internalDataBus: UInt8 = 0x00

    init(memory: Memory, interruptLine: InterruptLine, renderer: Renderer) {
        self.memory = memory
        self.interruptLine = interruptLine
        self.renderer = renderer
    }

    var renderingEnabled: Bool {
        return registers.mask.contains(.sprite) || registers.mask.contains(.background)
    }

    func step() {
        process()

        switch scan.nextDot() {
        case .line(let last):
            renderer.newLine(number: last, pixels: lineBuffer)
        case .frame(let last):
            renderer.newLine(number: last, pixels: lineBuffer)
            frames += 1
        default:
            break
        }
    }

    func reset() {
        registers.clear()
        memory.clear()
        scan.clear()
        lineBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)
        frames = 0
    }
}

// MARK: - process implementation
extension PPU {

    func process() {
        var preRendering = false

        switch scan.line {
        case 261:
            // Pre Render
            defer {
                if scan.dot == 1 {
                    registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
                }
                if scan.dot == 341 && renderingEnabled && frames.isOdd {
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
    }

    func renderPixel() {
        let x = scan.dot &- 2

        let bg = getBackgroundPixel(x: x)
        let (sprite, spriteAttr, spriteZeroHit) = getSpritePixel(x: x)

        fetchBackgroundPixel()
        fetchSpritePixel()

        let idx = renderingEnabled
            ? selectPalleteIndex(bg: bg, sprite: sprite, spriteAttr: spriteAttr)
            : 0

        if spriteZeroHit && 0 < bg && x < 255 && renderingEnabled && !registers.status.contains(.spriteZeroHit) {
            registers.status.formUnion(.spriteZeroHit)
        }

        guard scan.line < NES.maxLine && 0 <= x && x < NES.width else {
            return
        }

        let palleteNo = memory.read(at: UInt16(0x3F00) &+ idx)
        lineBuffer[x] = palletes[Int(palleteNo)]
    }

    func selectPalleteIndex(bg: UInt16, sprite: UInt16, spriteAttr: SpriteAttribute) -> UInt16 {
        switch (bg, sprite, spriteAttr.contains(.behindBackground)) {
        case (0, 0, _):
            return bg
        case (0, let p, _) where 0 < p:
            return sprite
        case (let p, 0, _) where 0 < p:
            return bg
        case (_, _, false):
            return sprite
        case (_, _, true):
            return bg
        }
    }
}

// MARK: - Background
extension PPU {

    // swiftlint:disable cyclomatic_complexity
    func fetchBackgroundPixel() {
        switch scan.dot {
        case 321:
            // No reload shift
            bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
        case 1...255, 322...336:
            switch scan.dot % 8 {
            case 1:
                // Fetch nametable byte : step 1
                bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
                tile.reload(for: nextPattern, attribute: attrTableEntry)
            case 2:
                // Fetch nametable byte : step 2
                nameTableEntry = memory.read(at: bgTempAddr)
            case 3:
                // Fetch attribute table byte : step 1
                bgTempAddr = attributeTableFirst | registers.v.attributeAddressIndex
            case 4:
                // Fetch attribute table byte : step 2
                attrTableEntry = memory.read(at: bgTempAddr)
                // select area
                if registers.v.coarseXScroll[1] == 1 { attrTableEntry &>>= 2 }
                if registers.v.coarseYScroll[1] == 1 { attrTableEntry &>>= 4 }
            case 5:
                // Fetch tile bitmap low byte : step 1
                let base: UInt16 = registers.controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
                let index = nameTableEntry.u16 &* tileHeight &* 2
                bgTempAddr = base &+ index &+ registers.v.fineYScroll.u16
            case 6:
                // Fetch tile bitmap low byte : step 2
                nextPattern.low = memory.read(at: bgTempAddr).u16
            case 7:
                // Fetch tile bitmap high byte : step 1
                bgTempAddr &+= tileHeight
            case 0:
                // Fetch tile bitmap high byte : step 2
                nextPattern.high = memory.read(at: bgTempAddr).u16
                if renderingEnabled {
                    registers.incrCoarseX()
                }
            default:
                break
            }
        case 256:
            nextPattern.high = memory.read(at: bgTempAddr).u16
            if renderingEnabled {
                registers.incrY()
            }
        case 257:
            tile.reload(for: nextPattern, attribute: attrTableEntry)
            if renderingEnabled {
                registers.copyX()
            }
        case 280...304:
            if scan.line == 261 && renderingEnabled {
                registers.copyY()
            }
        // Unused name table fetches
        case 337, 339:
            bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
        case 338, 340:
            nameTableEntry = memory.read(at: bgTempAddr)
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    /// Returns pallete index for fine X
    func getBackgroundPixel(x: Int) -> UInt16 {
        let (pixel, pallete) = tile[registers.fineX]

        if (1 <= scan.dot && scan.dot <= 256) || (321 <= scan.dot && scan.dot <= 336) {
            tile.shift()
        }

        guard registers.isEnabledBackground(at: x) else {
            return 0x00
        }
        guard pixel != 0 else {
            return pixel
        }
        return pixel | (pallete &<< 2)
    }
}

// MARK: - Sprite
extension PPU {

    func fetchSpritePixel() {
        switch scan.dot {
        case 1:
            for i in 0..<oamSize {
                secondaryOAM[i] = 0xFF
            }
        case 257:
            // the sprite evaluation phase
            let spriteSize = registers.spriteSize
            var n = 0

            for i in 0..<spriteCount {
                let first = i &* 4
                let y = primaryOAM[first]
                secondaryOAM[first] = y
                if n < spriteLimit {
                    let row = scan.line &- Int(primaryOAM[first])
                    guard 0 <= row && row < spriteSize else {
                        continue
                    }
                    secondaryOAM[first &+ 1] = primaryOAM[first &+ 1]
                    secondaryOAM[first &+ 2] = primaryOAM[first &+ 2]
                    secondaryOAM[first &+ 3] = primaryOAM[first &+ 3]
                    n &+= 1
                }
            }

        case 257...320:
            // the sprite fetch phase
            let i = (scan.dot &- 257) / 8
            let n = i &* 4
            sprites[i] = Sprite(
                y: secondaryOAM[n],
                tileIndex: secondaryOAM[n &+ 1],
                attr: SpriteAttribute(rawValue: secondaryOAM[n &+ 2]),
                x: secondaryOAM[n &+ 3]
            )
        default:
            break
        }
    }

    func getSpritePixel(x: Int) -> (palleteIndex: UInt16, attribute: SpriteAttribute, spriteZero: Bool) {
        guard registers.isEnabledSprite(at: x) else {
            return (0, [], false)
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
            let low = memory.read(at: tileAddr)
            let high = memory.read(at: tileAddr &+ 8)

            let pixel = low[col] &+ (high[col] &<< 1)
            if pixel == 0 { // transparent
                continue
            }
            return (UInt16(pixel &+ 0x10), sprite.attr, i == 0)   // from 0x3F10
        }
        return (0, [], false)
    }
}

private extension BinaryInteger {
    @inline(__always)
    var isOdd: Bool { return self.magnitude % 2 != 0 }
}
