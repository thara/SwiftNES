extension CPU {

    /// Reset registers & memory state
    func reset() -> UInt {
#if nestest
        registers.PC = 0xC000
        interruptLine.clear(.RESET)
        return 7
#else
        registers.PC = memory.readWord(at: 0xFFFC)
        registers.P.formUnion(.I)
        registers.S -= 3

        interruptLine.clear(.RESET)

        return 7
#endif
    }

    func handleNMI() -> UInt {
        pushStack(word: registers.PC)
        pushStack(registers.P.rawValue)
        registers.P.formUnion(.I)

        registers.PC = memory.readWord(at: 0xFFFA)

        interruptLine.clear(.NMI)

        return 7
    }

    func handleIRQ() -> UInt? {
        guard !registers.P.contains(.I) else {
            return nil
        }

        pushStack(word: registers.PC)
        pushStack(registers.P.rawValue)
        registers.P.formUnion(.I)
        registers.PC = memory.readWord(at: 0xFFFE)

        interruptLine.clear(.IRQ)

        return 7
    }

    func handleBRK() -> UInt? {
        guard !registers.P.contains(.I) else {
            return nil
        }

        registers.PC &+= 1
        pushStack(word: registers.PC)
        pushStack(registers.P.rawValue)
        registers.P.formUnion(.I)
        registers.PC = memory.readWord(at: 0xFFFE)

        interruptLine.clear(.BRK)

        return 7
    }
}
