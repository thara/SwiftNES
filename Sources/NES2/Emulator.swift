class Emulator {
    var nes = NES()
    var cpuRegister = CPURegister()
    var cpuInterconnect: CPUInterconnect

    var cycles: UInt = 0

    init() {
        self.cpuInterconnect = CPUInterconnect()
    }

    func step() {
        let before = nes.cpuCycles

        cpuStep()

        let after = nes.cpuCycles

        let cpuCycles: UInt
        if before <= after {
            cpuCycles = after &- before
        } else {
            cpuCycles = UInt.max &- before &+ after
        }
        cycles += cpuCycles
    }

    func cpuStep() {
        switch nes.receiveInterrupt() {
        case .RESET:
            nes.reset(register: &cpuRegister, bus: &cpuInterconnect)
            nes.clearInterrupt(.RESET)
        case .NMI:
            nes.handleNMI(register: &cpuRegister, with: &cpuInterconnect)
            nes.clearInterrupt(.NMI)
        case .IRQ:
            if cpuRegister.P.contains(.I) {
                nes.handleIRQ(register: &cpuRegister, with: &cpuInterconnect)
                nes.clearInterrupt(.IRQ)
            }
        case .BRK:
            if cpuRegister.P.contains(.I) {
                nes.handleBRK(register: &cpuRegister, with: &cpuInterconnect)
                nes.clearInterrupt(.BRK)
            }
        default:
            nes.cpuStep(register: &cpuRegister, with: &cpuInterconnect)
        }
    }
}
