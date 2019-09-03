final class PPUBus: Memory {
    var cartridge: Cartridge?

    var mirroring: Mirroring?

    private var nameTable: [UInt8]
    private var paletteRAMIndexes: [UInt8]

    init() {
        nameTable = [UInt8](repeating: 0x00, count: 0x1000)
        paletteRAMIndexes = [UInt8](repeating: 0x00, count: 0x0020)
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return cartridge?.read(at: address) ?? 0x00
        case 0x2000...0x3EFF:
            return nameTable.read(at: toNameTableAddress(address))
        case 0x3F00...0x3F1F:
            return paletteRAMIndexes.read(at: toPalleteAddress(address))
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x1FFF:
            cartridge?.write(value, at: address)
        case 0x2000...0x3EFF:
            nameTable.write(value, at: toNameTableAddress(address))
        case 0x3F00...0x3F1F:
            paletteRAMIndexes.write(value, at: toPalleteAddress(address))
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

    func toPalleteAddress(_ baseAddress: UInt16) -> UInt16 {
        // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
        if baseAddress % 4 == 0 {
            return (baseAddress | 0x10) & 0xFF
        } else {
            return baseAddress & 0xFF
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
