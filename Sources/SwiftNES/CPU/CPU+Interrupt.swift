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
