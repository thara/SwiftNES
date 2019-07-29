extension CPU {

    /// Reset registers & memory state
    func reset() -> UInt {
        registers.P.formUnion(.I)

        registers.A = 0x00
        registers.X = 0x00
        registers.Y = 0x00
        registers.S = 0xff

#if nestest
        registers.PC = 0xC000
#else
        registers.PC = memory.readWord(at: 0xFFFC)
#endif

        interruptLine.clear(.RESET)

        return 7
    }

    func handleNMI() -> UInt {
        registers.P.remove(.B)
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

        registers.P.remove(.B)
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

        registers.P.formUnion(.B)
        registers.PC &+= 1
        pushStack(word: registers.PC)
        pushStack(registers.P.rawValue)
        registers.P.formUnion(.I)
        registers.PC = memory.readWord(at: 0xFFFE)

        interruptLine.clear(.BRK)

        return 7
    }
}
