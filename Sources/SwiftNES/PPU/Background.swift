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
        return nameTableFirstAddr | (currentAddress & 0xFFF)
    }

    var attrTableAddr: UInt16 {
        // Translate currentAddress for attribute table(8 x 8) from name table(16x15)
        return attrTableFirstAddr | (currentAddress.nameTableSelect & (currentAddress.attrY << 3) & currentAddress.attrX)
    }
}

private extension UInt16 {

    var coarseX: UInt16 {
        return self & UInt16(0b11111)
    }

    /// Translate index of attribute table from name table
    var attrX: UInt16 {
        return coarseX / 4
    }

    var coarseY: UInt16 {
        return (self & UInt16(0b1111100000)) >> 5
    }

    /// Translate index of attribute table from name table
    var attrY: UInt16 {
        return coarseY / 4
    }

    var nameTableSelect: UInt16 {
        return self & UInt16(0b110000000000)
    }
}
