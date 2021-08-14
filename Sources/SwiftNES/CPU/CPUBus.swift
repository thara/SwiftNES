final class CPUBus: Memory {
    private var wram: [UInt8]

    var ppuPort: IOPort?
    var apuPort: IOPort?
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
        case 0x4000...0x4013, 0x4015:
            return apuPort?.read(from: address) ?? 0x00
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
        case 0x4000...0x4013, 0x4015:
            apuPort?.write(value, to: address)
        case 0x4016:
            controllerPort?.write(value)
        case 0x4017:
            controllerPort?.write(value)
            apuPort?.write(value, to: address)
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

extension CPU {

    mutating func readWord(at address: UInt16) -> UInt16 {
        return read(at: address).u16 | (read(at: address + 1).u16 << 8)
    }

    mutating func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8
        return low | high
    }
}

extension Memory {
    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8
        return low | high
    }
}

func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
    return pageCrossed(value: value, operand: operand.u16)
}

func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

func pageCrossed(value: Int, operand: Int) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}
