class PPUBus: Memory {
    var cartridge: Cartridge?

    private var nameTable: RAM
    private var paletteRAMIndexes: RAM

    init() {
        nameTable = RAM(data: 0x00, count: 0x1000)
        paletteRAMIndexes = RAM(data: 0x00, count: 0x0020)
    }

    func read(addr: UInt16) -> UInt8 {
        switch addr {
        case 0x0000...0x1FFF:
            return cartridge?.readCharacter(addr: addr) ?? 0x00
        case 0x2000...0x3EFF:
            return nameTable.read(addr: addr - 0x2000)
        case 0x3F00...0x3F1F:
            return paletteRAMIndexes.read(addr: addr - 0x3F00)
        default:
            return 0x00
        }
    }

    func write(addr: UInt16, data: UInt8) {
        switch addr {
        case 0x0000...0x1FFF:
            print("[PPU] Unsupported write access to cartridge")
        case 0x2000...0x3EFF:
            nameTable.write(addr: addr - 0x2000, data: data)
        case 0x3F00...0x3F1F:
            paletteRAMIndexes.write(addr: addr - 0x3F00, data: data)
        default:
            break // NOP
        }
    }
}
