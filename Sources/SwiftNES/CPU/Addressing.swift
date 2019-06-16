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

    func fetchOperand(addressingMode: AddressingMode) -> UInt16? {
        switch addressingMode {
        case .implicit:
            return nil
        case .accumulator:
            return UInt16(registers.A)
        case .immediate:
            return registers.PC
        case .zeroPage:
            return UInt16(memory.read(addr: registers.PC)) & 0xFF
        case .zeroPageX:
            return (UInt16(memory.read(addr: registers.PC)) + UInt16(registers.X)) & 0xFF
        case .zeroPageY:
            return (UInt16(memory.read(addr: registers.PC)) + UInt16(registers.Y)) & 0xFF
        case .absolute:
            return registers.PC
        case .absoluteX:
            return registers.PC + UInt16(registers.X)
        case .absoluteY:
            return registers.PC + UInt16(registers.Y)
        case .relative:
            let data = Int8(bitPattern: memory.read(addr: registers.PC))
            let result = Int16(bitPattern: registers.PC) + Int16(data)
            return UInt16(bitPattern: result)
        case .indirect:
            let low = memory.readWord(addr: registers.PC)
            let high = low & 0xFF00 + ((low + 1) & 0x00FF)  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            return UInt16(memory.read(addr: low)) + UInt16(memory.read(addr: high)) << 8
        case .indexedIndirect:
            let low = (UInt16(memory.read(addr: registers.PC)) + UInt16(registers.X)) & 0x00FF
            let high = (low + 1) & 0x00FF  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            return UInt16(memory.read(addr: low)) + UInt16(memory.read(addr: high)) << 8
        case .indirectIndexed:
            let low = UInt16(memory.read(addr: registers.PC))
            let high = (low + 1) & 0x00FF  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
            let base = UInt16(memory.read(addr: low)) + UInt16(memory.read(addr: high)) << 8
            return base + UInt16(registers.Y)
        }
    }
}
