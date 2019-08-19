extension Instruction {
    static let NOP = Instruction(opcode: 0x00, mnemonic: .NOP, addressingMode: .implicit, cycle: 2, exec: { _ in .next })
}

extension CPU {

    func buildInstructionTable() -> [Instruction?] {
        var table: [Instruction?] = Array(repeating: nil, count: 0x100)
        for i in 0x00..<0xFF {
            table[i] = buildInstruction(opcode: UInt8(i))
        }
        return table
    }

    // swiftlint:disable cyclomatic_complexity function_body_length line_length
    private func buildInstruction(opcode: UInt8) -> Instruction? {
        switch opcode {

        case 0xA9:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .immediate, cycle: 2, exec: loadAccumulator)
        case 0xA5:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .zeroPage, cycle: 3, exec: loadAccumulator)
        case 0xB5:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .zeroPageX, cycle: 4, exec: loadAccumulator)
        case 0xAD:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .absolute, cycle: 4, exec: loadAccumulator)
        case 0xBD:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .absoluteX, cycle: 4, exec: loadAccumulator)
        case 0xB9:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .absoluteY, cycle: 4, exec: loadAccumulator)
        case 0xA1:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .indexedIndirect, cycle: 6, exec: loadAccumulator)
        case 0xB1:
            return Instruction(opcode: opcode, mnemonic: .LDA, addressingMode: .indirectIndexed, cycle: 5, exec: loadAccumulator)
        case 0xA2:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: .immediate, cycle: 2, exec: loadXRegister)
        case 0xA6:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: .zeroPage, cycle: 3, exec: loadXRegister)
        case 0xB6:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: .zeroPageY, cycle: 4, exec: loadXRegister)
        case 0xAE:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: .absolute, cycle: 4, exec: loadXRegister)
        case 0xBE:
            return Instruction(opcode: opcode, mnemonic: .LDX, addressingMode: .absoluteY, cycle: 4, exec: loadXRegister)
        case 0xA0:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: .immediate, cycle: 2, exec: loadYRegister)
        case 0xA4:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: .zeroPage, cycle: 3, exec: loadYRegister)
        case 0xB4:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: .zeroPageX, cycle: 4, exec: loadYRegister)
        case 0xAC:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: .absolute, cycle: 4, exec: loadYRegister)
        case 0xBC:
            return Instruction(opcode: opcode, mnemonic: .LDY, addressingMode: .absoluteX, cycle: 4, exec: loadYRegister)
        case 0x85:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: .zeroPage, cycle: 3, exec: storeAccumulator)
        case 0x95:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: .zeroPageX, cycle: 4, exec: storeAccumulator)
        case 0x8D:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: .absolute, cycle: 4, exec: storeAccumulator)
        case 0x9D:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: .absoluteX, cycle: 5, exec: storeAccumulator)
        case 0x99:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: .absoluteY, cycle: 5, exec: storeAccumulator)
        case 0x81:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: .indexedIndirect, cycle: 6, exec: storeAccumulator)
        case 0x91:
            return Instruction(opcode: opcode, mnemonic: .STA, addressingMode: .indirectIndexed, cycle: 6, exec: storeAccumulator)
        case 0x86:
            return Instruction(opcode: opcode, mnemonic: .STX, addressingMode: .zeroPage, cycle: 3, exec: storeXRegister)
        case 0x96:
            return Instruction(opcode: opcode, mnemonic: .STX, addressingMode: .zeroPageY, cycle: 4, exec: storeXRegister)
        case 0x8E:
            return Instruction(opcode: opcode, mnemonic: .STX, addressingMode: .absolute, cycle: 4, exec: storeXRegister)
        case 0x84:
            return Instruction(opcode: opcode, mnemonic: .STY, addressingMode: .zeroPage, cycle: 3, exec: storeYRegister)
        case 0x94:
            return Instruction(opcode: opcode, mnemonic: .STY, addressingMode: .zeroPageX, cycle: 4, exec: storeYRegister)
        case 0x8C:
            return Instruction(opcode: opcode, mnemonic: .STY, addressingMode: .absolute, cycle: 4, exec: storeYRegister)
        case 0xAA:
            return Instruction(opcode: opcode, mnemonic: .TAX, addressingMode: .implicit, cycle: 2, exec: transferAccumulatorToX)
        case 0xBA:
            return Instruction(opcode: opcode, mnemonic: .TSX, addressingMode: .implicit, cycle: 2, exec: transferStackPointerToX)
        case 0xA8:
            return Instruction(opcode: opcode, mnemonic: .TAY, addressingMode: .implicit, cycle: 2, exec: transferAccumulatorToY)
        case 0x8A:
            return Instruction(opcode: opcode, mnemonic: .TXA, addressingMode: .implicit, cycle: 2, exec: transferXtoAccumulator)
        case 0x9A:
            return Instruction(opcode: opcode, mnemonic: .TXS, addressingMode: .implicit, cycle: 2, exec: transferXtoStackPointer)
        case 0x98:
            return Instruction(opcode: opcode, mnemonic: .TYA, addressingMode: .implicit, cycle: 2, exec: transferYtoAccumulator)

        case 0x48:
            return Instruction(opcode: opcode, mnemonic: .PHA, addressingMode: .implicit, cycle: 3, exec: pushAccumulator)
        case 0x08:
            return Instruction(opcode: opcode, mnemonic: .PHP, addressingMode: .implicit, cycle: 3, exec: pushProcessorStatus)
        case 0x68:
            return Instruction(opcode: opcode, mnemonic: .PLA, addressingMode: .implicit, cycle: 3, exec: pullAccumulator)
        case 0x28:
            return Instruction(opcode: opcode, mnemonic: .PLP, addressingMode: .implicit, cycle: 4, exec: pullProcessorStatus)

        case 0x29:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .immediate, cycle: 2, exec: bitwiseANDwithAccumulator)
        case 0x25:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .zeroPage, cycle: 3, exec: bitwiseANDwithAccumulator)
        case 0x35:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .zeroPageX, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x2D:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .absolute, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x3D:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .absoluteX, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x39:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .absoluteY, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x21:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .indexedIndirect, cycle: 6, exec: bitwiseANDwithAccumulator)
        case 0x31:
            return Instruction(opcode: opcode, mnemonic: .AND, addressingMode: .indirectIndexed, cycle: 5, exec: bitwiseANDwithAccumulator)
        case 0x49:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .immediate, cycle: 2, exec: bitwiseExclusiveOR)
        case 0x45:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .zeroPage, cycle: 3, exec: bitwiseExclusiveOR)
        case 0x55:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .zeroPageX, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x4D:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .absolute, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x5D:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .absoluteX, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x59:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .absoluteY, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x41:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .indexedIndirect, cycle: 6, exec: bitwiseExclusiveOR)
        case 0x51:
            return Instruction(opcode: opcode, mnemonic: .EOR, addressingMode: .indirectIndexed, cycle: 5, exec: bitwiseExclusiveOR)
        case 0x09:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .immediate, cycle: 2, exec: bitwiseORwithAccumulator)
        case 0x05:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .zeroPage, cycle: 3, exec: bitwiseORwithAccumulator)
        case 0x15:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .zeroPageX, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x0D:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .absolute, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x1D:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .absoluteX, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x19:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .absoluteY, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x01:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .indexedIndirect, cycle: 6, exec: bitwiseORwithAccumulator)
        case 0x11:
            return Instruction(opcode: opcode, mnemonic: .ORA, addressingMode: .indirectIndexed, cycle: 5, exec: bitwiseORwithAccumulator)
        case 0x24:
            return Instruction(opcode: opcode, mnemonic: .BIT, addressingMode: .zeroPage, cycle: 3, exec: testBits)
        case 0x2C:
            return Instruction(opcode: opcode, mnemonic: .BIT, addressingMode: .absolute, cycle: 4, exec: testBits)

        case 0x69:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .immediate, cycle: 2, exec: addWithCarry)
        case 0x65:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .zeroPage, cycle: 3, exec: addWithCarry)
        case 0x75:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .zeroPageX, cycle: 4, exec: addWithCarry)
        case 0x6D:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .absolute, cycle: 4, exec: addWithCarry)
        case 0x7D:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .absoluteX, cycle: 4, exec: addWithCarry)
        case 0x79:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .absoluteY, cycle: 4, exec: addWithCarry)
        case 0x61:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .indexedIndirect, cycle: 6, exec: addWithCarry)
        case 0x71:
            return Instruction(opcode: opcode, mnemonic: .ADC, addressingMode: .indirectIndexed, cycle: 5, exec: addWithCarry)
        case 0xE9:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .immediate, cycle: 2, exec: subtractWithCarry)
        case 0xE5:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .zeroPage, cycle: 3, exec: subtractWithCarry)
        case 0xF5:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .zeroPageX, cycle: 4, exec: subtractWithCarry)
        case 0xED:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .absolute, cycle: 4, exec: subtractWithCarry)
        case 0xFD:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .absoluteX, cycle: 4, exec: subtractWithCarry)
        case 0xF9:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .absoluteY, cycle: 4, exec: subtractWithCarry)
        case 0xE1:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .indexedIndirect, cycle: 6, exec: subtractWithCarry)
        case 0xF1:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .indirectIndexed, cycle: 5, exec: subtractWithCarry)
        case 0xC9:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .immediate, cycle: 2, exec: compareAccumulator)
        case 0xC5:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .zeroPage, cycle: 3, exec: compareAccumulator)
        case 0xD5:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .zeroPageX, cycle: 4, exec: compareAccumulator)
        case 0xCD:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .absolute, cycle: 4, exec: compareAccumulator)
        case 0xDD:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .absoluteX, cycle: 4, exec: compareAccumulator)
        case 0xD9:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .absoluteY, cycle: 4, exec: compareAccumulator)
        case 0xC1:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .indexedIndirect, cycle: 6, exec: compareAccumulator)
        case 0xD1:
            return Instruction(opcode: opcode, mnemonic: .CMP, addressingMode: .indirectIndexed, cycle: 5, exec: compareAccumulator)
        case 0xE0:
            return Instruction(opcode: opcode, mnemonic: .CPX, addressingMode: .immediate, cycle: 2, exec: compareXRegister)
        case 0xE4:
            return Instruction(opcode: opcode, mnemonic: .CPX, addressingMode: .zeroPage, cycle: 3, exec: compareXRegister)
        case 0xEC:
            return Instruction(opcode: opcode, mnemonic: .CPX, addressingMode: .absolute, cycle: 4, exec: compareXRegister)
        case 0xC0:
            return Instruction(opcode: opcode, mnemonic: .CPY, addressingMode: .immediate, cycle: 2, exec: compareYRegister)
        case 0xC4:
            return Instruction(opcode: opcode, mnemonic: .CPY, addressingMode: .zeroPage, cycle: 3, exec: compareYRegister)
        case 0xCC:
            return Instruction(opcode: opcode, mnemonic: .CPY, addressingMode: .absolute, cycle: 4, exec: compareYRegister)

        case 0xE6:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: .zeroPage, cycle: 5, exec: incrementMemory)
        case 0xF6:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: .zeroPageX, cycle: 6, exec: incrementMemory)
        case 0xEE:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: .absolute, cycle: 6, exec: incrementMemory)
        case 0xFE:
            return Instruction(opcode: opcode, mnemonic: .INC, addressingMode: .absoluteX, cycle: 7, exec: incrementMemory)
        case 0xE8:
            return Instruction(opcode: opcode, mnemonic: .INX, addressingMode: .implicit, cycle: 2, exec: incrementX)
        case 0xC8:
            return Instruction(opcode: opcode, mnemonic: .INY, addressingMode: .implicit, cycle: 2, exec: incrementY)
        case 0xC6:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: .zeroPage, cycle: 5, exec: decrementMemory)
        case 0xD6:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: .zeroPageX, cycle: 6, exec: decrementMemory)
        case 0xCE:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: .absolute, cycle: 6, exec: decrementMemory)
        case 0xDE:
            return Instruction(opcode: opcode, mnemonic: .DEC, addressingMode: .absoluteX, cycle: 7, exec: decrementMemory)
        case 0xCA:
            return Instruction(opcode: opcode, mnemonic: .DEX, addressingMode: .implicit, cycle: 2, exec: decrementX)
        case 0x88:
            return Instruction(opcode: opcode, mnemonic: .DEY, addressingMode: .implicit, cycle: 2, exec: decrementY)

        case 0x0A:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: .accumulator, cycle: 2, exec: arithmeticShiftLeftForAccumulator)
        case 0x06:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: .zeroPage, cycle: 5, exec: arithmeticShiftLeft)
        case 0x16:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: .zeroPageX, cycle: 6, exec: arithmeticShiftLeft)
        case 0x0E:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: .absolute, cycle: 6, exec: arithmeticShiftLeft)
        case 0x1E:
            return Instruction(opcode: opcode, mnemonic: .ASL, addressingMode: .absoluteX, cycle: 7, exec: arithmeticShiftLeft)
        case 0x4A:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: .accumulator, cycle: 2, exec: logicalShiftRightForAccumulator)
        case 0x46:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: .zeroPage, cycle: 5, exec: logicalShiftRight)
        case 0x56:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: .zeroPageX, cycle: 6, exec: logicalShiftRight)
        case 0x4E:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: .absolute, cycle: 6, exec: logicalShiftRight)
        case 0x5E:
            return Instruction(opcode: opcode, mnemonic: .LSR, addressingMode: .absoluteX, cycle: 7, exec: logicalShiftRight)
        case 0x2A:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: .accumulator, cycle: 2, exec: rotateLeftForAccumulator)
        case 0x26:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: .zeroPage, cycle: 5, exec: rotateLeft)
        case 0x36:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: .zeroPageX, cycle: 6, exec: rotateLeft)
        case 0x2E:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: .absolute, cycle: 6, exec: rotateLeft)
        case 0x3E:
            return Instruction(opcode: opcode, mnemonic: .ROL, addressingMode: .absoluteX, cycle: 7, exec: rotateLeft)
        case 0x6A:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: .accumulator, cycle: 2, exec: rotateRightForAccumulator)
        case 0x66:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: .zeroPage, cycle: 5, exec: rotateRight)
        case 0x76:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: .zeroPageX, cycle: 6, exec: rotateRight)
        case 0x6E:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: .absolute, cycle: 6, exec: rotateRight)
        case 0x7E:
            return Instruction(opcode: opcode, mnemonic: .ROR, addressingMode: .absoluteX, cycle: 7, exec: rotateRight)

        case 0x4C:
            return Instruction(opcode: opcode, mnemonic: .JMP, addressingMode: .absolute, cycle: 3, exec: jump)
        case 0x6C:
            return Instruction(opcode: opcode, mnemonic: .JMP, addressingMode: .indirect, cycle: 5, exec: jump)
        case 0x20:
            return Instruction(opcode: opcode, mnemonic: .JSR, addressingMode: .absolute, cycle: 6, exec: jumpToSubroutine)
        case 0x60:
            return Instruction(opcode: opcode, mnemonic: .RTS, addressingMode: .implicit, cycle: 6, exec: returnFromSubroutine)
        case 0x40:
            return Instruction(opcode: opcode, mnemonic: .RTI, addressingMode: .implicit, cycle: 6, exec: returnFromInterrupt)

        case 0x90:
            return Instruction(opcode: opcode, mnemonic: .BCC, addressingMode: .relative, cycle: 2, exec: branchIfCarryClear)
        case 0xB0:
            return Instruction(opcode: opcode, mnemonic: .BCS, addressingMode: .relative, cycle: 2, exec: branchIfCarrySet)
        case 0xF0:
            return Instruction(opcode: opcode, mnemonic: .BEQ, addressingMode: .relative, cycle: 2, exec: branchIfEqual)
        case 0x30:
            return Instruction(opcode: opcode, mnemonic: .BMI, addressingMode: .relative, cycle: 2, exec: branchIfMinus)
        case 0xD0:
            return Instruction(opcode: opcode, mnemonic: .BNE, addressingMode: .relative, cycle: 2, exec: branchIfNotEqual)
        case 0x10:
            return Instruction(opcode: opcode, mnemonic: .BPL, addressingMode: .relative, cycle: 2, exec: branchIfPlus)
        case 0x50:
            return Instruction(opcode: opcode, mnemonic: .BVC, addressingMode: .relative, cycle: 2, exec: branchIfOverflowClear)
        case 0x70:
            return Instruction(opcode: opcode, mnemonic: .BVS, addressingMode: .relative, cycle: 2, exec: branchIfOverflowSet)

        case 0x18:
            return Instruction(opcode: opcode, mnemonic: .CLC, addressingMode: .implicit, cycle: 2, exec: clearCarry)
        case 0xD8:
            return Instruction(opcode: opcode, mnemonic: .CLD, addressingMode: .implicit, cycle: 2, exec: clearDecimal)
        case 0x58:
            return Instruction(opcode: opcode, mnemonic: .CLI, addressingMode: .implicit, cycle: 2, exec: clearInterrupt)
        case 0xB8:
            return Instruction(opcode: opcode, mnemonic: .CLV, addressingMode: .implicit, cycle: 2, exec: clearOverflow)

        case 0x38:
            return Instruction(opcode: opcode, mnemonic: .SEC, addressingMode: .implicit, cycle: 2, exec: setCarryFlag)
        case 0xF8:
            return Instruction(opcode: opcode, mnemonic: .SED, addressingMode: .implicit, cycle: 2, exec: setDecimalFlag)
        case 0x78:
            return Instruction(opcode: opcode, mnemonic: .SEI, addressingMode: .implicit, cycle: 2, exec: setInterruptDisable)

        case 0x00:
            return Instruction(opcode: opcode, mnemonic: .BRK, addressingMode: .implicit, cycle: 7, exec: forceInterrupt)

        // Undocumented

        case 0xEB:
            return Instruction(opcode: opcode, mnemonic: .SBC, addressingMode: .immediate, cycle: 2, exec: subtractWithCarry)

        case 0x04, 0x44, 0x64:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: .zeroPage, cycle: 0, exec: doNothing)
        case 0x0C:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: .absolute, cycle: 0, exec: doNothing)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: .zeroPageX, cycle: 0, exec: doNothing)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: .implicit, cycle: 0, exec: doNothing)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: .absoluteX, cycle: 0, exec: doNothing)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: .immediate, cycle: 0, exec: doNothing)

        case 0xA3:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: .indexedIndirect, cycle: 0, exec: loadAccumulatorAndX)
        case 0xA7:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: .zeroPage, cycle: 0, exec: loadAccumulatorAndX)
        case 0xAF:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: .absolute, cycle: 0, exec: loadAccumulatorAndX)
        case 0xB3:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: .indirectIndexed, cycle: 0, exec: loadAccumulatorAndX)
        case 0xB7:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: .zeroPageY, cycle: 0, exec: loadAccumulatorAndX)
        case 0xBF:
            return Instruction(opcode: opcode, mnemonic: .LAX, addressingMode: .absoluteY, cycle: 0, exec: loadAccumulatorAndX)

        case 0x83:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: .indexedIndirect, cycle: 0, exec: storeAccumulatorAndX)
        case 0x87:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: .zeroPage, cycle: 0, exec: storeAccumulatorAndX)
        case 0x8F:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: .absolute, cycle: 0, exec: storeAccumulatorAndX)
        case 0x97:
            return Instruction(opcode: opcode, mnemonic: .SAX, addressingMode: .zeroPageY, cycle: 0, exec: storeAccumulatorAndX)

        default:
            return Instruction(opcode: opcode, mnemonic: .NOP, addressingMode: .implicit, cycle: 2, exec: { _ in .next })
        }
    }
}
