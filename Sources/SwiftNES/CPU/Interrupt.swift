func interrupt(cpu: inout CPU, memory: inout Memory, from interruptLine: InterruptLine) -> Bool {
    switch interruptLine.get() {
    case .RESET:
        reset(cpu: &cpu, memory: &memory)
        interruptLine.clear(.RESET)
    case .NMI:
        handleNMI(cpu: &cpu, memory: &memory)
        interruptLine.clear(.NMI)
    case .IRQ:
        if cpu.P.contains(.I) {
            handleIRQ(cpu: &cpu, memory: &memory)
            interruptLine.clear(.IRQ)
        }
    case .BRK:
        if cpu.P.contains(.I) {
            handleBRK(cpu: &cpu, memory: &memory)
            interruptLine.clear(.BRK)
        }
    default:
        return false
    }

    return true
}

/// Reset registers & memory state
func reset(cpu: inout CPU, memory: inout Memory) {
    cpu.tick(count: 5)
#if nestest
    cpu.PC = 0xC000
    interruptLine.clear(.RESET)
    cpu.tick(count: 2)
#else
    cpu.PC = cpu.readWord(at: 0xFFFC, from: &memory)
    cpu.P.formUnion(.I)
    cpu.S -= 3
#endif
}

func handleNMI(cpu: inout CPU, memory: inout Memory) {
    cpu.tick(count: 2)

    pushStack(word: cpu.PC, cpu: &cpu, memory: &memory)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(cpu.P.rawValue | Status.interruptedB.rawValue, cpu: &cpu, memory: &memory)
    cpu.P.formUnion(.I)
    cpu.PC = cpu.readWord(at: 0xFFFA, from: &memory)
}

func handleIRQ(cpu: inout CPU, memory: inout Memory) {
    cpu.tick(count: 2)

    pushStack(word: cpu.PC, cpu: &cpu, memory: &memory)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(cpu.P.rawValue | Status.interruptedB.rawValue, cpu: &cpu, memory: &memory)
    cpu.P.formUnion(.I)
    cpu.PC = cpu.readWord(at: 0xFFFE, from: &memory)
}

func handleBRK(cpu: inout CPU, memory: inout Memory) {
    cpu.tick(count: 2)

    cpu.PC &+= 1
    pushStack(word: cpu.PC, cpu: &cpu, memory: &memory)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(cpu.P.rawValue | Status.interruptedB.rawValue, cpu: &cpu, memory: &memory)
    cpu.P.formUnion(.I)
    cpu.PC = cpu.readWord(at: 0xFFFE, from: &memory)
}
