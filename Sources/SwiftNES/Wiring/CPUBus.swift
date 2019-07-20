class CPUBus: Memory {
    private var wram: Memory
    var ppuPort: IOPort?
    var cartridge: Cartridge?

    init() {
        self.wram = RAM(data: 0x00, count: 32767)
    }

    init(initial: [UInt8]) {
        self.wram = RAM(rawData: initial)
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return wram.read(at: address)
        case 0x2000...0x3FFF:
            return ppuPort?.read(addr: ppuAddr(address)) ?? 0x00
        case 0x4020...0xFFFF:
            return cartridge?.read(addr: address) ?? 0x00
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x07FF:
            wram.write(value, at: address)
        case 0x2000...0x3FFF:
            ppuPort?.write(addr: ppuAddr(address), data: value)
        case 0x4020...0xFFFF:
            cartridge?.write(addr: address, data: value)
        default:
            break
        }
    }

    private func ppuAddr(_ address: UInt16) -> UInt16 {
        // repears every 8 bytes
        return 0x2000 + address % 8
    }
}
