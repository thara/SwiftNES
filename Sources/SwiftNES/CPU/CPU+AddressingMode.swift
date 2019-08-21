enum AddressingMode {
    case implicit
    case accumulator
    case immediate
    case zeroPage
    case zeroPageX
    case zeroPageY
    case absolute
    case absoluteX
    case absoluteY
    case relative
    case indirect
    case indexedIndirect
    case indirectIndexed
}

extension CPU {

    // swiftlint:disable cyclomatic_complexity
    func fetchOperand(in addressingMode: AddressingMode) -> (operand: UInt16?, pc: UInt16) {
        switch addressingMode {
        case .implicit:
            return (nil, 0)
        case .accumulator:
            return (registers.A.u16, 0)
        case .immediate:
            return (registers.PC, 1)
        case .zeroPage:
            return (memory.read(at: registers.PC).u16 & 0xFF, 1)
        case .zeroPageX:
            return ((memory.read(at: registers.PC).u16 &+ registers.X.u16) & 0xFF, 1)
        case .zeroPageY:
            return ((memory.read(at: registers.PC).u16 &+ registers.Y.u16) & 0xFF, 1)
        case .absolute:
            return (memory.readWord(at: registers.PC), 2)
        case .absoluteX:
            return (memory.readWord(at: registers.PC) &+ registers.X.u16 & 0xFFFF, 2)
        case .absoluteY:
            return (memory.readWord(at: registers.PC) &+ registers.Y.u16 & 0xFFFF, 2)
        case .relative:
            return (memory.read(at: registers.PC).u16, 1)
        case .indirect:
            let data = memory.readWord(at: registers.PC)
            return (readOnIndirect(operand: data), 2)
        case .indexedIndirect:
            let data = memory.readWord(at: registers.PC)
            return (readOnIndirect(operand: (data &+ registers.X.u16) & 0xFF), 1)
        case .indirectIndexed:
            let data = memory.read(at: registers.PC).u16
            return (readOnIndirect(operand: data) &+ registers.Y.u16, 1)
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = memory.read(at: operand).u16
        let high = memory.read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}
