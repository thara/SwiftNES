func interrupt(cpu: inout CPU, memory: inout Memory, from interruptLine: InterruptLine) -> Bool {
    switch interruptLine.get() {
    case .RESET:
        cpu.reset(memory: &memory)
        interruptLine.clear(.RESET)
    case .NMI:
        cpu.handleNMI(memory: &memory)
        interruptLine.clear(.NMI)
    case .IRQ:
        if cpu.P.contains(.I) {
            cpu.handleIRQ(memory: &memory)
            interruptLine.clear(.IRQ)
        }
    case .BRK:
        if cpu.P.contains(.I) {
            cpu.handleBRK(memory: &memory)
            interruptLine.clear(.BRK)
        }
    default:
        return false
    }

    return true
}

extension CPU {
    /// Reset registers & memory state
    mutating func reset(memory: inout Memory) {
        tick(count: 5)
#if nestest
        PC = 0xC000
        tick(count: 2)
#else
        PC = readWord(at: 0xFFFC, from: &memory)
        P.formUnion(.I)
        S -= 3
#endif
    }

    mutating func handleNMI(memory: inout Memory) {
        tick(count: 2)

        pushStack(word: PC, to: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | Status.interruptedB.rawValue, to: &memory)
        P.formUnion(.I)
        PC = readWord(at: 0xFFFA, from: &memory)
    }

    mutating func handleIRQ(memory: inout Memory) {
        tick(count: 2)

        pushStack(word: PC, to: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | Status.interruptedB.rawValue, to: &memory)
        P.formUnion(.I)
        PC = readWord(at: 0xFFFE, from: &memory)
    }

    mutating func handleBRK(memory: inout Memory) {
        tick(count: 2)

        PC &+= 1
        pushStack(word: PC, to: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | Status.interruptedB.rawValue, to: &memory)
        P.formUnion(.I)
        PC = readWord(at: 0xFFFE, from: &memory)
    }
}
