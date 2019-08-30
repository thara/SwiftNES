struct Instruction {
    let opcode: UInt8
    let mnemonic: Mnemonic
    let addressingMode: AddressingMode
    let fetchOperand: AddressingMode.FetchOperand
    let exec: Operation
}

extension CPU {

    func buildInstructionTable() -> [Instruction] {
        var table: [Instruction?] = Array(repeating: nil, count: 0x100)
        for i in 0x00...0xFF {
            let opcode = UInt8(i)

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
            return (.LDA, .absoluteX(extraCycle: true), loadAccumulator)
        case 0xB9:
            return (.LDA, .absoluteY(extraCycle: true), loadAccumulator)
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
            return (.LDX, .absoluteY(extraCycle: true), loadXRegister)
        case 0xA0:
            return (.LDY, .immediate, loadYRegister)
        case 0xA4:
            return (.LDY, .zeroPage, loadYRegister)
        case 0xB4:
            return (.LDY, .zeroPageX, loadYRegister)
        case 0xAC:
            return (.LDY, .absolute, loadYRegister)
        case 0xBC:
            return (.LDY, .absoluteX(extraCycle: true), loadYRegister)
        case 0x85:
            return (.STA, .zeroPage, storeAccumulator)
        case 0x95:
            return (.STA, .zeroPageX, storeAccumulator)
        case 0x8D:
            return (.STA, .absolute, storeAccumulator)
        case 0x9D:
            return (.STA, .absoluteX(extraCycle: false), storeAccumulator)
        case 0x99:
            return (.STA, .absoluteY(extraCycle: false), storeAccumulator)
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
            return (.AND, .absoluteX(extraCycle: true), bitwiseANDwithAccumulator)
        case 0x39:
            return (.AND, .absoluteY(extraCycle: true), bitwiseANDwithAccumulator)
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
            return (.EOR, .absoluteX(extraCycle: true), bitwiseExclusiveOR)
        case 0x59:
            return (.EOR, .absoluteY(extraCycle: true), bitwiseExclusiveOR)
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
            return (.ORA, .absoluteX(extraCycle: true), bitwiseORwithAccumulator)
        case 0x19:
            return (.ORA, .absoluteY(extraCycle: true), bitwiseORwithAccumulator)
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
            return (.ADC, .absoluteX(extraCycle: true), addWithCarry)
        case 0x79:
            return (.ADC, .absoluteY(extraCycle: true), addWithCarry)
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
            return (.SBC, .absoluteX(extraCycle: true), subtractWithCarry)
        case 0xF9:
            return (.SBC, .absoluteY(extraCycle: true), subtractWithCarry)
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
            return (.CMP, .absoluteX(extraCycle: true), compareAccumulator)
        case 0xD9:
            return (.CMP, .absoluteY(extraCycle: true), compareAccumulator)
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
            return (.INC, .absoluteX(extraCycle: false), incrementMemory)
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
            return (.DEC, .absoluteX(extraCycle: false), decrementMemory)
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
            return (.ASL, .absoluteX(extraCycle: false), arithmeticShiftLeft)
        case 0x4A:
            return (.LSR, .accumulator, logicalShiftRightForAccumulator)
        case 0x46:
            return (.LSR, .zeroPage, logicalShiftRight)
        case 0x56:
            return (.LSR, .zeroPageX, logicalShiftRight)
        case 0x4E:
            return (.LSR, .absolute, logicalShiftRight)
        case 0x5E:
            return (.LSR, .absoluteX(extraCycle: false), logicalShiftRight)
        case 0x2A:
            return (.ROL, .accumulator, rotateLeftForAccumulator)
        case 0x26:
            return (.ROL, .zeroPage, rotateLeft)
        case 0x36:
            return (.ROL, .zeroPageX, rotateLeft)
        case 0x2E:
            return (.ROL, .absolute, rotateLeft)
        case 0x3E:
            return (.ROL, .absoluteX(extraCycle: false), rotateLeft)
        case 0x6A:
            return (.ROR, .accumulator, rotateRightForAccumulator)
        case 0x66:
            return (.ROR, .zeroPage, rotateRight)
        case 0x76:
            return (.ROR, .zeroPageX, rotateRight)
        case 0x6E:
            return (.ROR, .absolute, rotateRight)
        case 0x7E:
            return (.ROR, .absoluteX(extraCycle: false), rotateRight)

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
            return (.NOP, .absoluteX(extraCycle: true), doNothing)
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
            return (.LAX, .absoluteY(extraCycle: true), loadAccumulatorAndX)

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
            return (.DCP, .absoluteY(extraCycle: false), decrementMemoryAndCompareAccumulator)
        case 0xDF:
            return (.DCP, .absoluteX(extraCycle: false), decrementMemoryAndCompareAccumulator)

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
            return (.ISB, .absoluteY(extraCycle: false), incrementMemoryAndSubtractWithCarry)
        case 0xFF:
            return (.ISB, .absoluteX(extraCycle: false), incrementMemoryAndSubtractWithCarry)

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
            return (.SLO, .absoluteY(extraCycle: false), arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x1F:
            return (.SLO, .absoluteX(extraCycle: false), arithmeticShiftLeftAndBitwiseORwithAccumulator)

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
            return (.RLA, .absoluteY(extraCycle: false), rotateLeftAndBitwiseANDwithAccumulator)
        case 0x3F:
            return (.RLA, .absoluteX(extraCycle: false), rotateLeftAndBitwiseANDwithAccumulator)

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
            return (.SRE, .absoluteY(extraCycle: false), logicalShiftRightAndBitwiseExclusiveOR)
        case 0x5F:
            return (.SRE, .absoluteX(extraCycle: false), logicalShiftRightAndBitwiseExclusiveOR)

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
            return (.RRA, .absoluteY(extraCycle: false), rotateRightAndAddWithCarry)
        case 0x7F:
            return (.RRA, .absoluteX(extraCycle: false), rotateRightAndAddWithCarry)

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
        case .absoluteX(let extraCycle):
            return extraCycle ? absoluteXWithExtraCycle : absoluteX
        case .absoluteY(let extraCycle):
            return extraCycle ? absoluteYWithExtraCycle : absoluteY
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
