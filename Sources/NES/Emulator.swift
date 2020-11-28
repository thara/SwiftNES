struct Emulator: CPU {
    var nes: NES

    private(set) var cycles: UInt = 0

    init() {
        self.nes = NES()
    }

    mutating func step() {
        let before = nes.cpuCycles

        cpuStep()

        let after = nes.cpuCycles
        if before <= after {
            cycles += after &- before
        } else {
            cycles += UInt.max &- before &+ after
        }
    }
}

extension Emulator: CPURegisters {
    var A: UInt8 {
        get { nes.cpu.A }
        set { nes.cpu.A = newValue }
    }
    var X: UInt8 {
        get { nes.cpu.X }
        set { nes.cpu.X = newValue }
    }
    var Y: UInt8 {
        get { nes.cpu.Y }
        set { nes.cpu.Y = newValue }
    }
    var S: UInt8 {
        get { nes.cpu.S }
        set { nes.cpu.S = newValue }
    }
    var P: CPUStatus {
        get { nes.cpu.P }
        set { nes.cpu.P = newValue }
    }
    var PC: UInt16 {
        get { nes.cpu.PC }
        set { nes.cpu.PC = newValue }
    }
}

extension Emulator: CPUCycle {
    mutating func tick() {
        nes.cpuCycles &+= 1
    }

    mutating func tick(count: UInt) {
        nes.cpuCycles &+= count
    }
}

extension Emulator: CPUMemory {
    mutating func cpuRead(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.cpu.wram.read(at: address)
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
            nes.cpu.wram.write(value, at: address)
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

extension Emulator: InterruptLine {

    mutating func sendInterrupt(_ interrupt: Interrupt) {
        nes.interrupt.formUnion(interrupt)
    }

    func receiveInterrupt() -> Interrupt {
        return nes.interrupt
    }

    mutating func clearInterrupt(_ interrupt: Interrupt) {
        nes.interrupt.remove(interrupt)
    }

    var interrupted: Bool {
        return !nes.interrupt.isEmpty
    }
}
