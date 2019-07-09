struct Background {
    var nameTableEntry: UInt8 = 0x00
    var attrTableEntry: UInt8 = 0x00

    var tileBitmapLow: UInt8 = 0x00
    var tileBitmapHigh: UInt8 = 0x00

    var tempTableAddr: UInt16 = 0x00
}

let nameTableFirstAddr: UInt16 = 0x2000
let attrTableFirstAddr: UInt16 = 0x23C0

let tileHeight: UInt8 = 8

extension PPUEmulator {

    func updateBackground(preRendering: Bool = false) {
        switch dot {
        case 1...255:
            switch dot % 8 {
            // name table
            case 1:
                background.tempTableAddr = nameTableAddr
            case 2:
                background.nameTableEntry = memory.read(addr: background.tempTableAddr)
            // attribute table
            case 3:
                background.tempTableAddr = attrTableAddr
            case 4:
                background.attrTableEntry = memory.read(addr: background.tempTableAddr)
            // tile bitmap low
            case 5:
                background.tempTableAddr = bgPatternTableAddr
            case 6:
                background.tileBitmapLow = memory.read(addr: background.tempTableAddr)
            // tile bitmap high
            case 7:
                background.tempTableAddr += tileHeight.u16
            case 0:
                background.tileBitmapHigh = memory.read(addr: background.tempTableAddr)
                incrCoarseX()
            default:
                break
            }
        case 256:
            background.tileBitmapHigh = memory.read(addr: background.tempTableAddr)
            incrY()
        default:
            break
        }
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
        if registers.vramAddr.coarseXScroll == 31 {
            registers.vramAddr &= ~0b11111 // coarse X = 0
            registers.vramAddr ^= 0x0400  // switch horizontal nametable
        } else {
            registers.vramAddr += 1
        }
    }

    func incrY() {
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
}
