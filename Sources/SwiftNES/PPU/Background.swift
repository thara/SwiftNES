struct Background {
    /// value of name table
    var nameTableEntry: UInt8 = 0x00
    /// value of attribute table
    var attrTableEntry: UInt8 = 0x00

    /// 2 planes of 1 tile pattern
    var tempTileFirst: UInt8 = 0x00
    var tempTileSecond: UInt8 = 0x00

    /// general temporary address
    var tempTableAddr: UInt16 = 0x00

    /// 2 planes of 1 tile pattern
    var tilePatternFirst: UInt16 = 0x00
    var tilePatternSecond: UInt16 = 0x00

    var tileAttrLow: UInt8 = 0x00
    var tileAttrHigh: UInt8 = 0x00

    /// 1 quadrant of attrTableEntry
    var tileAttrLowLatch: Bool = false
    var tileAttrHighLatch: Bool = false

    mutating func shift() {
        tilePatternFirst <<= 1
        tilePatternSecond <<= 1
        tileAttrLow = (tileAttrLow << 1) | unsafeBitCast(tileAttrLowLatch, to: UInt8.self)
        tileAttrHigh = (tileAttrHigh << 1) | unsafeBitCast(tileAttrHighLatch, to: UInt8.self)
    }

    mutating func reloadShift() {
        tilePatternFirst = (tilePatternFirst & 0xFF00) | tempTileFirst.u16
        tilePatternSecond = (tilePatternSecond & 0xFF00) | tempTileSecond.u16

        tileAttrLowLatch = (attrTableEntry & 0x01) == 1
        tileAttrHighLatch = (attrTableEntry & 0x10) == 0x10
    }
}

let nameTableFirstAddr: UInt16 = 0x2000
let attrTableFirstAddr: UInt16 = 0x23C0

let tileHeight: UInt8 = 8

extension PPUEmulator {

    // swiftlint:disable cyclomatic_complexity
    func updateBackground(preRendering: Bool = false) {
        switch dot {
        case 1:
            background.tempTableAddr = nameTableAddr
            if preRendering {
                registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
            }
        case 321:
            // No reload shift
            background.tempTableAddr = nameTableAddr
        case 2...255, 322...336:
            switch dot % 8 {
            // name table
            case 1:
                background.tempTableAddr = nameTableAddr
                background.reloadShift()
            case 2:
                background.nameTableEntry = memory.read(addr: background.tempTableAddr)
            // attribute table
            case 3:
                background.tempTableAddr = attrTableAddr
            case 4:
                background.attrTableEntry = memory.read(addr: background.tempTableAddr)

                if registers.vramAddr.coarseXScroll & UInt16(0b10) == 0b10 {
                    // top right
                    background.attrTableEntry <<= 2
                }
                if registers.vramAddr.coarseYScroll & UInt16(0b10)  == 0b10 {
                    // buttom left
                    background.attrTableEntry <<= 4
                }

            // tile bitmap low
            case 5:
                background.tempTableAddr = bgPatternTableAddr
            case 6:
                background.tempTileFirst = memory.read(addr: background.tempTableAddr)
            // tile bitmap high
            case 7:
                background.tempTableAddr += tileHeight.u16
            case 0:
                background.tempTileSecond = memory.read(addr: background.tempTableAddr)
                incrCoarseX()
            default:
                break
            }
        case 256:
            background.tempTileSecond = memory.read(addr: background.tempTableAddr)
            incrY()
        case 257:
            updateHorizontalPosition()
            background.reloadShift()
        case 280...304:
            if preRendering {
                updateVerticalPosition()
            }
        // Unused name table fetches
        case 337:
            background.tempTableAddr = nameTableAddr
        case 338:
            background.nameTableEntry = memory.read(addr: background.tempTableAddr)
        case 339:
            background.tempTableAddr = nameTableAddr
        case 340:
            background.nameTableEntry = memory.read(addr: background.tempTableAddr)
            if preRendering && renderingEnabled && frames.isOdd {
                // Skip 0 cycle on visible frame
                dot += 1
            }
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func getBackgroundPaletteIndex() -> Int {
        // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
        let pixel = ((background.tilePatternSecond >> (15 - registers.fineX)) << 1) | (background.tilePatternFirst >> (15 - registers.fineX))
        let pallete = ((background.tileAttrHigh.u16 >> (7 - registers.fineX)) << 1) | (background.tileAttrLow.u16 >> (7 - registers.fineX))
        return Int(pixel | (pallete << 2))
    }

    var nameTableAddr: UInt16 {
        return nameTableFirstAddr | registers.vramAddr.nameTableIdx
    }

    var attrTableAddr: UInt16 {
        // Translate current VRAM address for attribute table(8x8) from name table(16x15)
        return attrTableFirstAddr | registers.vramAddr.nameTableSelect | (registers.vramAddr.attrY << 3) | registers.vramAddr.attrX
    }

    var bgPatternTableAddr: UInt16 {
        return registers.controller.bgPatternTableAddrBase + (background.nameTableEntry * tileHeight * 2 + registers.vramAddr.fineYScroll).u16
    }

    func incrCoarseX() {
        guard renderingEnabled else { return }

        if registers.vramAddr.coarseXScroll == 31 {
            registers.vramAddr &= ~0b11111 // coarse X = 0
            registers.vramAddr ^= 0x0400  // switch horizontal nametable
        } else {
            registers.vramAddr += 1
        }
    }

    func incrY() {
        guard renderingEnabled else { return }

        if registers.vramAddr.fineYScroll < 7 {
            registers.vramAddr += 0x1000
        } else {
            registers.vramAddr &= ~0x7000 // fine Y = 0

            var y = registers.vramAddr.coarseYScroll
            if y == 29 {
                y = 0
                registers.vramAddr ^= 0x0800  // switch vertical nametable
            } else if y == 31 {
                y = 0
            } else {
                y += 1
            }

            registers.vramAddr = (registers.vramAddr & ~0x03E0) | (y << 5)
        }
    }

    func updateHorizontalPosition() {
        guard renderingEnabled else { return }

        registers.vramAddr = (registers.vramAddr & ~0b010000011111) | (registers.tempAddr & 0b010000011111)
    }

    func updateVerticalPosition() {
        guard renderingEnabled else { return }

        registers.vramAddr = (registers.vramAddr & ~0b101111100000) | (registers.tempAddr & 0b101111100000)
    }

    var renderingEnabled: Bool {
        return registers.mask.contains(.sprite) || registers.mask.contains(.background)
    }
}
