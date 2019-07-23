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
            let low = memory.readWord(at: registers.PC)
            let high = low & 0xFF00 &+ ((low &+ 1) & 0x00FF)  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            return (memory.read(at: low).u16 &+ memory.read(at: high).u16 &<< 8, 2)
        case .indexedIndirect:
            let low = (memory.read(at: registers.PC).u16 + registers.X.u16) & 0x00FF
            let high = (low &+ 1) & 0x00FF  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            return (memory.read(at: low).u16 &+ memory.read(at: high).u16 &<< 8, 1)
        case .indirectIndexed:
            let low = memory.read(at: registers.PC).u16
            let high = (low &+ 1) & 0x00FF  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            let base = memory.read(at: low).u16 &+ memory.read(at: high).u16 &<< 8
            return (base &+ registers.Y.u16, 1)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
