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

    func fetchOperand(addressingMode: AddressingMode) -> (operand: UInt16?, pc: UInt16) {
        switch addressingMode {
        case .implicit:
            return (nil, 0)
        case .accumulator:
            return (UInt16(registers.A), 0)
        case .immediate:
            return (registers.PC, 1)
        case .zeroPage:
            return (UInt16(memory.read(addr: registers.PC)) & 0xFF, 1)
        case .zeroPageX:
            return ((UInt16(memory.read(addr: registers.PC)) + UInt16(registers.X)) & 0xFF, 1)
        case .zeroPageY:
            return ((UInt16(memory.read(addr: registers.PC)) + UInt16(registers.Y)) & 0xFF, 1)
        case .absolute:
            return (memory.readWord(addr: registers.PC), 2)
        case .absoluteX:
            return (memory.readWord(addr: registers.PC) + UInt16(registers.X) & 0xFFFF, 2)
        case .absoluteY:
            return (memory.readWord(addr: registers.PC) + UInt16(registers.Y) & 0xFFFF, 2)
        case .relative:
            let data = Int8(bitPattern: memory.read(addr: registers.PC))
            let result = Int16(bitPattern: registers.PC) + Int16(data)
            return (UInt16(bitPattern: result), 1)
        case .indirect:
            let low = memory.readWord(addr: registers.PC)
            let high = low & 0xFF00 + ((low + 1) & 0x00FF)  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            return (UInt16(memory.read(addr: low)) + UInt16(memory.read(addr: high)) << 8, 2)
        case .indexedIndirect:
            let low = (UInt16(memory.read(addr: registers.PC)) + UInt16(registers.X)) & 0x00FF
            let high = (low + 1) & 0x00FF  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            return (UInt16(memory.read(addr: low)) + UInt16(memory.read(addr: high)) << 8, 1)
        case .indirectIndexed:
            let low = UInt16(memory.read(addr: registers.PC))
            let high = (low + 1) & 0x00FF  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            let base = UInt16(memory.read(addr: low)) + UInt16(memory.read(addr: high)) << 8
            return (base + UInt16(registers.Y), 1)
        }
    }
}
