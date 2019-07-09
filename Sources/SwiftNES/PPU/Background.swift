struct Background {
    var nameTableEntry: UInt8 = 0x00
    var attrTableEntry: UInt8 = 0x00
    var low: UInt8 = 0x00
    var high: UInt8 = 0x00
}

let nameTableFirstAddr: UInt16 = 0x2000
let attrTableFirstAddr: UInt16 = 0x23C0

extension PPUEmulator {

    func updateBackground(preRendering: Bool) {
        switch dot % 8 {
        case 1:
            background.nameTableEntry = memory.read(addr: nameTableAddr)
        case 2:
            background.attrTableEntry = memory.read(addr: attrTableAddr)
        //TODO
        default:
            break
        }
    }

    var nameTableAddr: UInt16 {
        return nameTableFirstAddr | (registers.vramAddr & 0xFFF)
    }

    var attrTableAddr: UInt16 {
        // Translate current VRAM address for attribute table(8 x 8) from name table(16x15)
        return attrTableFirstAddr | (registers.vramAddr.nameTableSelect & (registers.vramAddr.attrY << 3) & registers.vramAddr.attrX)
    }
}
