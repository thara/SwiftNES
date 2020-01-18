let startVerticalBlank = 241

func ppuStep(on nes: inout NES) {
    switch nes.ppu.scan.line {
    case 261:
        // Pre Render
        defer {
            if nes.ppu.scan.dot == 1 {
                nes.ppu.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
            }
            if nes.ppu.scan.dot == 341 && nes.ppu.renderingEnabled && nes.ppu.frames.isOdd {
                // Skip 0 cycle on visible frame
                nes.ppu.scan.skip()
            }
        }

        fallthrough
    case 0...239:
        // Visible
        renderPixel(on: &nes)
    case 240:
        // Post Render
        break
    case startVerticalBlank:
        // begin VBLANK
        if nes.ppu.scan.dot == 1 {
            nes.ppu.status.formUnion(.vblank)
            if nes.ppu.controller.contains(.nmi) {
                nes.interruptLine.send(.NMI)
            }
        }
    default:
        break
    }

    switch nes.ppu.scan.nextDot() {
    case .frame:
        nes.ppu.frames += 1
    default:
        break
    }
}

// MARK: - process implementation
func renderPixel(on nes: inout NES) {
    let x = nes.ppu.scan.dot &- 2

    let bg = getBackgroundPixel(x: x, from: &nes)
    let sprite = getSpritePixel(x: x, background: bg, from: &nes)

    if nes.ppu.renderingEnabled {
        fetchBackgroundPixel(from: &nes)
        fetchSpritePixel(from: &nes.ppu)
    }

    guard nes.ppu.scan.line < NES.maxLine && 0 <= x && x < NES.width else {
        return
    }

    let pixel = nes.ppu.renderingEnabled ? selectPixel(bg: bg, sprite: sprite, from: &nes) : 0
    nes.ppu.lineBuffer.write(pixel, bg.color, sprite.color, at: x)
}

func selectPixel(bg: BackgroundPixel, sprite: SpritePixel, from nes: inout NES) -> Int {
    switch (bg.enabled, sprite.enabled) {
    case (false, false):
        return Int(readPPU(at: 0x3F00, from: &nes))
    case (false, true):
        return sprite.color
    case (true, false):
        return bg.color
    case (true, true):
        return sprite.priority ? bg.color : sprite.color
    }
}

// MARK: - Background

// swiftlint:disable cyclomatic_complexity
func fetchBackgroundPixel(from nes: inout NES) {
    switch nes.ppu.scan.dot {
    case 321:
        // No reload shift
        nes.ppu.bgTempAddr = nameTableFirst | nes.ppu.v.nameTableAddressIndex
    case 1...255, 322...336:
        switch nes.ppu.scan.dot % 8 {
        case 1:
            // Fetch nametable byte : step 1
            nes.ppu.bgTempAddr = nameTableFirst | nes.ppu.v.nameTableAddressIndex
            nes.ppu.tile.reload(for: nes.ppu.nextPattern, with: nes.ppu.attrTableEntry)
        case 2:
            // Fetch nametable byte : step 2
            nes.ppu.nameTableEntry = readPPU(at: nes.ppu.bgTempAddr, from: &nes)
        case 3:
            // Fetch attribute table byte : step 1
            nes.ppu.bgTempAddr = attributeTableFirst | nes.ppu.v.attributeAddressIndex
        case 4:
            // Fetch attribute table byte : step 2
            nes.ppu.attrTableEntry = readPPU(at: nes.ppu.bgTempAddr, from: &nes)
            // select area
            if nes.ppu.v.coarseXScroll[1] == 1 { nes.ppu.attrTableEntry &>>= 2 }
            if nes.ppu.v.coarseYScroll[1] == 1 { nes.ppu.attrTableEntry &>>= 4 }
        case 5:
            // Fetch tile bitmap low byte : step 1
            let base: UInt16 = nes.ppu.controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
            let index = nes.ppu.nameTableEntry.u16 &* tileHeight &* 2
            nes.ppu.bgTempAddr = base &+ index &+ nes.ppu.v.fineYScroll.u16
        case 6:
            // Fetch tile bitmap low byte : step 2
            nes.ppu.nextPattern.low = readPPU(at: nes.ppu.bgTempAddr, from: &nes).u16
        case 7:
            // Fetch tile bitmap high byte : step 1
            nes.ppu.bgTempAddr &+= tileHeight
        case 0:
            // Fetch tile bitmap high byte : step 2
            nes.ppu.nextPattern.high = readPPU(at: nes.ppu.bgTempAddr, from: &nes).u16
            if nes.ppu.renderingEnabled {
                nes.ppu.incrCoarseX()
            }
        default:
            break
        }
    case 256:
        nes.ppu.nextPattern.high = readPPU(at: nes.ppu.bgTempAddr, from: &nes).u16
        if nes.ppu.renderingEnabled {
            nes.ppu.incrY()
        }
    case 257:
        nes.ppu.tile.reload(for: nes.ppu.nextPattern, with: nes.ppu.attrTableEntry)
        if nes.ppu.renderingEnabled {
            nes.ppu.copyX()
        }
    case 280...304:
        if nes.ppu.scan.line == 261 && nes.ppu.renderingEnabled {
            nes.ppu.copyY()
        }
    // Unused name table fetches
    case 337, 339:
        nes.ppu.bgTempAddr = nameTableFirst | nes.ppu.v.nameTableAddressIndex
    case 338, 340:
        nes.ppu.nameTableEntry = readPPU(at: nes.ppu.bgTempAddr, from: &nes)
    default:
        break
    }
}
// swiftlint:enable cyclomatic_complexity

/// Returns pallete index for fine X
func getBackgroundPixel(x: Int, from nes: inout NES) -> BackgroundPixel {
    let (pixel, pallete) = nes.ppu.tile[nes.ppu.fineX]

    if (1 <= nes.ppu.scan.dot && nes.ppu.scan.dot <= 256) || (321 <= nes.ppu.scan.dot && nes.ppu.scan.dot <= 336) {
        nes.ppu.tile.shift()
    }

    guard isEnabledBackground(nes.ppu.mask, at: x) else {
        return .zero
    }
    return BackgroundPixel(
        enabled: pixel != 0,
        color: Int(readPPU(at: 0x3F00 &+ pallete &* 4 &+ pixel, from: &nes)))
}

// MARK: - Sprite

func fetchSpritePixel(from ppu: inout PPU) {
    switch ppu.scan.dot {
    case 0:
        ppu.secondaryOAM.fill(0xFF)
        ppu.spriteZeroOnLine = false

        // the sprite evaluation phase
        let spriteSize = ppu.spriteSize
        var n = 0

        let oamIterator = Iterator(limit: ppu.secondaryOAM.count)
        for i in 0..<spriteCount {
            let first = i &* 4
            let y = ppu.primaryOAM[first]

            if oamIterator.hasNext {
                let row = ppu.scan.line &- Int(ppu.primaryOAM[first])
                guard 0 <= row && row < spriteSize else {
                    continue
                }
                if n == 0 {
                    ppu.spriteZeroOnLine = true
                }
                ppu.secondaryOAM[oamIterator] = y
                ppu.secondaryOAM[oamIterator] = ppu.primaryOAM[first &+ 1]
                ppu.secondaryOAM[oamIterator] = ppu.primaryOAM[first &+ 2]
                ppu.secondaryOAM[oamIterator] = ppu.primaryOAM[first &+ 3]
                n &+= 1
            }
        }
        if spriteLimit <= n && ppu.renderingEnabled {
            ppu.status.formUnion(.spriteOverflow)
        }
    case 257...320:
        // the sprite fetch phase
        let i = (ppu.scan.dot &- 257) / 8
        let n = i &* 4
        ppu.sprites[i] = Sprite(
            y: ppu.secondaryOAM[n],
            tileIndex: ppu.secondaryOAM[n &+ 1],
            attr: Sprite.Attribute(rawValue: ppu.secondaryOAM[n &+ 2]),
            x: ppu.secondaryOAM[n &+ 3]
        )
    default:
        break
    }
}

func getSpritePixel(x: Int, background bg: BackgroundPixel, from nes: inout NES) -> SpritePixel {
    guard isEnabledSprite(nes.ppu.mask, at: x) else {
        return .zero
    }

    let y = nes.ppu.scan.line
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
        let low = readPPU(at: tileAddr, from: &nes)
        let high = readPPU(at: tileAddr &+ 8, from: &nes)

        let pixel = low[col] &+ (high[col] &<< 1)
        if pixel == 0 { // transparent
            continue
        }

        if i == 0
            && nes.ppu.spriteZeroOnLine
            && nes.ppu.renderingEnabled
            && !nes.ppu.status.contains(.spriteZeroHit)
            && sprite.x != 0xFF && x < 0xFF
            && bg.enabled {
            nes.ppu.status.formUnion(.spriteZeroHit)
        }

        return SpritePixel(
            enabled: pixel != 0,
            color: Int(readPPU(at: 0x3F10 &+ sprite.attr.pallete.u16 &* 4 &+ pixel.u16, from: &nes)),
            priority: sprite.attr.contains(.behindBackground))
    }
    return .zero
}

extension PPU {

    var spriteSize: Int {
        return controller.contains(.spriteSize) ? 16 : 8
    }

    var backgroundPatternTableAddrBase: UInt16 {
        return controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
    }

    mutating func incrV() {
        v &+= controller.vramIncrement
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242000_write
    mutating func writeController(_ d: UInt8) {
        controller = PPUController(rawValue: d)
        // t: ...BA.. ........ = d: ......BA
        t = (t & ~0b000110000000000) | (controller.nameTableSelect << 10)
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
            t = (t & ~0b000000000011111) | ((d & 0b11111000).u16 >> 3)
            fineX = d & 0b111
            writeToggle = true
        } else {
            // second write
            // t: CBA..HG FED..... = d: HGFEDCBA
            t = (t & ~0b111001111100000) | ((d & 0b111).u16 << 12) | ((d & 0b11111000).u16 << 2)
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
            t = (t & ~0b011111100000000) | ((d & 0b111111).u16 << 8)
            writeToggle = true
        } else {
            // second write
            // t: ....... HGFEDCBA = d: HGFEDCBA
            // v                   = t
            t = (t & ~0b000000011111111) | d.u16
            v = t
            writeToggle = false
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#Coarse_X_increment
    mutating func incrCoarseX() {
        if v.coarseXScroll == 31 {
            v &= ~0b11111 // coarse X = 0
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
            v &= ~0x7000 // fine Y = 0

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
        v = (v & ~0b10000011111) | (t & 0b10000011111)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#During_dots_280_to_304_of_the_pre-render_scanline_.28end_of_vblank.29
    mutating func copyY() {
        // v: IHGF.ED CBA..... = t: IHGF.ED CBA.....
        v = (v & ~0b111101111100000) | (t & 0b111101111100000)
    }
}

private extension BinaryInteger {
    @inline(__always)
    var isOdd: Bool { return self.magnitude % 2 != 0 }
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

func isEnabledSprite(_ mask: PPUMask, at x: Int) -> Bool {
    return mask.contains(.sprite) && !(x < 8 && !mask.contains(.spriteLeft))
}

func isEnabledBackground(_ mask: PPUMask, at x: Int) -> Bool {
    return mask.contains(.background) && !(x < 8 && !mask.contains(.backgroundLeft))
}
