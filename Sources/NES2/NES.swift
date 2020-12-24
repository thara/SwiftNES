struct NES {
    var cpuCycles: UInt = 0

    var interrupt: Interrupt = []
}

extension NES: CPU {
    typealias Bus = CPUInterconnect

    @discardableResult
    mutating func cpuTick() -> UInt {
        cpuCycles += 1
        return cpuCycles
    }

    @discardableResult
    mutating func cpuTick(count: UInt) -> UInt {
        cpuCycles += count
        return cpuCycles
    }
}

final class CPUInterconnect: CPUBus {
    private var wram: [UInt8]

    init() {
        self.wram = [UInt8](repeating: 0x00, count: 32767)
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return wram.read(at: address)
        /* case 0x2000...0x3FFF: */
        /*     return ppu.readPPURegister(from: ppuAddress(address), by: self) */
        /* case 0x4000...0x4013, 0x4015: */
        /*     return apu.read(from: address) ?? 0x00 */
        /* case 0x4016, 0x4017: */
        /*     return controllers.read(at: address) */
        /* case 0x4020...0xFFFF: */
        /*     return mapper.read(at: address) ?? 0x00 */
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x07FF:
            wram.write(value, at: address)
        /* case 0x2000...0x3FFF: */
        /*     ppuPort?.write(value, to: ppuAddress(address)) */
        /* case 0x4000...0x4013, 0x4015: */
        /*     apuPort?.write(value, to: address) */
        /* case 0x4016: */
        /*     controllerPort?.write(value) */
        /* case 0x4017: */
        /*     controllerPort?.write(value) */
        /*     apuPort?.write(value, to: address) */
        /* case 0x4020...0xFFFF: */
        /*     cartridge?.write(value, at: address) */
        default:
            break
        }
    }
}
