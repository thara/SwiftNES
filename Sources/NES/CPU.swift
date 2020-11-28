// CPU specification

protocol CPU: CPUStack, AddressingMode, CPUInstruction {
    mutating func cpuStep()
}

protocol CPURegisters {
    var A: UInt8 { get set }
    var X: UInt8 { get set }
    var Y: UInt8 { get set }
    var S: UInt8 { get set }
    var P: CPUStatus { get set }
    var PC: UInt16 { get set }
}

protocol CPUCycle {
    mutating func tick()
    mutating func tick(count: UInt)
}

protocol CPUMemory {
    mutating func cpuRead(at address: UInt16) -> UInt8
    mutating func cpuReadWord(at address: UInt16) -> UInt16
    mutating func cpuWrite(_ value: UInt8, at address: UInt16)
}

extension CPU where Self: CPURegisters & CPUCycle & CPUMemory & InterruptLine {

    mutating func cpuStep() {
        switch receiveInterrupt() {
        case .RESET:
            handleRESET()
            clearInterrupt(.RESET)
        case .NMI:
            handleNMI()
            clearInterrupt(.NMI)
        case .IRQ:
            if P.contains(.I) {
                handleIRQ()
                clearInterrupt(.IRQ)
            }
        case .BRK:
            if P.contains(.I) {
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
        #if nestest
            PC = 0xC000
            tick(count: 2)
        #else
            PC = cpuReadWord(at: 0xFFFC)
            P.formUnion(.I)
            S -= 3
        #endif
    }

    mutating func handleNMI() {
        tick(count: 2)

        pushStack(word: PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | CPUStatus.interruptedB.rawValue)
        P.formUnion(.I)
        PC = cpuReadWord(at: 0xFFFA)
    }

    mutating func handleIRQ() {
        tick(count: 2)

        pushStack(word: PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | CPUStatus.interruptedB.rawValue)
        P.formUnion(.I)
        PC = cpuReadWord(at: 0xFFFE)
    }

    mutating func handleBRK() {
        tick(count: 2)

        PC &+= 1
        pushStack(word: PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | CPUStatus.interruptedB.rawValue)
        P.formUnion(.I)
        PC = cpuReadWord(at: 0xFFFE)
    }
}

protocol CPUStack {}

extension CPUStack where Self: CPURegisters & CPUMemory {
    @inline(__always)
    mutating func pushStack(_ value: UInt8) {
        cpuWrite(value, at: S.u16 &+ 0x100)
        S &-= 1
    }

    @inline(__always)
    mutating func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    @inline(__always)
    mutating func pullStack() -> UInt8 {
        S &+= 1
        return cpuRead(at: S.u16 &+ 0x100)
    }

    @inline(__always)
    mutating func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 &<< 8 | lo.u16
    }
}
