extension CPU {

    func interrupt() -> UInt? {
        switch interruptLine.get() {
        case .RESET:
            return reset()
        case .NMI:
            return handleNMI()
        case .IRQ:
            if registers.P.contains(.I) {
                return handleIRQ()
            }
        case .BRK:
            if registers.P.contains(.I) {
                return handleBRK()
            }
        default:
            break
        }

        return nil
    }

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

    func handleIRQ() -> UInt {
        pushStack(word: registers.PC)
        pushStack(registers.P.rawValue)
        registers.P.formUnion(.I)
        registers.PC = memory.readWord(at: 0xFFFE)

        interruptLine.clear(.IRQ)

        return 7
    }

    func handleBRK() -> UInt {
        registers.PC &+= 1
        pushStack(word: registers.PC)
        pushStack(registers.P.rawValue)
        registers.P.formUnion(.I)
        registers.PC = memory.readWord(at: 0xFFFE)

        interruptLine.clear(.BRK)

        return 7
    }
}
