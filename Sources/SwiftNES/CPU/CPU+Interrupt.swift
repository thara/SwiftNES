extension CPU {

    func interrupt() -> Bool {
        switch interruptLine.get() {
        case .RESET:
            reset()
        case .NMI:
            handleNMI()
        case .IRQ:
            if registers.P.contains(.I) {
                handleIRQ()
            }
        case .BRK:
            if registers.P.contains(.I) {
                handleBRK()
            }
        default:
            return false
        }

        return true
    }

    /// Reset registers & memory state
    func reset() {
        tick(count: 5)
#if nestest
        registers.PC = 0xC000
        interruptLine.clear(.RESET)
        tick(count: 2)
#else
        registers.PC = readWord(at: 0xFFFC)
        registers.P.formUnion(.I)
        registers.S -= 3

        interruptLine.clear(.RESET)
#endif
    }

    func handleNMI() {
        tick(count: 2)

        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.P.formUnion(.I)
        registers.PC = readWord(at: 0xFFFA)

        interruptLine.clear(.NMI)
    }

    func handleIRQ() {
        tick(count: 2)

        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.P.formUnion(.I)
        registers.PC = readWord(at: 0xFFFE)

        interruptLine.clear(.IRQ)
    }

    func handleBRK() {
        tick(count: 2)

        registers.PC &+= 1
        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.P.formUnion(.I)
        registers.PC = readWord(at: 0xFFFE)

        interruptLine.clear(.BRK)
    }
}
