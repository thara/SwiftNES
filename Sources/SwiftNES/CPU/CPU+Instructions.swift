extension Instruction {
    static let NOP = Instruction(mnemonic: .NOP, addressingMode: .implicit, cycle: 2, exec: { _ in .next })
}

extension CPU {

    func buildInstructionTable() -> [Instruction?] {
        var table: [Instruction?] = Array(repeating: nil, count: 0xFF)
        for i in 0x00..<0xFF {
            table[i] = buildInstruction(opcode: UInt8(i))
        }
        return table
    }

    // swiftlint:disable cyclomatic_complexity function_body_length line_length
    func buildInstruction(opcode: UInt8) -> Instruction? {
        switch opcode {

        case 0xA9:
            return Instruction(mnemonic: .LDA, addressingMode: .immediate, cycle: 2, exec: loadAccumulator)
        case 0xA5:
            return Instruction(mnemonic: .LDA, addressingMode: .zeroPage, cycle: 3, exec: loadAccumulator)
        case 0xB5:
            return Instruction(mnemonic: .LDA, addressingMode: .zeroPageX, cycle: 4, exec: loadAccumulator)
        case 0xAD:
            return Instruction(mnemonic: .LDA, addressingMode: .absolute, cycle: 4, exec: loadAccumulator)
        case 0xBD:
            return Instruction(mnemonic: .LDA, addressingMode: .absoluteX, cycle: 4, exec: loadAccumulator)
        case 0xB9:
            return Instruction(mnemonic: .LDA, addressingMode: .absoluteY, cycle: 4, exec: loadAccumulator)
        case 0xA1:
            return Instruction(mnemonic: .LDA, addressingMode: .indexedIndirect, cycle: 6, exec: loadAccumulator)
        case 0xB1:
            return Instruction(mnemonic: .LDA, addressingMode: .indirectIndexed, cycle: 5, exec: loadAccumulator)
        case 0xA2:
            return Instruction(mnemonic: .LDX, addressingMode: .immediate, cycle: 2, exec: loadXRegister)
        case 0xA6:
            return Instruction(mnemonic: .LDX, addressingMode: .zeroPage, cycle: 3, exec: loadXRegister)
        case 0xB6:
            return Instruction(mnemonic: .LDX, addressingMode: .zeroPageY, cycle: 4, exec: loadXRegister)
        case 0xAE:
            return Instruction(mnemonic: .LDX, addressingMode: .absolute, cycle: 4, exec: loadXRegister)
        case 0xBE:
            return Instruction(mnemonic: .LDX, addressingMode: .absoluteY, cycle: 4, exec: loadXRegister)
        case 0xA0:
            return Instruction(mnemonic: .LDY, addressingMode: .immediate, cycle: 2, exec: loadYRegister)
        case 0xA4:
            return Instruction(mnemonic: .LDY, addressingMode: .zeroPage, cycle: 3, exec: loadYRegister)
        case 0xB4:
            return Instruction(mnemonic: .LDY, addressingMode: .zeroPageX, cycle: 4, exec: loadYRegister)
        case 0xAC:
            return Instruction(mnemonic: .LDY, addressingMode: .absolute, cycle: 4, exec: loadYRegister)
        case 0xBC:
            return Instruction(mnemonic: .LDY, addressingMode: .absoluteX, cycle: 4, exec: loadYRegister)
        case 0x85:
            return Instruction(mnemonic: .STA, addressingMode: .zeroPage, cycle: 3, exec: storeAccumulator)
        case 0x95:
            return Instruction(mnemonic: .STA, addressingMode: .zeroPageX, cycle: 4, exec: storeAccumulator)
        case 0x8D:
            return Instruction(mnemonic: .STA, addressingMode: .absolute, cycle: 4, exec: storeAccumulator)
        case 0x9D:
            return Instruction(mnemonic: .STA, addressingMode: .absoluteX, cycle: 5, exec: storeAccumulator)
        case 0x99:
            return Instruction(mnemonic: .STA, addressingMode: .absoluteY, cycle: 5, exec: storeAccumulator)
        case 0x81:
            return Instruction(mnemonic: .STA, addressingMode: .indexedIndirect, cycle: 6, exec: storeAccumulator)
        case 0x91:
            return Instruction(mnemonic: .STA, addressingMode: .indirectIndexed, cycle: 6, exec: storeAccumulator)
        case 0x86:
            return Instruction(mnemonic: .STX, addressingMode: .zeroPage, cycle: 3, exec: storeXRegister)
        case 0x96:
            return Instruction(mnemonic: .STX, addressingMode: .zeroPageY, cycle: 4, exec: storeXRegister)
        case 0x8E:
            return Instruction(mnemonic: .STX, addressingMode: .absolute, cycle: 4, exec: storeXRegister)
        case 0x84:
            return Instruction(mnemonic: .STY, addressingMode: .zeroPage, cycle: 3, exec: storeYRegister)
        case 0x94:
            return Instruction(mnemonic: .STY, addressingMode: .zeroPageY, cycle: 4, exec: storeYRegister)
        case 0x8C:
            return Instruction(mnemonic: .STY, addressingMode: .absolute, cycle: 4, exec: storeYRegister)
        case 0xAA:
            return Instruction(mnemonic: .TAX, addressingMode: .implicit, cycle: 2, exec: transferAccumulatorToX)
        case 0xA8:
            return Instruction(mnemonic: .TAY, addressingMode: .implicit, cycle: 2, exec: transferAccumulatorToY)
        case 0x8A:
            return Instruction(mnemonic: .TXA, addressingMode: .implicit, cycle: 2, exec: transferXtoAccumulator)
        case 0x98:
            return Instruction(mnemonic: .TYA, addressingMode: .implicit, cycle: 2, exec: transferYtoAccumulator)

        case 0x48:
            return Instruction(mnemonic: .PHA, addressingMode: .implicit, cycle: 3, exec: pushAccumulator)
        case 0x08:
            return Instruction(mnemonic: .PHP, addressingMode: .implicit, cycle: 3, exec: pushProcessorStatus)
        case 0x68:
            return Instruction(mnemonic: .PLA, addressingMode: .implicit, cycle: 3, exec: pullAccumulator)
        case 0x28:
            return Instruction(mnemonic: .PLP, addressingMode: .implicit, cycle: 4, exec: pullProcessorStatus)

        case 0x29:
            return Instruction(mnemonic: .AND, addressingMode: .immediate, cycle: 2, exec: bitwiseANDwithAccumulator)
        case 0x25:
            return Instruction(mnemonic: .AND, addressingMode: .zeroPage, cycle: 3, exec: bitwiseANDwithAccumulator)
        case 0x35:
            return Instruction(mnemonic: .AND, addressingMode: .zeroPageX, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x2D:
            return Instruction(mnemonic: .AND, addressingMode: .absolute, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x3D:
            return Instruction(mnemonic: .AND, addressingMode: .absoluteX, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x39:
            return Instruction(mnemonic: .AND, addressingMode: .absoluteY, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x21:
            return Instruction(mnemonic: .AND, addressingMode: .indexedIndirect, cycle: 6, exec: bitwiseANDwithAccumulator)
        case 0x31:
            return Instruction(mnemonic: .AND, addressingMode: .indirectIndexed, cycle: 5, exec: bitwiseANDwithAccumulator)
        case 0x49:
            return Instruction(mnemonic: .EOR, addressingMode: .immediate, cycle: 2, exec: bitwiseExclusiveOR)
        case 0x45:
            return Instruction(mnemonic: .EOR, addressingMode: .zeroPage, cycle: 3, exec: bitwiseExclusiveOR)
        case 0x55:
            return Instruction(mnemonic: .EOR, addressingMode: .zeroPageX, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x4D:
            return Instruction(mnemonic: .EOR, addressingMode: .absolute, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x5D:
            return Instruction(mnemonic: .EOR, addressingMode: .absoluteX, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x59:
            return Instruction(mnemonic: .EOR, addressingMode: .absoluteY, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x41:
            return Instruction(mnemonic: .EOR, addressingMode: .indexedIndirect, cycle: 6, exec: bitwiseExclusiveOR)
        case 0x51:
            return Instruction(mnemonic: .EOR, addressingMode: .indirectIndexed, cycle: 5, exec: bitwiseExclusiveOR)
        case 0x09:
            return Instruction(mnemonic: .ORA, addressingMode: .immediate, cycle: 2, exec: bitwiseORwithAccumulator)
        case 0x05:
            return Instruction(mnemonic: .ORA, addressingMode: .zeroPage, cycle: 3, exec: bitwiseORwithAccumulator)
        case 0x15:
            return Instruction(mnemonic: .ORA, addressingMode: .zeroPageX, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x0D:
            return Instruction(mnemonic: .ORA, addressingMode: .absolute, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x1D:
            return Instruction(mnemonic: .ORA, addressingMode: .absoluteX, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x19:
            return Instruction(mnemonic: .ORA, addressingMode: .absoluteY, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x01:
            return Instruction(mnemonic: .ORA, addressingMode: .indexedIndirect, cycle: 6, exec: bitwiseORwithAccumulator)
        case 0x11:
            return Instruction(mnemonic: .ORA, addressingMode: .indirectIndexed, cycle: 5, exec: bitwiseORwithAccumulator)
        case 0x24:
            return Instruction(mnemonic: .BIT, addressingMode: .zeroPage, cycle: 3, exec: testBits)
        case 0x2C:
            return Instruction(mnemonic: .BIT, addressingMode: .absolute, cycle: 4, exec: testBits)

        case 0x69:
            return Instruction(mnemonic: .ADC, addressingMode: .immediate, cycle: 2, exec: addWithCarry)
        case 0x65:
            return Instruction(mnemonic: .ADC, addressingMode: .zeroPage, cycle: 3, exec: addWithCarry)
        case 0x75:
            return Instruction(mnemonic: .ADC, addressingMode: .zeroPageX, cycle: 4, exec: addWithCarry)
        case 0x6D:
            return Instruction(mnemonic: .ADC, addressingMode: .absolute, cycle: 4, exec: addWithCarry)
        case 0x7D:
            return Instruction(mnemonic: .ADC, addressingMode: .absoluteX, cycle: 4, exec: addWithCarry)
        case 0x79:
            return Instruction(mnemonic: .ADC, addressingMode: .absoluteY, cycle: 4, exec: addWithCarry)
        case 0x61:
            return Instruction(mnemonic: .ADC, addressingMode: .indexedIndirect, cycle: 6, exec: addWithCarry)
        case 0x71:
            return Instruction(mnemonic: .ADC, addressingMode: .indirectIndexed, cycle: 5, exec: addWithCarry)
        case 0xE9:
            return Instruction(mnemonic: .SBC, addressingMode: .immediate, cycle: 2, exec: subtractWithCarry)
        case 0xE5:
            return Instruction(mnemonic: .SBC, addressingMode: .zeroPage, cycle: 3, exec: subtractWithCarry)
        case 0xF5:
            return Instruction(mnemonic: .SBC, addressingMode: .zeroPageX, cycle: 4, exec: subtractWithCarry)
        case 0xED:
            return Instruction(mnemonic: .SBC, addressingMode: .absolute, cycle: 4, exec: subtractWithCarry)
        case 0xFD:
            return Instruction(mnemonic: .SBC, addressingMode: .absoluteX, cycle: 4, exec: subtractWithCarry)
        case 0xF9:
            return Instruction(mnemonic: .SBC, addressingMode: .absoluteY, cycle: 4, exec: subtractWithCarry)
        case 0xE1:
            return Instruction(mnemonic: .SBC, addressingMode: .indexedIndirect, cycle: 6, exec: subtractWithCarry)
        case 0xF1:
            return Instruction(mnemonic: .SBC, addressingMode: .indirectIndexed, cycle: 5, exec: subtractWithCarry)
        case 0xC9:
            return Instruction(mnemonic: .CMP, addressingMode: .immediate, cycle: 2, exec: compareAccumulator)
        case 0xC5:
            return Instruction(mnemonic: .CMP, addressingMode: .zeroPage, cycle: 3, exec: compareAccumulator)
        case 0xD5:
            return Instruction(mnemonic: .CMP, addressingMode: .zeroPageX, cycle: 4, exec: compareAccumulator)
        case 0xCD:
            return Instruction(mnemonic: .CMP, addressingMode: .absolute, cycle: 4, exec: compareAccumulator)
        case 0xDD:
            return Instruction(mnemonic: .CMP, addressingMode: .absoluteX, cycle: 4, exec: compareAccumulator)
        case 0xD9:
            return Instruction(mnemonic: .CMP, addressingMode: .absoluteY, cycle: 4, exec: compareAccumulator)
        case 0xC1:
            return Instruction(mnemonic: .CMP, addressingMode: .indexedIndirect, cycle: 6, exec: compareAccumulator)
        case 0xD1:
            return Instruction(mnemonic: .CMP, addressingMode: .indirectIndexed, cycle: 5, exec: compareAccumulator)
        case 0xE0:
            return Instruction(mnemonic: .CPX, addressingMode: .immediate, cycle: 2, exec: compareXRegister)
        case 0xE4:
            return Instruction(mnemonic: .CPX, addressingMode: .zeroPage, cycle: 3, exec: compareXRegister)
        case 0xEC:
            return Instruction(mnemonic: .CPX, addressingMode: .absolute, cycle: 4, exec: compareXRegister)
        case 0xC0:
            return Instruction(mnemonic: .CPY, addressingMode: .immediate, cycle: 2, exec: compareYRegister)
        case 0xC4:
            return Instruction(mnemonic: .CPY, addressingMode: .zeroPage, cycle: 3, exec: compareYRegister)
        case 0xCC:
            return Instruction(mnemonic: .CPY, addressingMode: .absolute, cycle: 4, exec: compareYRegister)

        case 0xE6:
            return Instruction(mnemonic: .INC, addressingMode: .zeroPage, cycle: 5, exec: incrementMemory)
        case 0xF6:
            return Instruction(mnemonic: .INC, addressingMode: .zeroPageX, cycle: 6, exec: incrementMemory)
        case 0xEE:
            return Instruction(mnemonic: .INC, addressingMode: .absolute, cycle: 6, exec: incrementMemory)
        case 0xFE:
            return Instruction(mnemonic: .INC, addressingMode: .absoluteX, cycle: 7, exec: incrementMemory)
        case 0xE8:
            return Instruction(mnemonic: .INX, addressingMode: .implicit, cycle: 2, exec: incrementX)
        case 0xC8:
            return Instruction(mnemonic: .INY, addressingMode: .implicit, cycle: 2, exec: incrementY)
        case 0xC6:
            return Instruction(mnemonic: .DEC, addressingMode: .zeroPage, cycle: 5, exec: decrementMemory)
        case 0xD6:
            return Instruction(mnemonic: .DEC, addressingMode: .zeroPageX, cycle: 6, exec: decrementMemory)
        case 0xCE:
            return Instruction(mnemonic: .DEC, addressingMode: .absolute, cycle: 6, exec: decrementMemory)
        case 0xDE:
            return Instruction(mnemonic: .DEC, addressingMode: .absoluteX, cycle: 7, exec: decrementMemory)
        case 0xCA:
            return Instruction(mnemonic: .DEX, addressingMode: .implicit, cycle: 2, exec: decrementX)
        case 0x88:
            return Instruction(mnemonic: .DEY, addressingMode: .implicit, cycle: 2, exec: decrementY)

        case 0x0A:
            return Instruction(mnemonic: .ASL, addressingMode: .accumulator, cycle: 2, exec: arithmeticShiftLeftForAccumulator)
        case 0x06:
            return Instruction(mnemonic: .ASL, addressingMode: .zeroPage, cycle: 5, exec: arithmeticShiftLeft)
        case 0x16:
            return Instruction(mnemonic: .ASL, addressingMode: .zeroPageX, cycle: 6, exec: arithmeticShiftLeft)
        case 0x0E:
            return Instruction(mnemonic: .ASL, addressingMode: .absolute, cycle: 6, exec: arithmeticShiftLeft)
        case 0x1E:
            return Instruction(mnemonic: .ASL, addressingMode: .absoluteX, cycle: 7, exec: arithmeticShiftLeft)
        case 0x4A:
            return Instruction(mnemonic: .LSR, addressingMode: .accumulator, cycle: 2, exec: logicalShiftRightForAccumulator)
        case 0x46:
            return Instruction(mnemonic: .LSR, addressingMode: .zeroPage, cycle: 5, exec: logicalShiftRight)
        case 0x56:
            return Instruction(mnemonic: .LSR, addressingMode: .zeroPageX, cycle: 6, exec: logicalShiftRight)
        case 0x4E:
            return Instruction(mnemonic: .LSR, addressingMode: .absolute, cycle: 6, exec: logicalShiftRight)
        case 0x5E:
            return Instruction(mnemonic: .LSR, addressingMode: .absoluteX, cycle: 7, exec: logicalShiftRight)
        case 0x2A:
            return Instruction(mnemonic: .ROL, addressingMode: .accumulator, cycle: 2, exec: rotateLeftForAccumulator)
        case 0x26:
            return Instruction(mnemonic: .ROL, addressingMode: .zeroPage, cycle: 5, exec: rotateLeft)
        case 0x36:
            return Instruction(mnemonic: .ROL, addressingMode: .zeroPageX, cycle: 6, exec: rotateLeft)
        case 0x2E:
            return Instruction(mnemonic: .ROL, addressingMode: .absolute, cycle: 6, exec: rotateLeft)
        case 0x3E:
            return Instruction(mnemonic: .ROL, addressingMode: .absoluteX, cycle: 7, exec: rotateLeft)
        case 0x6A:
            return Instruction(mnemonic: .ROR, addressingMode: .accumulator, cycle: 2, exec: rotateRightForAccumulator)
        case 0x66:
            return Instruction(mnemonic: .ROR, addressingMode: .zeroPage, cycle: 5, exec: rotateRight)
        case 0x76:
            return Instruction(mnemonic: .ROR, addressingMode: .zeroPageX, cycle: 6, exec: rotateRight)
        case 0x6E:
            return Instruction(mnemonic: .ROR, addressingMode: .absolute, cycle: 6, exec: rotateRight)
        case 0x7E:
            return Instruction(mnemonic: .ROR, addressingMode: .absoluteX, cycle: 7, exec: rotateRight)

        case 0x4C:
            return Instruction(mnemonic: .JMP, addressingMode: .absolute, cycle: 3, exec: jump)
        case 0x6C:
            return Instruction(mnemonic: .JMP, addressingMode: .indirect, cycle: 5, exec: jump)
        case 0x20:
            return Instruction(mnemonic: .JSR, addressingMode: .absolute, cycle: 6, exec: jumpToSubroutine)
        case 0x60:
            return Instruction(mnemonic: .RTS, addressingMode: .implicit, cycle: 6, exec: returnFromSubroutine)
        case 0x40:
            return Instruction(mnemonic: .RTI, addressingMode: .implicit, cycle: 6, exec: returnFromInterrupt)

        case 0x90:
            return Instruction(mnemonic: .BCC, addressingMode: .relative, cycle: 2, exec: branchIfCarryClear)
        case 0xB0:
            return Instruction(mnemonic: .BCS, addressingMode: .relative, cycle: 2, exec: branchIfCarrySet)
        case 0xF0:
            return Instruction(mnemonic: .BEQ, addressingMode: .relative, cycle: 2, exec: branchIfEqual)
        case 0x30:
            return Instruction(mnemonic: .BMI, addressingMode: .relative, cycle: 2, exec: branchIfMinus)
        case 0xD0:
            return Instruction(mnemonic: .BNE, addressingMode: .relative, cycle: 2, exec: branchIfNotEqual)
        case 0x10:
            return Instruction(mnemonic: .BPL, addressingMode: .relative, cycle: 2, exec: branchIfPlus)
        case 0x50:
            return Instruction(mnemonic: .BVC, addressingMode: .relative, cycle: 2, exec: branchIfOverflowClear)
        case 0x70:
            return Instruction(mnemonic: .BVS, addressingMode: .relative, cycle: 2, exec: branchIfOverflowSet)

        case 0x18:
            return Instruction(mnemonic: .CLC, addressingMode: .implicit, cycle: 2, exec: clearCarry)
        case 0xD8:
            return Instruction(mnemonic: .CLD, addressingMode: .implicit, cycle: 2, exec: clearDecimal)
        case 0x58:
            return Instruction(mnemonic: .CLI, addressingMode: .implicit, cycle: 2, exec: clearInterrupt)
        case 0xB8:
            return Instruction(mnemonic: .CLV, addressingMode: .implicit, cycle: 2, exec: clearOverflow)

        case 0x38:
            return Instruction(mnemonic: .SEC, addressingMode: .implicit, cycle: 2, exec: setCarryFlag)
        case 0xF8:
            return Instruction(mnemonic: .SED, addressingMode: .implicit, cycle: 2, exec: setDecimalFlag)
        case 0x78:
            return Instruction(mnemonic: .SEI, addressingMode: .implicit, cycle: 2, exec: setInterruptDisable)

        case 0x00:
            return Instruction(mnemonic: .BRK, addressingMode: .implicit, cycle: 7, exec: forceInterrupt)
        case 0xEA:
            return .NOP

        default:
            return nil
        }
    }
}
