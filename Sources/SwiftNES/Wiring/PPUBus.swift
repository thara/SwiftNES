final class PPUBus: Memory {
    var cartridge: Cartridge?

    var mirroring: Mirroring?

    private var nameTable: RAM
    private var paletteRAMIndexes: RAM

    init() {
        nameTable = RAM(data: 0x00, count: 0x1000)
        paletteRAMIndexes = RAM(data: 0x00, count: 0x0020)
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return cartridge?.read(at: address) ?? 0x00
        case 0x2000...0x3EFF:
            return nameTable.read(at: toNameTableAddress(address))
        case 0x3F00...0x3F1F:
            return paletteRAMIndexes.read(at: address &- 0x3F00)
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x1FFF:
            ppuBusLogger.warning("[PPU] Unsupported write access to cartridge : addr=\(address.radix16) value=\(value.radix16)")
        case 0x2000...0x3EFF:
            nameTable.write(value, at: toNameTableAddress(address))
        case 0x3F00...0x3F1F:
            paletteRAMIndexes.write(value, at: address &- 0x3F00)
        default:
            break // NOP
        }
    }

    func toNameTableAddress(_ baseAddress: UInt16) -> UInt16 {
        switch mirroring {
        case .vertical?:
            return baseAddress % 0x0800
        case .horizontal?:
            return ((baseAddress / 2) % 0x400) + (baseAddress % 0x400)
        default:
            return baseAddress &- 0x2000
        }
    }

    func clear() {
        nameTable.fill(0x00)
        paletteRAMIndexes.fill(0x00)
    }
}

enum Mirroring {
    case vertical, horizontal
}
