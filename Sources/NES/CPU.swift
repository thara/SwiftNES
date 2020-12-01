extension Emulator {

    @inline(__always)
    mutating func tick(count: UInt = 1) {
        nes.cpuCycles &+= count
    }

    mutating func cpuPowerOn() {
        nes.cpu.A = 0
        nes.cpu.X = 0
        nes.cpu.Y = 0
        nes.cpu.S = 0xFD
        nes.cpu.P = CPUStatus(rawValue: 0x34)
    }

    mutating func cpuStep() {
        switch receiveInterrupt() {
        case .RESET:
            handleRESET()
            clearInterrupt(.RESET)
        case .NMI:
            handleNMI()
            clearInterrupt(.NMI)
        case .IRQ:
            if nes.cpu.P.contains(.I) {
                handleIRQ()
                clearInterrupt(.IRQ)
            }
        case .BRK:
            if nes.cpu.P.contains(.I) {
                handleBRK()
                clearInterrupt(.BRK)
            }
        default:
            let opcode = fetchOperand()
            excuteInstruction(opcode: opcode)
        }
    }

    /// Reset registers & memory state
    mutating func handleRESET() {
        tick(count: 5)
        nes.cpu.PC = M.cpuReadWord(at: 0xFFFC, from: &nes)
        nes.cpu.P.formUnion(.I)
        nes.cpu.S -= 3
    }

    mutating func handleNMI() {
        tick(count: 2)

        pushStack(word: nes.cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPUStatus.interruptedB.rawValue)
        nes.cpu.P.formUnion(.I)
        nes.cpu.PC = M.cpuReadWord(at: 0xFFFA, from: &nes)
    }

    mutating func handleIRQ() {
        tick(count: 2)

        pushStack(word: nes.cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPUStatus.interruptedB.rawValue)
        nes.cpu.P.formUnion(.I)
        nes.cpu.PC = M.cpuReadWord(at: 0xFFFE, from: &nes)
    }

    mutating func handleBRK() {
        tick(count: 2)

        nes.cpu.PC &+= 1
        pushStack(word: nes.cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPUStatus.interruptedB.rawValue)
        nes.cpu.P.formUnion(.I)
        nes.cpu.PC = M.cpuReadWord(at: 0xFFFE, from: &nes)
    }

    @inline(__always)
    mutating func pushStack(_ value: UInt8) {
        M.cpuWrite(value, at: nes.cpu.S.u16 &+ 0x100, to: &nes)
        nes.cpu.S &-= 1
    }

    @inline(__always)
    mutating func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    @inline(__always)
    mutating func pullStack() -> UInt8 {
        nes.cpu.S &+= 1
        return M.cpuRead(at: nes.cpu.S.u16 &+ 0x100, from: &nes)
    }

    @inline(__always)
    mutating func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 &<< 8 | lo.u16
    }
}

extension MemoryMap {
    static func cpuReadWord(at address: UInt16, from nes: inout NES) -> UInt16 {
        return cpuRead(at: address, from: &nes).u16 | (cpuRead(at: address + 1, from: &nes).u16 << 8)
    }
}
