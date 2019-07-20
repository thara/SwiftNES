class PPUBus: Memory {
    var cartridge: Cartridge?

    private var nameTable: RAM
    private var paletteRAMIndexes: RAM

    init() {
        nameTable = RAM(data: 0x00, count: 0x1000)
        paletteRAMIndexes = RAM(data: 0x00, count: 0x0020)
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return cartridge?.readCharacter(addr: address) ?? 0x00
        case 0x2000...0x3EFF:
            return nameTable.read(at: address - 0x2000)
        case 0x3F00...0x3F1F:
            return paletteRAMIndexes.read(at: address - 0x3F00)
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x1FFF:
            print("[PPU] Unsupported write access to cartridge")
        case 0x2000...0x3EFF:
            nameTable.write(value, at: address - 0x2000)
        case 0x3F00...0x3F1F:
            paletteRAMIndexes.write(value, at: address - 0x3F00)
        default:
            break // NOP
        }
    }
}
