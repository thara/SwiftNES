extension CPU {

    func buildInstructionTable() -> [Instruction?] {
        var table: [Instruction?] = Array(repeating: nil, count: 0x100)
        for i in 0x00...0xFF {
            table[i] = buildInstruction(opcode: UInt8(i))
        }
        return table
    }

    // swiftlint:disable cyclomatic_complexity function_body_length line_length
    private func buildInstruction(opcode: UInt8) -> Instruction? {
        switch opcode {

        case 0xA9:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: immediate, exec: loadAccumulator)
        case 0xA5:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: zeroPage, exec: loadAccumulator)
        case 0xB5:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: zeroPageX, exec: loadAccumulator)
        case 0xAD:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: absolute, exec: loadAccumulator)
        case 0xBD:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: absoluteX, exec: loadAccumulator)
        case 0xB9:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: absoluteY, exec: loadAccumulator)
        case 0xA1:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: indexedIndirect, exec: loadAccumulator)
        case 0xB1:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: indirectIndexed, exec: loadAccumulator)
        case 0xA2:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: immediate, exec: loadXRegister)
        case 0xA6:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: zeroPage, exec: loadXRegister)
        case 0xB6:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: zeroPageY, exec: loadXRegister)
        case 0xAE:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: absolute, exec: loadXRegister)
        case 0xBE:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: absoluteY, exec: loadXRegister)
        case 0xA0:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: immediate, exec: loadYRegister)
        case 0xA4:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: zeroPage, exec: loadYRegister)
        case 0xB4:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: zeroPageX, exec: loadYRegister)
        case 0xAC:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: absolute, exec: loadYRegister)
        case 0xBC:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: absoluteX, exec: loadYRegister)
        case 0x85:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: zeroPage, exec: storeAccumulator)
        case 0x95:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: zeroPageX, exec: storeAccumulator)
        case 0x8D:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: absolute, exec: storeAccumulator)
        case 0x9D:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: absoluteX, exec: storeAccumulator)
        case 0x99:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: absoluteY, exec: storeAccumulator)
        case 0x81:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: indexedIndirect, exec: storeAccumulator)
        case 0x91:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: indirectIndexed, exec: storeAccumulator)
        case 0x86:
            return Instruction(opcode: opcode, mnemonic: .STX, addressingMode: zeroPage, exec: storeXRegister)
        case 0x96:
            return Instruction(opcode: opcode, mnemonic: .STX, addressingMode: zeroPageY, exec: storeXRegister)
        case 0x8E:
            return Instruction(opcode: opcode, mnemonic: .STX, addressingMode: absolute, exec: storeXRegister)
        case 0x84:
            return Instruction(opcode: opcode, mnemonic: .STY, addressingMode: zeroPage, exec: storeYRegister)
        case 0x94:
            return Instruction(opcode: opcode, mnemonic: .STY, addressingMode: zeroPageX, exec: storeYRegister)
        case 0x8C:
            return Instruction(opcode: opcode, mnemonic: .STY, addressingMode: absolute, exec: storeYRegister)
        case 0xAA:
            return Instruction(opcode: opcode, mnemonic: .TAX, addressingMode: implicit, exec: transferAccumulatorToX)
        case 0xBA:
            return Instruction(opcode: opcode, mnemonic: .TSX, addressingMode: implicit, exec: transferStackPointerToX)
        case 0xA8:
            return Instruction(opcode: opcode, mnemonic: .TAY, addressingMode: implicit, exec: transferAccumulatorToY)
        case 0x8A:
            return Instruction(opcode: opcode, mnemonic: .TXA, addressingMode: implicit, exec: transferXtoAccumulator)
        case 0x9A:
            return Instruction(opcode: opcode, mnemonic: .TXS, addressingMode: implicit, exec: transferXtoStackPointer)
        case 0x98:
            return Instruction(opcode: opcode, mnemonic: .TYA, addressingMode: implicit, exec: transferYtoAccumulator)

        case 0x48:
            return Instruction(opcode: opcode, mnemonic: .PHA, addressingMode: implicit, exec: pushAccumulator)
        case 0x08:
            return Instruction(opcode: opcode, mnemonic: .PHP, addressingMode: implicit, exec: pushProcessorStatus)
        case 0x68:
            return Instruction(opcode: opcode, mnemonic: .PLA, addressingMode: implicit, exec: pullAccumulator)
        case 0x28:
            return Instruction(opcode: opcode, mnemonic: .PLP, addressingMode: implicit, exec: pullProcessorStatus)

        case 0x29:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: immediate, exec: bitwiseANDwithAccumulator)
        case 0x25:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: zeroPage, exec: bitwiseANDwithAccumulator)
        case 0x35:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: zeroPageX, exec: bitwiseANDwithAccumulator)
        case 0x2D:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: absolute, exec: bitwiseANDwithAccumulator)
        case 0x3D:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: absoluteX, exec: bitwiseANDwithAccumulator)
        case 0x39:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: absoluteY, exec: bitwiseANDwithAccumulator)
        case 0x21:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: indexedIndirect, exec: bitwiseANDwithAccumulator)
        case 0x31:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: indirectIndexed, exec: bitwiseANDwithAccumulator)
        case 0x49:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: immediate, exec: bitwiseExclusiveOR)
        case 0x45:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: zeroPage, exec: bitwiseExclusiveOR)
        case 0x55:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: zeroPageX, exec: bitwiseExclusiveOR)
        case 0x4D:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: absolute, exec: bitwiseExclusiveOR)
        case 0x5D:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: absoluteX, exec: bitwiseExclusiveOR)
        case 0x59:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: absoluteY, exec: bitwiseExclusiveOR)
        case 0x41:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: indexedIndirect, exec: bitwiseExclusiveOR)
        case 0x51:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: indirectIndexed, exec: bitwiseExclusiveOR)
        case 0x09:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: immediate, exec: bitwiseORwithAccumulator)
        case 0x05:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: zeroPage, exec: bitwiseORwithAccumulator)
        case 0x15:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: zeroPageX, exec: bitwiseORwithAccumulator)
        case 0x0D:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: absolute, exec: bitwiseORwithAccumulator)
        case 0x1D:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: absoluteX, exec: bitwiseORwithAccumulator)
        case 0x19:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: absoluteY, exec: bitwiseORwithAccumulator)
        case 0x01:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: indexedIndirect, exec: bitwiseORwithAccumulator)
        case 0x11:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: indirectIndexed, exec: bitwiseORwithAccumulator)
        case 0x24:
            return Instruction(opcode: opcode, mnemonic: .BIT, addressingMode: zeroPage, exec: testBits)
        case 0x2C:
            return Instruction(opcode: opcode, mnemonic: .BIT, addressingMode: absolute, exec: testBits)

        case 0x69:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: immediate, exec: addWithCarry)
        case 0x65:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: zeroPage, exec: addWithCarry)
        case 0x75:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: zeroPageX, exec: addWithCarry)
        case 0x6D:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: absolute, exec: addWithCarry)
        case 0x7D:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: absoluteX, exec: addWithCarry)
        case 0x79:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: absoluteY, exec: addWithCarry)
        case 0x61:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: indexedIndirect, exec: addWithCarry)
        case 0x71:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: indirectIndexed, exec: addWithCarry)
        case 0xE9:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: immediate, exec: subtractWithCarry)
        case 0xE5:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: zeroPage, exec: subtractWithCarry)
        case 0xF5:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: zeroPageX, exec: subtractWithCarry)
        case 0xED:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: absolute, exec: subtractWithCarry)
        case 0xFD:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: absoluteX, exec: subtractWithCarry)
        case 0xF9:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: absoluteY, exec: subtractWithCarry)
        case 0xE1:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: indexedIndirect, exec: subtractWithCarry)
        case 0xF1:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: indirectIndexed, exec: subtractWithCarry)
        case 0xC9:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: immediate, exec: compareAccumulator)
        case 0xC5:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: zeroPage, exec: compareAccumulator)
        case 0xD5:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: zeroPageX, exec: compareAccumulator)
        case 0xCD:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: absolute, exec: compareAccumulator)
        case 0xDD:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: absoluteX, exec: compareAccumulator)
        case 0xD9:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: absoluteY, exec: compareAccumulator)
        case 0xC1:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: indexedIndirect, exec: compareAccumulator)
        case 0xD1:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: indirectIndexed, exec: compareAccumulator)
        case 0xE0:
            return Instruction(opcode: opcode, mnemonic: .CPX, addressingMode: immediate, exec: compareXRegister)
        case 0xE4:
            return Instruction(opcode: opcode, mnemonic: .CPX, addressingMode: zeroPage, exec: compareXRegister)
        case 0xEC:
            return Instruction(opcode: opcode, mnemonic: .CPX, addressingMode: absolute, exec: compareXRegister)
        case 0xC0:
            return Instruction(opcode: opcode, mnemonic: .CPY, addressingMode: immediate, exec: compareYRegister)
        case 0xC4:
            return Instruction(opcode: opcode, mnemonic: .CPY, addressingMode: zeroPage, exec: compareYRegister)
        case 0xCC:
            return Instruction(opcode: opcode, mnemonic: .CPY, addressingMode: absolute, exec: compareYRegister)

        case 0xE6:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: zeroPage, exec: incrementMemory)
        case 0xF6:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: zeroPageX, exec: incrementMemory)
        case 0xEE:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: absolute, exec: incrementMemory)
        case 0xFE:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: absoluteX, exec: incrementMemory)
        case 0xE8:
            return Instruction(opcode: opcode, mnemonic: .INX, addressingMode: implicit, exec: incrementX)
        case 0xC8:
            return Instruction(opcode: opcode, mnemonic: .INY, addressingMode: implicit, exec: incrementY)
        case 0xC6:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: zeroPage, exec: decrementMemory)
        case 0xD6:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: zeroPageX, exec: decrementMemory)
        case 0xCE:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: absolute, exec: decrementMemory)
        case 0xDE:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: absoluteX, exec: decrementMemory)
        case 0xCA:
            return Instruction(opcode: opcode, mnemonic: .DEX, addressingMode: implicit, exec: decrementX)
        case 0x88:
            return Instruction(opcode: opcode, mnemonic: .DEY, addressingMode: implicit, exec: decrementY)

        case 0x0A:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: accumulator, exec: arithmeticShiftLeftForAccumulator)
        case 0x06:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: zeroPage, exec: arithmeticShiftLeft)
        case 0x16:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: zeroPageX, exec: arithmeticShiftLeft)
        case 0x0E:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: absolute, exec: arithmeticShiftLeft)
        case 0x1E:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: absoluteX, exec: arithmeticShiftLeft)
        case 0x4A:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: accumulator, exec: logicalShiftRightForAccumulator)
        case 0x46:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: zeroPage, exec: logicalShiftRight)
        case 0x56:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: zeroPageX, exec: logicalShiftRight)
        case 0x4E:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: absolute, exec: logicalShiftRight)
        case 0x5E:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: absoluteX, exec: logicalShiftRight)
        case 0x2A:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: accumulator, exec: rotateLeftForAccumulator)
        case 0x26:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: zeroPage, exec: rotateLeft)
        case 0x36:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: zeroPageX, exec: rotateLeft)
        case 0x2E:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: absolute, exec: rotateLeft)
        case 0x3E:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: absoluteX, exec: rotateLeft)
        case 0x6A:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: accumulator, exec: rotateRightForAccumulator)
        case 0x66:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: zeroPage, exec: rotateRight)
        case 0x76:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: zeroPageX, exec: rotateRight)
        case 0x6E:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: absolute, exec: rotateRight)
        case 0x7E:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: absoluteX, exec: rotateRight)

        case 0x4C:
            return Instruction(opcode: opcode, mnemonic: .JMP, addressingMode: absolute, exec: jump)
        case 0x6C:
            return Instruction(opcode: opcode, mnemonic: .JMP, addressingMode: indirect, exec: jump)
        case 0x20:
            return Instruction(opcode: opcode, mnemonic: .JSR, addressingMode: absolute, exec: jumpToSubroutine)
        case 0x60:
            return Instruction(opcode: opcode, mnemonic: .RTS, addressingMode: implicit, exec: returnFromSubroutine)
        case 0x40:
            return Instruction(opcode: opcode, mnemonic: .RTI, addressingMode: implicit, exec: returnFromInterrupt)

        case 0x90:
            return Instruction(opcode: opcode, mnemonic: .BCC, addressingMode: relative, exec: branchIfCarryClear)
        case 0xB0:
            return Instruction(opcode: opcode, mnemonic: .BCS, addressingMode: relative, exec: branchIfCarrySet)
        case 0xF0:
            return Instruction(opcode: opcode, mnemonic: .BEQ, addressingMode: relative, exec: branchIfEqual)
        case 0x30:
            return Instruction(opcode: opcode, mnemonic: .BMI, addressingMode: relative, exec: branchIfMinus)
        case 0xD0:
            return Instruction(opcode: opcode, mnemonic: .BNE, addressingMode: relative, exec: branchIfNotEqual)
        case 0x10:
            return Instruction(opcode: opcode, mnemonic: .BPL, addressingMode: relative, exec: branchIfPlus)
        case 0x50:
            return Instruction(opcode: opcode, mnemonic: .BVC, addressingMode: relative, exec: branchIfOverflowClear)
        case 0x70:
            return Instruction(opcode: opcode, mnemonic: .BVS, addressingMode: relative, exec: branchIfOverflowSet)

        case 0x18:
            return Instruction(opcode: opcode, mnemonic: .CLC, addressingMode: implicit, exec: clearCarry)
        case 0xD8:
            return Instruction(opcode: opcode, mnemonic: .CLD, addressingMode: implicit, exec: clearDecimal)
        case 0x58:
            return Instruction(opcode: opcode, mnemonic: .CLI, addressingMode: implicit, exec: clearInterrupt)
        case 0xB8:
            return Instruction(opcode: opcode, mnemonic: .CLV, addressingMode: implicit, exec: clearOverflow)

        case 0x38:
            return Instruction(opcode: opcode, mnemonic: .SEC, addressingMode: implicit, exec: setCarryFlag)
        case 0xF8:
            return Instruction(opcode: opcode, mnemonic: .SED, addressingMode: implicit, exec: setDecimalFlag)
        case 0x78:
            return Instruction(opcode: opcode, mnemonic: .SEI, addressingMode: implicit, exec: setInterruptDisable)

        case 0x00:
            return Instruction(opcode: opcode, mnemonic: .BRK, addressingMode: implicit, exec: forceInterrupt)

        // Undocumented

        case 0xEB:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: immediate, exec: subtractWithCarry)

        case 0x04, 0x44, 0x64:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: zeroPage, exec: doNothing)
        case 0x0C:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: absolute, exec: doNothing)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: zeroPageX, exec: doNothing)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: implicit, exec: doNothing)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: absoluteX, exec: doNothing)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: immediate, exec: doNothing)

        case 0xA3:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: indexedIndirect, exec: loadAccumulatorAndX)
        case 0xA7:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: zeroPage, exec: loadAccumulatorAndX)
        case 0xAF:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: absolute, exec: loadAccumulatorAndX)
        case 0xB3:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: indirectIndexed, exec: loadAccumulatorAndX)
        case 0xB7:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: zeroPageY, exec: loadAccumulatorAndX)
        case 0xBF:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: absoluteY, exec: loadAccumulatorAndX)

        case 0x83:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: indexedIndirect, exec: storeAccumulatorAndX)
        case 0x87:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: zeroPage, exec: storeAccumulatorAndX)
        case 0x8F:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: absolute, exec: storeAccumulatorAndX)
        case 0x97:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: zeroPageY, exec: storeAccumulatorAndX)

        case 0xC3:
            return Instruction(opcode: opcode, mnemonic: .DCP, addressingMode: indexedIndirect, exec: decrementMemoryAndCompareAccumulator)
        case 0xC7:
            return Instruction(opcode: opcode, mnemonic: .DCP, addressingMode: zeroPage, exec: decrementMemoryAndCompareAccumulator)
        case 0xCF:
            return Instruction(opcode: opcode, mnemonic: .DCP, addressingMode: absolute, exec: decrementMemoryAndCompareAccumulator)
        case 0xD3:
            return Instruction(opcode: opcode, mnemonic: .DCP, addressingMode: indirectIndexed, exec: decrementMemoryAndCompareAccumulator)
        case 0xD7:
            return Instruction(opcode: opcode, mnemonic: .DCP, addressingMode: zeroPageX, exec: decrementMemoryAndCompareAccumulator)
        case 0xDB:
            return Instruction(opcode: opcode, mnemonic: .DCP, addressingMode: absoluteY, exec: decrementMemoryAndCompareAccumulator)
        case 0xDF:
            return Instruction(opcode: opcode, mnemonic: .DCP, addressingMode: absoluteX, exec: decrementMemoryAndCompareAccumulator)

        case 0xE3:
            return Instruction(opcode: opcode, mnemonic: .ISB, addressingMode: indexedIndirect, exec: incrementMemoryAndSubtractWithCarry)
        case 0xE7:
            return Instruction(opcode: opcode, mnemonic: .ISB, addressingMode: zeroPage, exec: incrementMemoryAndSubtractWithCarry)
        case 0xEF:
            return Instruction(opcode: opcode, mnemonic: .ISB, addressingMode: absolute, exec: incrementMemoryAndSubtractWithCarry)
        case 0xF3:
            return Instruction(opcode: opcode, mnemonic: .ISB, addressingMode: indirectIndexed, exec: incrementMemoryAndSubtractWithCarry)
        case 0xF7:
            return Instruction(opcode: opcode, mnemonic: .ISB, addressingMode: zeroPageX, exec: incrementMemoryAndSubtractWithCarry)
        case 0xFB:
            return Instruction(opcode: opcode, mnemonic: .ISB, addressingMode: absoluteY, exec: incrementMemoryAndSubtractWithCarry)
        case 0xFF:
            return Instruction(opcode: opcode, mnemonic: .ISB, addressingMode: absoluteX, exec: incrementMemoryAndSubtractWithCarry)

        case 0x03:
            return Instruction(opcode: opcode, mnemonic: .SLO, addressingMode: indexedIndirect, exec: arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x07:
            return Instruction(opcode: opcode, mnemonic: .SLO, addressingMode: zeroPage, exec: arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x0F:
            return Instruction(opcode: opcode, mnemonic: .SLO, addressingMode: absolute, exec: arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x13:
            return Instruction(opcode: opcode, mnemonic: .SLO, addressingMode: indirectIndexed, exec: arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x17:
            return Instruction(opcode: opcode, mnemonic: .SLO, addressingMode: zeroPageX, exec: arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x1B:
            return Instruction(opcode: opcode, mnemonic: .SLO, addressingMode: absoluteY, exec: arithmeticShiftLeftAndBitwiseORwithAccumulator)
        case 0x1F:
            return Instruction(opcode: opcode, mnemonic: .SLO, addressingMode: absoluteX, exec: arithmeticShiftLeftAndBitwiseORwithAccumulator)

        case 0x23:
            return Instruction(opcode: opcode, mnemonic: .RLA, addressingMode: indexedIndirect, exec: rotateLeftAndBitwiseANDwithAccumulator)
        case 0x27:
            return Instruction(opcode: opcode, mnemonic: .RLA, addressingMode: zeroPage, exec: rotateLeftAndBitwiseANDwithAccumulator)
        case 0x2F:
            return Instruction(opcode: opcode, mnemonic: .RLA, addressingMode: absolute, exec: rotateLeftAndBitwiseANDwithAccumulator)
        case 0x33:
            return Instruction(opcode: opcode, mnemonic: .RLA, addressingMode: indirectIndexed, exec: rotateLeftAndBitwiseANDwithAccumulator)
        case 0x37:
            return Instruction(opcode: opcode, mnemonic: .RLA, addressingMode: zeroPageX, exec: rotateLeftAndBitwiseANDwithAccumulator)
        case 0x3B:
            return Instruction(opcode: opcode, mnemonic: .RLA, addressingMode: absoluteY, exec: rotateLeftAndBitwiseANDwithAccumulator)
        case 0x3F:
            return Instruction(opcode: opcode, mnemonic: .RLA, addressingMode: absoluteX, exec: rotateLeftAndBitwiseANDwithAccumulator)

        case 0x43:
            return Instruction(opcode: opcode, mnemonic: .SRE, addressingMode: indexedIndirect, exec: logicalShiftRightAndBitwiseExclusiveOR)
        case 0x47:
            return Instruction(opcode: opcode, mnemonic: .SRE, addressingMode: zeroPage, exec: logicalShiftRightAndBitwiseExclusiveOR)
        case 0x4F:
            return Instruction(opcode: opcode, mnemonic: .SRE, addressingMode: absolute, exec: logicalShiftRightAndBitwiseExclusiveOR)
        case 0x53:
            return Instruction(opcode: opcode, mnemonic: .SRE, addressingMode: indirectIndexed, exec: logicalShiftRightAndBitwiseExclusiveOR)
        case 0x57:
            return Instruction(opcode: opcode, mnemonic: .SRE, addressingMode: zeroPageX, exec: logicalShiftRightAndBitwiseExclusiveOR)
        case 0x5B:
            return Instruction(opcode: opcode, mnemonic: .SRE, addressingMode: absoluteY, exec: logicalShiftRightAndBitwiseExclusiveOR)
        case 0x5F:
            return Instruction(opcode: opcode, mnemonic: .SRE, addressingMode: absoluteX, exec: logicalShiftRightAndBitwiseExclusiveOR)

        case 0x63:
            return Instruction(opcode: opcode, mnemonic: .RRA, addressingMode: indexedIndirect, exec: rotateRightAndAddWithCarry)
        case 0x67:
            return Instruction(opcode: opcode, mnemonic: .RRA, addressingMode: zeroPage, exec: rotateRightAndAddWithCarry)
        case 0x6F:
            return Instruction(opcode: opcode, mnemonic: .RRA, addressingMode: absolute, exec: rotateRightAndAddWithCarry)
        case 0x73:
            return Instruction(opcode: opcode, mnemonic: .RRA, addressingMode: indirectIndexed, exec: rotateRightAndAddWithCarry)
        case 0x77:
            return Instruction(opcode: opcode, mnemonic: .RRA, addressingMode: zeroPageX, exec: rotateRightAndAddWithCarry)
        case 0x7B:
            return Instruction(opcode: opcode, mnemonic: .RRA, addressingMode: absoluteY, exec: rotateRightAndAddWithCarry)
        case 0x7F:
            return Instruction(opcode: opcode, mnemonic: .RRA, addressingMode: absoluteX, exec: rotateRightAndAddWithCarry)

        default:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: implicit, exec: { _ in .next })
        }
    }
}
