extension NES: CPU {}

extension NES: CPURegisters {
    var A: UInt8 {
        get { cpu.A }
        set { cpu.A = newValue }
    }
    var X: UInt8 {
        get { cpu.X }
        set { cpu.X = newValue }
    }
    var Y: UInt8 {
        get { cpu.Y }
        set { cpu.Y = newValue }
    }
    var S: UInt8 {
        get { cpu.S }
        set { cpu.S = newValue }
    }
    var P: CPU.Status {
        get { cpu.P }
        set { cpu.P = newValue }
    }
    var PC: UInt16 {
        get { cpu.PC }
        set { cpu.PC = newValue }
    }
}

extension NES: CPUCycle {
    mutating func tick() {
        cpuCycles &+= 1
    }

    mutating func tick(count: UInt) {
        cpuCycles &+= count
    }
}

extension NES: CPUMemory {
    mutating func cpuRead(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return cpu.wram.read(at: address)
        /* case 0x2000...0x3FFF: */
        /*     return ppuPort?.read(from: ppuAddress(address)) ?? 0x00 */
        /* case 0x4000...0x4013, 0x4015: */
        /*     return apuPort?.read(from: address) ?? 0x00 */
        /* case 0x4016, 0x4017: */
        /*     return controllerPort?.read(at: address) ?? 0x00 */
        /* case 0x4020...0xFFFF: */
        /*     return cartridge?.read(at: address) ?? 0x00 */
        default:
            return 0x00
        }
    }

    mutating func cpuReadWord(at address: UInt16) -> UInt16 {
        return cpuRead(at: address).u16 | (cpuRead(at: address + 1).u16 << 8)
    }

    mutating func cpuWrite(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x07FF:
            cpu.wram.write(value, at: address)
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

extension NES: InterruptLine {

    mutating func sendInterrupt(_ interrupt: Interrupt) {
        self.interrupt.formUnion(interrupt)
    }

    func receiveInterrupt() -> Interrupt {
        return self.interrupt
    }

    mutating func clearInterrupt(_ interrupt: Interrupt) {
        self.interrupt.remove(interrupt)
    }

    var interrupted: Bool {
        return !interrupt.isEmpty
    }
}
