class PPUAddressSpace: Memory {
    private var patternTable = [UInt8](repeating: 0, count: 0x2000)
    private var nameTable = [UInt8](repeating: 0, count: 0x1000)
    private var paletteRAMIndexes = [UInt8](repeating: 0, count: 0x0020)

    func read(addr: UInt16) -> UInt8 {
        switch addr {
        case 0x0000...0x1FFF:
            return patternTable[Int(addr)]
        case 0x2000...0x3EFF:
            return nameTable[Int(addr - 0x2000)]
        case 0x3F00...0x3F1F:
            return paletteRAMIndexes[Int(addr - 0x3F00)]
        default:
            return 0x00
        }
    }

    func write(addr: UInt16, data: UInt8) {
        switch addr {
        case 0x0000...0x1FFF:
            patternTable[Int(addr)] = data
        case 0x2000...0x3EFF:
            nameTable[Int(addr - 0x2000)] = data
        case 0x3F00...0x3F1F:
            paletteRAMIndexes[Int(addr - 0x3F00)] = data
        default:
            break // NOP
        }
    }
}
