class CPUBus: RAM {
    private var wram: RAM
    var ppuPort: IOPort?
    var cartridge: Cartridge?

    init() {
        self.wram = ArrayRAM(data: 0x00, count: 32767)
    }

    init(initial: [UInt8]) {
        self.wram = ArrayRAM(rawData: initial)
    }

    func read(addr: UInt16) -> UInt8 {
        switch addr {
        case 0x0000...0x1FFF:
            return wram.read(addr: addr)
        case 0x2000...0x3FFF:
            return ppuPort?.read(addr: ppuAddr(addr)) ?? 0x00
        case 0x4020...0xFFFF:
            return cartridge?.read(addr: addr) ?? 0x00
        default:
            return 0x00
        }
    }

    func write(addr: UInt16, data: UInt8) {
        switch addr {
        case 0x0000...0x07FF:
            wram.write(addr: addr, data: data)
        case 0x2000...0x3FFF:
            ppuPort?.write(addr: ppuAddr(addr), data: data)
        case 0x4020...0xFFFF:
            cartridge?.write(addr: addr, data: data)
        default:
            break
        }
    }

    private func ppuAddr(_ addr: UInt16) -> UInt16 {
        // repears every 8 bytes
        return 0x2000 + addr % 8
    }
}
