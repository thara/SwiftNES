// swiftlint:disable file_length

struct Instruction {
    let opcode: OpCode
    let mnemonic: Mnemonic
    let addressingMode: AddressingMode
    let fetchOperand: AddressingMode.FetchOperand
    let exec: Operation
}

extension CPU {

    func buildInstructionTable() -> [Instruction] {
        var table: [Instruction?] = Array(repeating: nil, count: 0x100)
        for i in 0x00...0xFF {
            let opcode = OpCode(i)

            let (mnemonic, addressingMode, operation) = decodeInstruction(for: opcode)
            table[i] = Instruction(
                opcode: opcode, mnemonic: mnemonic, addressingMode: addressingMode,
                fetchOperand: decodeToFetchOperand(addressingMode: addressingMode),
                exec: operation)
        }
        return table.compactMap { $0 }
    }

    // swiftlint:disable cyclomatic_complexity function_body_length line_length
    private func decodeInstruction(for opcode: UInt8) -> (Mnemonic, AddressingMode, Operation) {
        switch opcode {

        case 0xA9:
            return (.LDA, .immediate, loadAccumulator)
        case 0xA5:
            return (.LDA, .zeroPage, loadAccumulator)
        case 0xB5:
            return (.LDA, .zeroPageX, loadAccumulator)
        case 0xAD:
            return (.LDA, .absolute, loadAccumulator)
        case 0xBD:
            return (.LDA, .absoluteX(cycles: .onlyIfPageCrossed), loadAccumulator)
        case 0xB9:
            return (.LDA, .absoluteY(cycles: .onlyIfPageCrossed), loadAccumulator)
        case 0xA1:
            return (.LDA, .indexedIndirect, loadAccumulator)
        case 0xB1:
            return (.LDA, .indirectIndexed, loadAccumulator)
        case 0xA2:
            return (.LDX, .immediate, loadXRegister)
        case 0xA6:
            return (.LDX, .zeroPage, loadXRegister)
        case 0xB6:
            return (.LDX, .zeroPageY, loadXRegister)
        case 0xAE:
            return (.LDX, .absolute, loadXRegister)
        case 0xBE:
            return (.LDX, .absoluteY(cycles: .onlyIfPageCrossed), loadXRegister)
        case 0xA0:
            return (.LDY, .immediate, loadYRegister)
        case 0xA4:
            return (.LDY, .zeroPage, loadYRegister)
        case 0xB4:
            return (.LDY, .zeroPageX, loadYRegister)
        case 0xAC:
            return (.LDY, .absolute, loadYRegister)
        case 0xBC:
            return (.LDY, .absoluteX(cycles: .onlyIfPageCrossed), loadYRegister)
        case 0x85:
            return (.STA, .zeroPage, storeAccumulator)
        case 0x95:
            return (.STA, .zeroPageX, storeAccumulator)
        case 0x8D:
            return (.STA, .absolute, storeAccumulator)
        case 0x9D:
            return (.STA, .absoluteX(cycles: .fixed), storeAccumulator)
        case 0x99:
            return (.STA, .absoluteY(cycles: .fixed), storeAccumulator)
        case 0x81:
            return (.STA, .indexedIndirect, storeAccumulator)
        case 0x91:
            return (.STA, .indirectIndexed, storeAccumulatorWithTick)
        case 0x86:
            return (.STX, .zeroPage, storeXRegister)
        case 0x96:
            return (.STX, .zeroPageY, storeXRegister)
        case 0x8E:
            return (.STX, .absolute, storeXRegister)
        case 0x84:
            return (.STY, .zeroPage, storeYRegister)
        case 0x94:
            return (.STY, .zeroPageX, storeYRegister)
        case 0x8C:
            return (.STY, .absolute, storeYRegister)
        case 0xAA:
            return (.TAX, .implicit, transferAccumulatorToX)
        case 0xBA:
            return (.TSX, .implicit, transferStackPointerToX)
        case 0xA8:
            return (.TAY, .implicit, transferAccumulatorToY)
        case 0x8A:
            return (.TXA, .implicit, transferXtoAccumulator)
        case 0x9A:
            return (.TXS, .implicit, transferXtoStackPointer)
        case 0x98:
            return (.TYA, .implicit, transferYtoAccumulator)

        case 0x48:
            return (.PHA, .implicit, pushAccumulator)
        case 0x08:
            return (.PHP, .implicit, pushProcessorStatus)
        case 0x68:
            return (.PLA, .implicit, pullAccumulator)
        case 0x28:
            return (.PLP, .implicit, pullProcessorStatus)

        case 0x29:
            return (.AND, .immediate, bitwiseANDwithAccumulator)
        case 0x25:
            return (.AND, .zeroPage, bitwiseANDwithAccumulator)
        case 0x35:
            return (.AND, .zeroPageX, bitwiseANDwithAccumulator)
        case 0x2D:
            return (.AND, .absolute, bitwiseANDwithAccumulator)
        case 0x3D:
            return (.AND, .absoluteX(cycles: .onlyIfPageCrossed), bitwiseANDwithAccumulator)
        case 0x39:
            return (.AND, .absoluteY(cycles: .onlyIfPageCrossed), bitwiseANDwithAccumulator)
        case 0x21:
            return (.AND, .indexedIndirect, bitwiseANDwithAccumulator)
        case 0x31:
            return (.AND, .indirectIndexed, bitwiseANDwithAccumulator)
        case 0x49:
            return (.EOR, .immediate, bitwiseExclusiveOR)
        case 0x45:
            return (.EOR, .zeroPage, bitwiseExclusiveOR)
        case 0x55:
            return (.EOR, .zeroPageX, bitwiseExclusiveOR)
        case 0x4D:
            return (.EOR, .absolute, bitwiseExclusiveOR)
        case 0x5D:
            return (.EOR, .absoluteX(cycles: .onlyIfPageCrossed), bitwiseExclusiveOR)
        case 0x59:
            return (.EOR, .absoluteY(cycles: .onlyIfPageCrossed), bitwiseExclusiveOR)
        case 0x41:
            return (.EOR, .indexedIndirect, bitwiseExclusiveOR)
        case 0x51:
            return (.EOR, .indirectIndexed, bitwiseExclusiveOR)
        case 0x09:
            return (.ORA, .immediate, bitwiseORwithAccumulator)
        case 0x05:
            return (.ORA, .zeroPage, bitwiseORwithAccumulator)
        case 0x15:
            return (.ORA, .zeroPageX, bitwiseORwithAccumulator)
        case 0x0D:
            return (.ORA, .absolute, bitwiseORwithAccumulator)
        case 0x1D:
            return (.ORA, .absoluteX(cycles: .onlyIfPageCrossed), bitwiseORwithAccumulator)
        case 0x19:
            return (.ORA, .absoluteY(cycles: .onlyIfPageCrossed), bitwiseORwithAccumulator)
        case 0x01:
            return (.ORA, .indexedIndirect, bitwiseORwithAccumulator)
        case 0x11:
            return (.ORA, .indirectIndexed, bitwiseORwithAccumulator)
        case 0x24:
            return (.BIT, .zeroPage, testBits)
        case 0x2C:
            return (.BIT, .absolute, testBits)

        case 0x69:
            return (.ADC, .immediate, addWithCarry)
        case 0x65:
            return (.ADC, .zeroPage, addWithCarry)
        case 0x75:
            return (.ADC, .zeroPageX, addWithCarry)
        case 0x6D:
            return (.ADC, .absolute, addWithCarry)
        case 0x7D:
            return (.ADC, .absoluteX(cycles: .onlyIfPageCrossed), addWithCarry)
        case 0x79:
            return (.ADC, .absoluteY(cycles: .onlyIfPageCrossed), addWithCarry)
        case 0x61:
            return (.ADC, .indexedIndirect, addWithCarry)
        case 0x71:
            return (.ADC, .indirectIndexed, addWithCarry)
        case 0xE9:
            return (.SBC, .immediate, subtractWithCarry)
        case 0xE5:
            return (.SBC, .zeroPage, subtractWithCarry)
        case 0xF5:
            return (.SBC, .zeroPageX, subtractWithCarry)
        case 0xED:
            return (.SBC, .absolute, subtractWithCarry)
        case 0xFD:
            return (.SBC, .absoluteX(cycles: .onlyIfPageCrossed), subtractWithCarry)
        case 0xF9:
            return (.SBC, .absoluteY(cycles: .onlyIfPageCrossed), subtractWithCarry)
        case 0xE1:
            return (.SBC, .indexedIndirect, subtractWithCarry)
        case 0xF1:
            return (.SBC, .indirectIndexed, subtractWithCarry)
        case 0xC9:
            return (.CMP, .immediate, compareAccumulator)
        case 0xC5:
            return (.CMP, .zeroPage, compareAccumulator)
        case 0xD5:
            return (.CMP, .zeroPageX, compareAccumulator)
        case 0xCD:
            return (.CMP, .absolute, compareAccumulator)
        case 0xDD:
            return (.CMP, .absoluteX(cycles: .onlyIfPageCrossed), compareAccumulator)
        case 0xD9:
            return (.CMP, .absoluteY(cycles: .onlyIfPageCrossed), compareAccumulator)
        case 0xC1:
            return (.CMP, .indexedIndirect, compareAccumulator)
        case 0xD1:
            return (.CMP, .indirectIndexed, compareAccumulator)
        case 0xE0:
            return (.CPX, .immediate, compareXRegister)
        case 0xE4:
            return (.CPX, .zeroPage, compareXRegister)
        case 0xEC:
            return (.CPX, .absolute, compareXRegister)
        case 0xC0:
            return (.CPY, .immediate, compareYRegister)
        case 0xC4:
            return (.CPY, .zeroPage, compareYRegister)
        case 0xCC:
            return (.CPY, .absolute, compareYRegister)

        case 0xE6:
            return (.INC, .zeroPage, incrementMemory)
        case 0xF6:
            return (.INC, .zeroPageX, incrementMemory)
        case 0xEE:
            return (.INC, .absolute, incrementMemory)
        case 0xFE:
            return (.INC, .absoluteX(cycles: .fixed), incrementMemory)
        case 0xE8:
            return (.INX, .implicit, incrementX)
        case 0xC8:
            return (.INY, .implicit, incrementY)
        case 0xC6:
            return (.DEC, .zeroPage, decrementMemory)
        case 0xD6:
            return (.DEC, .zeroPageX, decrementMemory)
        case 0xCE:
            return (.DEC, .absolute, decrementMemory)
        case 0xDE:
            return (.DEC, .absoluteX(cycles: .fixed), decrementMemory)
        case 0xCA:
            return (.DEX, .implicit, decrementX)
        case 0x88:
            return (.DEY, .implicit, decrementY)

        case 0x0A:
            return (.ASL, .accumulator, arithmeticShiftLeftForAccumulator)
        case 0x06:
            return (.ASL, .zeroPage, arithmeticShiftLeft)
        case 0x16:
            return (.ASL, .zeroPageX, arithmeticShiftLeft)
        case 0x0E:
            return (.ASL, .absolute, arithmeticShiftLeft)
        case 0x1E:
            return (.ASL, .absoluteX(cycles: .fixed), arithmeticShiftLeft)
        case 0x4A:
            return (.LSR, .accumulator, logicalShiftRightForAccumulator)
        case 0x46:
            return (.LSR, .zeroPage, logicalShiftRight)
        case 0x56:
            return (.LSR, .zeroPageX, logicalShiftRight)
        case 0x4E:
            return (.LSR, .absolute, logicalShiftRight)
        case 0x5E:
            return (.LSR, .absoluteX(cycles: .fixed), logicalShiftRight)
        case 0x2A:
            return (.ROL, .accumulator, rotateLeftForAccumulator)
        case 0x26:
            return (.ROL, .zeroPage, rotateLeft)
        case 0x36:
            return (.ROL, .zeroPageX, rotateLeft)
        case 0x2E:
            return (.ROL, .absolute, rotateLeft)
        case 0x3E:
            return (.ROL, .absoluteX(cycles: .fixed), rotateLeft)
        case 0x6A:
            return (.ROR, .accumulator, rotateRightForAccumulator)
        case 0x66:
            return (.ROR, .zeroPage, rotateRight)
        case 0x76:
            return (.ROR, .zeroPageX, rotateRight)
        case 0x6E:
            return (.ROR, .absolute, rotateRight)
        case 0x7E:
            return (.ROR, .absoluteX(cycles: .fixed), rotateRight)

        case 0x4C:
            return (.JMP, .absolute, jump)
        case 0x6C:
            return (.JMP, .indirect, jump)
        case 0x20:
            return (.JSR, .absolute, jumpToSubroutine)
        case 0x60:
            return (.RTS, .implicit, returnFromSubroutine)
        case 0x40:
            return (.RTI, .implicit, returnFromInterrupt)

        case 0x90:
            return (.BCC, .relative, branchIfCarryClear)
        case 0xB0:
            return (.BCS, .relative, branchIfCarrySet)
        case 0xF0:
            return (.BEQ, .relative, branchIfEqual)
        case 0x30:
            return (.BMI, .relative, branchIfMinus)
        case 0xD0:
            return (.BNE, .relative, branchIfNotEqual)
        case 0x10:
            return (.BPL, .relative, branchIfPlus)
        case 0x50:
            return (.BVC, .relative, branchIfOverflowClear)
        case 0x70:
            return (.BVS, .relative, branchIfOverflowSet)

        case 0x18:
            return (.CLC, .implicit, clearCarry)
        case 0xD8:
            return (.CLD, .implicit, clearDecimal)
        case 0x58:
            return (.CLI, .implicit, clearInterrupt)
        case 0xB8:
            return (.CLV, .implicit, clearOverflow)

        case 0x38:
            return (.SEC, .implicit, setCarryFlag)
        case 0xF8:
            return (.SED, .implicit, setDecimalFlag)
        case 0x78:
            return (.SEI, .implicit, setInterruptDisable)

        case 0x00:
            return (.BRK, .implicit, forceInterrupt)

        // Undocumented

        case 0xEB:
            return (.SBC, .immediate, subtractWithCarry)

        case 0x04, 0x44, 0x64:
            return (.NOP, .zeroPage, doNothing)
        case 0x0C:
            return (.NOP, .absolute, doNothing)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            return (.NOP, .zeroPageX, doNothing)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            return (.NOP, .implicit, doNothing)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            return (.NOP, .absoluteX(cycles: .onlyIfPageCrossed), doNothing)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            return (.NOP, .immediate, doNothing)

        case 0xA3:
            return (.LAX, .indexedIndirect, loadAccumulatorAndX)
        case 0xA7:
            return (.LAX, .zeroPage, loadAccumulatorAndX)
        case 0xAF:
            return (.LAX, .absolute, loadAccumulatorAndX)
        case 0xB3:
            return (.LAX, .indirectIndexed, loadAccumulatorAndX)
        case 0xB7:
            return (.LAX, .zeroPageY, loadAccumulatorAndX)
        case 0xBF:
            return (.LAX, .absoluteY(cycles: .onlyIfPageCrossed), loadAccumulatorAndX)

        case 0x83:
            return (.SAX, .indexedIndirect, storeAccumulatorAndX)
        case 0x87:
            return (.SAX, .zeroPage, storeAccumulatorAndX)
        case 0x8F:
            return (.SAX, .absolute, storeAccumulatorAndX)
        case 0x97:
            return (.SAX, .zeroPageY, storeAccumulatorAndX)

        case 0xC3:
            return (.DCP, .indexedIndirect, decrementMemoryAndCompareAccumulator)
        case 0xC7:
            return (.DCP, .zeroPage, decrementMemoryAndCompareAccumulator)
        case 0xCF:
            return (.DCP, .absolute, decrementMemoryAndCompareAccumulator)
        case 0xD3:
            return (.DCP, .indirectIndexed, decrementMemoryAndCompareAccumulator)
        case 0xD7:
            return (.DCP, .zeroPageX, decrementMemoryAndCompareAccumulator)
        case 0xDB:
            return (.DCP, .absoluteY(cycles: .fixed), decrementMemoryAndCompareAccumulator)
        case 0xDF:
            return (.DCP, .absoluteX(cycles: .fixed), decrementMemoryAndCompareAccumulator)

        case 0xE3:
            return (.ISB, .indexedIndirect, incrementMemoryAndSubtractWithCarry)
        case 0xE7:
            return (.ISB, .zeroPage, incrementMemoryAndSubtractWithCarry)
        case 0xEF:
            return (.ISB, .absolute, incrementMemoryAndSubtractWithCarry)
        case 0xF3:
            return (.ISB, .indirectIndexed, incrementMemoryAndSubtractWithCarry)
        case 0xF7:
            return (.ISB, .zeroPageX, incrementMemoryAndSubtractWithCarry)
        case 0xFB:
            return (.ISB, .absoluteY(cycles: .fixed), incrementMemoryAndSubtractWithCarry)
        case 0xFF:
            return (.ISB, .absoluteX(cycles: .fixed), incrementMemoryAndSubtractWithCarry)

        case 0x03:
            return (.SLO, .indexedIndirect, arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x07:
            return (.SLO, .zeroPage, arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x0F:
            return (.SLO, .absolute, arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x13:
            return (.SLO, .indirectIndexed, arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x17:
            return (.SLO, .zeroPageX, arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x1B:
            return (.SLO, .absoluteY(cycles: .fixed), arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x1F:
            return (.SLO, .absoluteX(cycles: .fixed), arithmeticShiftLeftAndBitwiseORwithAccumulator)

        case 0x23:
            return (.RLA, .indexedIndirect, rotateLeftAndBitwiseANDwithAccumulator)
        case 0x27:
            return (.RLA, .zeroPage, rotateLeftAndBitwiseANDwithAccumulator)
        case 0x2F:
            return (.RLA, .absolute, rotateLeftAndBitwiseANDwithAccumulator)
        case 0x33:
            return (.RLA, .indirectIndexed, rotateLeftAndBitwiseANDwithAccumulator)
        case 0x37:
            return (.RLA, .zeroPageX, rotateLeftAndBitwiseANDwithAccumulator)
        case 0x3B:
            return (.RLA, .absoluteY(cycles: .fixed), rotateLeftAndBitwiseANDwithAccumulator)
        case 0x3F:
            return (.RLA, .absoluteX(cycles: .fixed), rotateLeftAndBitwiseANDwithAccumulator)

        case 0x43:
            return (.SRE, .indexedIndirect, logicalShiftRightAndBitwiseExclusiveOR)
        case 0x47:
            return (.SRE, .zeroPage, logicalShiftRightAndBitwiseExclusiveOR)
        case 0x4F:
            return (.SRE, .absolute, logicalShiftRightAndBitwiseExclusiveOR)
        case 0x53:
            return (.SRE, .indirectIndexed, logicalShiftRightAndBitwiseExclusiveOR)
        case 0x57:
            return (.SRE, .zeroPageX, logicalShiftRightAndBitwiseExclusiveOR)
        case 0x5B:
            return (.SRE, .absoluteY(cycles: .fixed), logicalShiftRightAndBitwiseExclusiveOR)
        case 0x5F:
            return (.SRE, .absoluteX(cycles: .fixed), logicalShiftRightAndBitwiseExclusiveOR)

        case 0x63:
            return (.RRA, .indexedIndirect, rotateRightAndAddWithCarry)
        case 0x67:
            return (.RRA, .zeroPage, rotateRightAndAddWithCarry)
        case 0x6F:
            return (.RRA, .absolute, rotateRightAndAddWithCarry)
        case 0x73:
            return (.RRA, .indirectIndexed, rotateRightAndAddWithCarry)
        case 0x77:
            return (.RRA, .zeroPageX, rotateRightAndAddWithCarry)
        case 0x7B:
            return (.RRA, .absoluteY(cycles: .fixed), rotateRightAndAddWithCarry)
        case 0x7F:
            return (.RRA, .absoluteX(cycles: .fixed), rotateRightAndAddWithCarry)

        default:
            return (.NOP, .implicit, doNothing)
        }
    }

    fileprivate func decodeToFetchOperand(addressingMode: AddressingMode) -> AddressingMode.FetchOperand {
        switch addressingMode {
        case .implicit:
            return implicit
        case .accumulator:
            return accumulator
        case .immediate:
            return immediate
        case .zeroPage:
            return zeroPage
        case .zeroPageX:
            return zeroPageX
        case .zeroPageY:
            return zeroPageY
        case .absolute:
            return absolute
        case .absoluteX(let cycles):
            switch cycles {
            case .fixed:
                return absoluteX
            case .onlyIfPageCrossed:
                return absoluteXWithPenalty
            }
        case .absoluteY(let cycles):
            switch cycles {
            case .fixed:
                return absoluteY
            case .onlyIfPageCrossed:
                return absoluteYWithPenalty
            }
        case .relative:
            return relative
        case .indirect:
            return indirect
        case .indexedIndirect:
            return indexedIndirect
        case .indirectIndexed:
            return indirectIndexed
        }
    }
}

// MARK: - Addressing Mode
extension CPU {

    func implicit() -> UInt16 {
        return 0x00
    }

    func accumulator() -> UInt16 {
        return registers.A.u16
    }

    func immediate() -> UInt16 {
        let operand = registers.PC
        registers.PC &+= 1
        return operand
    }

    func zeroPage() -> UInt16 {
        let operand = read(at: registers.PC).u16 & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageX() -> UInt16 {
        tick()

        let operand = (read(at: registers.PC).u16 &+ registers.X.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageY() -> UInt16 {
        tick()

        let operand = (read(at: registers.PC).u16 &+ registers.Y.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func absolute() -> UInt16 {
        let operand = readWord(at: registers.PC)
        registers.PC &+= 2
        return operand
    }

    func absoluteX() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.X.u16 & 0xFFFF
        registers.PC &+= 2
        tick()
        return operand
    }

    func absoluteXWithPenalty() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.X.u16 & 0xFFFF
        registers.PC &+= 2

        tickOnPageCrossed(value: data, operand: registers.X)
        return operand
    }

    func absoluteY() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.Y.u16 & 0xFFFF
        registers.PC &+= 2
        tick()
        return operand
    }

    func absoluteYWithPenalty() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.Y.u16 & 0xFFFF
        registers.PC &+= 2

        tickOnPageCrossed(value: data, operand: registers.Y)
        return operand
    }

    func relative() -> UInt16 {
        let operand = read(at: registers.PC).u16
        registers.PC &+= 1
        return operand
    }

    func indirect() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = readOnIndirect(operand: data)
        registers.PC &+= 2
        return operand
    }

    func indexedIndirect() -> UInt16 {
        let data = read(at: registers.PC)
        let operand = readOnIndirect(operand: (data &+ registers.X).u16 & 0xFF)
        registers.PC &+= 1

        tick()

        return operand
    }

    func indirectIndexed() -> UInt16 {
        let data = read(at: registers.PC).u16
        let operand = readOnIndirect(operand: data) &+ registers.Y.u16
        registers.PC &+= 1

        tickOnPageCrossed(value: operand &- registers.Y.u16, operand: registers.Y)
        return operand
    }

    func tickOnPageCrossed(value: UInt16, operand: UInt8) {
        tickOnPageCrossed(value: value, operand: operand.u16)
    }

    func tickOnPageCrossed(value: UInt16, operand: UInt16) {
        if ((value &+ operand) & 0xFF00) != (value & 0xFF00) {
            tick()
        }
    }

    func tickOnPageCrossed(value: Int, operand: Int) {
        if ((value &+ operand) & 0xFF00) != (value & 0xFF00) {
            tick()
        }
    }
}

extension Memory {
    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}

// MARK: - Operations
extension CPU {
    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand) -> NextPC {
        registers.A = read(at: operand)
        return registers.PC
    }

    /// LDX
    func loadXRegister(operand: Operand) -> NextPC {
        registers.X = read(at: operand)
        return registers.PC
    }

    /// LDY
    func loadYRegister(operand: Operand) -> NextPC {
        registers.Y = read(at: operand)
        return registers.PC
    }

    /// STA
    func storeAccumulator(operand: Operand) -> NextPC {
        write(registers.A, at: operand)
        return registers.PC
    }

    func storeAccumulatorWithTick(operand: Operand) -> NextPC {
        write(registers.A, at: operand)
        tick()
        return registers.PC
    }

    /// STX
    func storeXRegister(operand: Operand) -> NextPC {
        write(registers.X, at: operand)
        return registers.PC
    }

    /// STY
    func storeYRegister(operand: Operand) -> NextPC {
        write(registers.Y, at: operand)
        return registers.PC
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand) -> NextPC {
        registers.X = registers.A
        tick()
        return registers.PC
    }

    /// TSX
    func transferStackPointerToX(operand: Operand) -> NextPC {
        registers.X = registers.S
        tick()
        return registers.PC
    }

    /// TAY
    func transferAccumulatorToY(operand: Operand) -> NextPC {
        registers.Y = registers.A
        tick()
        return registers.PC
    }

    /// TXA
    func transferXtoAccumulator(operand: Operand) -> NextPC {
        registers.A = registers.X
        tick()
        return registers.PC
    }

    /// TXS
    func transferXtoStackPointer(operand: Operand) -> NextPC {
        registers.S = registers.X
        tick()
        return registers.PC
    }

    /// TYA
    func transferYtoAccumulator(operand: Operand) -> NextPC {
        registers.A = registers.Y
        tick()
        return registers.PC
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand) -> NextPC {
        pushStack(registers.A)
        tick()
        return registers.PC
    }

    /// PHP
    func pushProcessorStatus(operand: Operand) -> NextPC {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.operatedB.rawValue)
        tick()
        return registers.PC
    }

    /// PLA
    func pullAccumulator(operand: Operand) -> NextPC {
        registers.A = pullStack()
        tick(count: 2)
        return registers.PC
    }

    /// PLP
    func pullProcessorStatus(operand: Operand) -> NextPC {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        tick(count: 2)
        return registers.PC
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand) -> NextPC {
        registers.A &= read(at: operand)
        return registers.PC
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand) -> NextPC {
        registers.A ^= read(at: operand)
        return registers.PC
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand) -> NextPC {
        registers.A |= read(at: operand)
        return registers.PC
    }

    /// BIT
    func testBits(operand: Operand) -> NextPC {
        let value = read(at: operand)
        let data = registers.A & value
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) } else { registers.P.remove(.Z) }
        if value[6] == 1 { registers.P.formUnion(.V) } else { registers.P.remove(.V) }
        if value[7] == 1 { registers.P.formUnion(.N) } else { registers.P.remove(.N) }
        return registers.PC
    }

    // MARK: - Arithmetic instructions

    /// ADC
    func addWithCarry(operand: Operand) -> NextPC {
        let a = registers.A
        let val = read(at: operand)
        var result = a &+ val

        if registers.P.contains(.C) { result &+= 1 }

        registers.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { registers.P.formUnion(.C) }
        if c6 ^ c7 == 1 { registers.P.formUnion(.V) }

        registers.A = result
        return registers.PC
    }

    /// SBC
    func subtractWithCarry(operand: Operand) -> NextPC {
        let a = registers.A
        let val = ~read(at: operand)
        var result = a &+ val

        if registers.P.contains(.C) { result &+= 1 }

        registers.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { registers.P.formUnion(.C) }
        if c6 ^ c7 == 1 { registers.P.formUnion(.V) }

        registers.A = result
        return registers.PC
    }

    /// CMP
    func compareAccumulator(operand: Operand) -> NextPC {
        let cmp = Int16(registers.A) &- Int16(read(at: operand))

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if 0 <= cmp { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return registers.PC
    }

    /// CPX
    func compareXRegister(operand: Operand) -> NextPC {
        let value = read(at: operand)
        let cmp = registers.X &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.X >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return registers.PC
    }

    /// CPY
    func compareYRegister(operand: Operand) -> NextPC {
        let value = read(at: operand)
        let cmp = registers.Y &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.Y >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return registers.PC
    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand) -> NextPC {
        let result = read(at: operand) &+ 1

        registers.P.setZN(result)
        write(result, at: operand)

        tick()

        return registers.PC
    }

    /// INX
    func incrementX(_: Operand) -> NextPC {
        registers.X = registers.X &+ 1
        tick()
        return registers.PC
    }

    /// INY
    func incrementY(operand: Operand) -> NextPC {
        registers.Y = registers.Y &+ 1
        tick()
        return registers.PC
    }

    /// DEC
    func decrementMemory(operand: Operand) -> NextPC {
        let result = read(at: operand) &- 1

        registers.P.setZN(result)

        write(result, at: operand)

        tick()

        return registers.PC
    }

    /// DEX
    func decrementX(operand: Operand) -> NextPC {
        registers.X = registers.X &- 1
        tick()
        return registers.PC
    }

    /// DEY
    func decrementY(operand: Operand) -> NextPC {
        registers.Y = registers.Y &- 1
        tick()
        return registers.PC
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand) -> NextPC {
        var data = read(at: operand)

        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand) -> NextPC {
        registers.P.remove([.C, .Z, .N])
        if registers.A[7] == 1 { registers.P.formUnion(.C) }

        registers.A <<= 1

        tick()
        return registers.PC
    }

    /// LSR
    func logicalShiftRight(operand: Operand) -> NextPC {
        var data = read(at: operand)

        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func logicalShiftRightForAccumulator(operand: Operand) -> NextPC {
        registers.P.remove([.C, .Z, .N])
        if registers.A[0] == 1 { registers.P.formUnion(.C) }

        registers.A >>= 1

        tick()
        return registers.PC
    }

    /// ROL
    func rotateLeft(operand: Operand) -> NextPC {
        var data = read(at: operand)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func rotateLeftForAccumulator(_: Operand) -> NextPC {
        let c = registers.A & 0x80

        var a = registers.A << 1
        if registers.P.contains(.C) { a |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
        return registers.PC
    }

    /// ROR
    func rotateRight(operand: Operand) -> NextPC {
        var data = read(at: operand)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func rotateRightForAccumulator(operand: Operand) -> NextPC {
        let c = registers.A & 0x01

        var a = registers.A >> 1
        if registers.P.contains(.C) { a |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
        return registers.PC
    }

    // MARK: - Jump instructions

    /// JMP
    func jump(operand: Operand) -> NextPC {
        return operand
    }

    /// JSR
    func jumpToSubroutine(operand: Operand) -> NextPC {
        pushStack(word: registers.PC &- 1)
        tick()
        return operand
    }

    /// RTS
    func returnFromSubroutine(operand: Operand) -> NextPC {
        tick(count: 3)
        return pullStack() &+ 1
    }

    /// RTI
    func returnFromInterrupt(operand: Operand) -> NextPC {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        tick(count: 2)
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        return pullStack()
    }

    // MARK: - Branch instructions

    fileprivate func branch(operand: Operand, test: Bool) -> NextPC {
        if test {
            tick()
            let pc = Int(registers.PC)
            let offset = Int(operand.i8)
            tickOnPageCrossed(value: pc, operand: offset)
            return UInt16(pc &+ offset)
        }
        return registers.PC
    }

    /// BCC
    func branchIfCarryClear(operand: Operand) -> NextPC {
        return branch(operand: operand, test: !registers.P.contains(.C))
    }

    /// BCS
    func branchIfCarrySet(operand: Operand) -> NextPC {
        return branch(operand: operand, test: registers.P.contains(.C))
    }

    /// BEQ
    func branchIfEqual(operand: Operand) -> NextPC {
        return branch(operand: operand, test: registers.P.contains(.Z))
    }

    /// BMI
    func branchIfMinus(operand: Operand) -> NextPC {
        return branch(operand: operand, test: registers.P.contains(.N))
    }

    /// BNE
    func branchIfNotEqual(operand: Operand) -> NextPC {
        return branch(operand: operand, test: !registers.P.contains(.Z))
    }

    /// BPL
    func branchIfPlus(operand: Operand) -> NextPC {
        return branch(operand: operand, test: !registers.P.contains(.N))
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand) -> NextPC {
        return branch(operand: operand, test: !registers.P.contains(.V))
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand) -> NextPC {
        return branch(operand: operand, test: registers.P.contains(.V))
    }

    // MARK: - Flag control instructions

    /// CLC
    func clearCarry(operand: Operand) -> NextPC {
        registers.P.remove(.C)
        tick()
        return registers.PC
    }

    /// CLD
    func clearDecimal(operand: Operand) -> NextPC {
        registers.P.remove(.D)
        tick()
        return registers.PC
    }

    /// CLI
    func clearInterrupt(operand: Operand) -> NextPC {
        registers.P.remove(.I)
        tick()
        return registers.PC
    }

    /// CLV
    func clearOverflow(operand: Operand) -> NextPC {
        registers.P.remove(.V)
        tick()
        return registers.PC
    }

    /// SEC
    func setCarryFlag(operand: Operand) -> NextPC {
        registers.P.formUnion(.C)
        tick()
        return registers.PC
    }

    /// SED
    func setDecimalFlag(operand: Operand) -> NextPC {
        registers.P.formUnion(.D)
        tick()
        return registers.PC
    }

    /// SEI
    func setInterruptDisable(operand: Operand) -> NextPC {
        registers.P.formUnion(.I)
        tick()
        return registers.PC
    }

    // MARK: - Misc

    /// BRK
    func forceInterrupt(operand: Operand) -> NextPC {
        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        tick()
        return readWord(at: 0xFFFE)
    }

    /// NOP
    func doNothing(_ operand: Operand) -> NextPC {
        tick()
        return registers.PC
    }

    // MARK: - Illegal

    /// LAX
    func loadAccumulatorAndX(operand: Operand) -> NextPC {
        let data = read(at: operand)
        registers.A = data
        registers.X = data
        return registers.PC
    }

    /// SAX
    func storeAccumulatorAndX(operand: Operand) -> NextPC {
        write(registers.A & registers.X, at: operand)
        return registers.PC
    }

    /// DCP
    func decrementMemoryAndCompareAccumulator(operand: Operand) -> NextPC {
        // decrementMemory excluding tick
        let result = read(at: operand) &- 1
        registers.P.setZN(result)
        write(result, at: operand)

        return compareAccumulator(operand: operand)
    }

    /// ISB
    func incrementMemoryAndSubtractWithCarry(operand: Operand) -> NextPC {
        // incrementMemory excluding tick
        let result = read(at: operand) &+ 1
        registers.P.setZN(result)
        write(result, at: operand)

        return subtractWithCarry(operand: operand)
    }

    /// SLO
    func arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: Operand) -> NextPC {
        // arithmeticShiftLeft excluding tick
        var data = read(at: operand)
        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1
        registers.P.setZN(data)
        write(data, at: operand)

        return bitwiseORwithAccumulator(operand: operand)
    }

    /// RLA
    func rotateLeftAndBitwiseANDwithAccumulator(operand: Operand) -> NextPC {
        // rotateLeft excluding tick
        var data = read(at: operand)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)
        write(data, at: operand)

        return bitwiseANDwithAccumulator(operand: operand)
    }

    /// SRE
    func logicalShiftRightAndBitwiseExclusiveOR(operand: Operand) -> NextPC {
        // logicalShiftRight excluding tick
        var data = read(at: operand)
        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)
        write(data, at: operand)

        return bitwiseExclusiveOR(operand: operand)
    }

    /// RRA
    func rotateRightAndAddWithCarry(operand: Operand) -> NextPC {
        // rotateRight excluding tick
        var data = read(at: operand)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)
        write(data, at: operand)

        return addWithCarry(operand: operand)
    }
}
