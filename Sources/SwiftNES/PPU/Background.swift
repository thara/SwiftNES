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
}
