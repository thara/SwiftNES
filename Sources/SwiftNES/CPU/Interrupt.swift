enum Interrupt {
    case RESET
    case NMI
    case IRQ
    case BRK
}

extension CPU {

    /// Reset registers & memory state
    func reset() -> UInt {
        registers.P.formUnion(.I)

        registers.A = 0x00
        registers.X = 0x00
        registers.Y = 0x00
        registers.S = 0xff
        registers.PC = memory.readWord(addr: 0xFFFC)

        return 7
    }

    func handleNMI() -> UInt {
        registers.P.remove(.B)
        pushStack(word: registers.PC)
        pushStack(data: registers.P.rawValue)
        registers.P.formUnion(.I)

        registers.PC = memory.readWord(addr: 0xFFFA)
        return 7
    }

    func handleIMQ() -> UInt? {
        guard !registers.P.contains(.I) else {
            return nil
        }

        registers.P.remove(.B)
        pushStack(word: registers.PC)
        pushStack(data: registers.P.rawValue)
        registers.P.formUnion(.I)
        registers.PC = memory.readWord(addr: 0xFFFE)
        return 7
    }

    func handleBRQ() -> UInt? {
        guard !registers.P.contains(.I) else {
            return nil
        }

        registers.P.formUnion(.B)
        registers.PC += 1
        pushStack(word: registers.PC)
        pushStack(data: registers.P.rawValue)
        registers.P.formUnion(.I)
        registers.PC = memory.readWord(addr: 0xFFFE)
        return 7
    }
}
