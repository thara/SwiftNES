
func interrupt(registers: inout CPURegisters, memory: inout Memory, from interruptLine: InterruptLine) -> Bool {
    switch interruptLine.get() {
    case .RESET:
        reset(registers: &registers, memory: &memory)
        interruptLine.clear(.RESET)
    case .NMI:
        handleNMI(registers: &registers, memory: &memory)
        interruptLine.clear(.NMI)
    case .IRQ:
        if registers.P.contains(.I) {
            handleIRQ(registers: &registers, memory: &memory)
            interruptLine.clear(.IRQ)
        }
    case .BRK:
        if registers.P.contains(.I) {
            handleBRK(registers: &registers, memory: &memory)
            interruptLine.clear(.BRK)
        }
    default:
        return false
    }

    return true
}

/// Reset registers & memory state
func reset(registers: inout CPURegisters, memory: inout Memory) {
    registers.tick(count: 5)
#if nestest
    registers.PC = 0xC000
    interruptLine.clear(.RESET)
    registers.tick(count: 2)
#else
    registers.PC = registers.readWord(at: 0xFFFC, from: &memory)
    registers.P.formUnion(.I)
    registers.S -= 3
#endif
}

func handleNMI(registers: inout CPURegisters, memory: inout Memory) {
    registers.tick(count: 2)

    pushStack(word: registers.PC, registers: &registers, memory: &memory)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(registers.P.rawValue | Status.interruptedB.rawValue, registers: &registers, memory: &memory)
    registers.P.formUnion(.I)
    registers.PC = registers.readWord(at: 0xFFFA, from: &memory)
}

func handleIRQ(registers: inout CPURegisters, memory: inout Memory) {
    registers.tick(count: 2)

    pushStack(word: registers.PC, registers: &registers, memory: &memory)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(registers.P.rawValue | Status.interruptedB.rawValue, registers: &registers, memory: &memory)
    registers.P.formUnion(.I)
    registers.PC = registers.readWord(at: 0xFFFE, from: &memory)
}

func handleBRK(registers: inout CPURegisters, memory: inout Memory) {
    registers.tick(count: 2)

    registers.PC &+= 1
    pushStack(word: registers.PC, registers: &registers, memory: &memory)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(registers.P.rawValue | Status.interruptedB.rawValue, registers: &registers, memory: &memory)
    registers.P.formUnion(.I)
    registers.PC = registers.readWord(at: 0xFFFE, from: &memory)
}
