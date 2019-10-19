final class CPUMemoryMap: Memory {
    private var wram: [UInt8]

    var ppuPort: IOPort?
    var cartridge: Cartridge?
    var controllerPort: ControllerPort?

    init() {
        self.wram = [UInt8](repeating: 0x00, count: 32767)
    }

    init(initial: [UInt8]) {
        self.wram = initial
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return wram.read(at: address)
        case 0x2000...0x3FFF:
            return ppuPort?.read(from: ppuAddress(address)) ?? 0x00
        case 0x4004, 0x4005, 0x4006, 0x4007, 0x4015:
            return 0xFF
        case 0x4016, 0x4017:
            return controllerPort?.read(at: address) ?? 0x00
        case 0x4020...0xFFFF:
            return cartridge?.read(at: address) ?? 0x00
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x07FF:
            wram.write(value, at: address)
        case 0x2000...0x3FFF:
            ppuPort?.write(value, to: ppuAddress(address))
        case 0x4016, 0x4017:
            controllerPort?.write(value)
        case 0x4020...0xFFFF:
            cartridge?.write(value, at: address)
        default:
            break
        }
    }

    private func ppuAddress(_ address: UInt16) -> UInt16 {
        // repears every 8 bytes
        return 0x2000 &+ address % 8
    }

    func clear() {
        wram.fill(0x00)
    }
}
