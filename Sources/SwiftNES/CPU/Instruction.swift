typealias Operand = UInt16
typealias Operation = ((Operand?) -> PCUpdate)

enum PCUpdate {
    case jump(addr: UInt16)
    case next
}

struct Instruction {
    let mnemonic: Mnemonic
    let addressing: AddressingMode
    let cycle: UInt
    let exec: Operation

    static let NOP = Instruction(mnemonic: .NOP, addressing: .implicit, cycle: 2, exec: { _ in .next })
}

extension CPU {

    func buildInstructionTable() -> [Instruction?] {
        var table: [Instruction?] = Array(repeating: nil, count: 0xFF)
        for i in 0x00..<0xFF {
            table[i] = buildInstruction(opcode: UInt8(i))
        }
        return table
    }

    func buildInstruction(opcode: UInt8) -> Instruction? {
        switch opcode {

        case 0xA9:
            return Instruction(mnemonic: .LDA, addressing: .immediate, cycle: 2, exec: loadAccumulator)
        case 0xA5:
            return Instruction(mnemonic: .LDA, addressing: .zeroPage, cycle: 3, exec: loadAccumulator)
        case 0xB5:
            return Instruction(mnemonic: .LDA, addressing: .zeroPageX, cycle: 4, exec: loadAccumulator)
        case 0xAD:
            return Instruction(mnemonic: .LDA, addressing: .absolute, cycle: 4, exec: loadAccumulator)
        case 0xBD:
            return Instruction(mnemonic: .LDA, addressing: .absoluteX, cycle: 4, exec: loadAccumulator)
        case 0xB9:
            return Instruction(mnemonic: .LDA, addressing: .absoluteY, cycle: 4, exec: loadAccumulator)
        case 0xA1:
            return Instruction(mnemonic: .LDA, addressing: .indexedIndirect, cycle: 6, exec: loadAccumulator)
        case 0xB1:
            return Instruction(mnemonic: .LDA, addressing: .indirectIndexed, cycle: 5, exec: loadAccumulator)
        case 0xA2:
            return Instruction(mnemonic: .LDX, addressing: .immediate, cycle: 2, exec: loadXRegister)
        case 0xA6:
            return Instruction(mnemonic: .LDX, addressing: .zeroPage, cycle: 3, exec: loadXRegister)
        case 0xB6:
            return Instruction(mnemonic: .LDX, addressing: .zeroPageY, cycle: 4, exec: loadXRegister)
        case 0xAE:
            return Instruction(mnemonic: .LDX, addressing: .absolute, cycle: 4, exec: loadXRegister)
        case 0xBE:
            return Instruction(mnemonic: .LDX, addressing: .absoluteY, cycle: 4, exec: loadXRegister)
        case 0xA0:
            return Instruction(mnemonic: .LDY, addressing: .immediate, cycle: 2, exec: loadYRegister)
        case 0xA4:
            return Instruction(mnemonic: .LDY, addressing: .zeroPage, cycle: 3, exec: loadYRegister)
        case 0xB4:
            return Instruction(mnemonic: .LDY, addressing: .zeroPageX, cycle: 4, exec: loadYRegister)
        case 0xAC:
            return Instruction(mnemonic: .LDY, addressing: .absolute, cycle: 4, exec: loadYRegister)
        case 0xBC:
            return Instruction(mnemonic: .LDY, addressing: .absoluteX, cycle: 4, exec: loadYRegister)
        case 0x85:
            return Instruction(mnemonic: .STA, addressing: .zeroPage, cycle: 3, exec: storeAccumulator)
        case 0x95:
            return Instruction(mnemonic: .STA, addressing: .zeroPageX, cycle: 4, exec: storeAccumulator)
        case 0x8D:
            return Instruction(mnemonic: .STA, addressing: .absolute, cycle: 4, exec: storeAccumulator)
        case 0x9D:
            return Instruction(mnemonic: .STA, addressing: .absoluteX, cycle: 5, exec: storeAccumulator)
        case 0x99:
            return Instruction(mnemonic: .STA, addressing: .absoluteY, cycle: 5, exec: storeAccumulator)
        case 0x81:
            return Instruction(mnemonic: .STA, addressing: .indexedIndirect, cycle: 6, exec: storeAccumulator)
        case 0x91:
            return Instruction(mnemonic: .STA, addressing: .indirectIndexed, cycle: 6, exec: storeAccumulator)
        case 0x86:
            return Instruction(mnemonic: .STX, addressing: .zeroPage, cycle: 3, exec: storeXRegister)
        case 0x96:
            return Instruction(mnemonic: .STX, addressing: .zeroPageY, cycle: 4, exec: storeXRegister)
        case 0x8E:
            return Instruction(mnemonic: .STX, addressing: .absolute, cycle: 4, exec: storeXRegister)
        case 0x84:
            return Instruction(mnemonic: .STY, addressing: .zeroPage, cycle: 3, exec: storeYRegister)
        case 0x94:
            return Instruction(mnemonic: .STY, addressing: .zeroPageY, cycle: 4, exec: storeYRegister)
        case 0x8C:
            return Instruction(mnemonic: .STY, addressing: .absolute, cycle: 4, exec: storeYRegister)
        case 0xAA:
            return Instruction(mnemonic: .TAX, addressing: .implicit, cycle: 2, exec: transferAccumulatorToX)
        case 0xA8:
            return Instruction(mnemonic: .TAY, addressing: .implicit, cycle: 2, exec: transferAccumulatorToY)
        case 0x8A:
            return Instruction(mnemonic: .TXA, addressing: .implicit, cycle: 2, exec: transferXtoAccumulator)
        case 0x98:
            return Instruction(mnemonic: .TYA, addressing: .implicit, cycle: 2, exec: transferYtoAccumulator)

        case 0x48:
            return Instruction(mnemonic: .PHA, addressing: .implicit, cycle: 3, exec: pushAccumulator)
        case 0x08:
            return Instruction(mnemonic: .PHP, addressing: .implicit, cycle: 3, exec: pushProcessorStatus)
        case 0x68:
            return Instruction(mnemonic: .PLA, addressing: .implicit, cycle: 3, exec: pullAccumulator)
        case 0x28:
            return Instruction(mnemonic: .PLP, addressing: .implicit, cycle: 4, exec: pullProcessorStatus)

        case 0x29:
            return Instruction(mnemonic: .AND, addressing: .immediate, cycle: 2, exec: bitwiseANDwithAccumulator)
        case 0x25:
            return Instruction(mnemonic: .AND, addressing: .zeroPage, cycle: 3, exec: bitwiseANDwithAccumulator)
        case 0x35:
            return Instruction(mnemonic: .AND, addressing: .zeroPageX, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x2D:
            return Instruction(mnemonic: .AND, addressing: .absolute, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x3D:
            return Instruction(mnemonic: .AND, addressing: .absoluteX, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x39:
            return Instruction(mnemonic: .AND, addressing: .absoluteY, cycle: 4, exec: bitwiseANDwithAccumulator)
        case 0x21:
            return Instruction(mnemonic: .AND, addressing: .indexedIndirect, cycle: 6, exec: bitwiseANDwithAccumulator)
        case 0x31:
            return Instruction(mnemonic: .AND, addressing: .indirectIndexed, cycle: 5, exec: bitwiseANDwithAccumulator)
        case 0x49:
            return Instruction(mnemonic: .EOR, addressing: .immediate, cycle: 2, exec: bitwiseExclusiveOR)
        case 0x45:
            return Instruction(mnemonic: .EOR, addressing: .zeroPage, cycle: 3, exec: bitwiseExclusiveOR)
        case 0x55:
            return Instruction(mnemonic: .EOR, addressing: .zeroPageX, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x4D:
            return Instruction(mnemonic: .EOR, addressing: .absolute, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x5D:
            return Instruction(mnemonic: .EOR, addressing: .absoluteX, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x59:
            return Instruction(mnemonic: .EOR, addressing: .absoluteY, cycle: 4, exec: bitwiseExclusiveOR)
        case 0x41:
            return Instruction(mnemonic: .EOR, addressing: .indexedIndirect, cycle: 6, exec: bitwiseExclusiveOR)
        case 0x51:
            return Instruction(mnemonic: .EOR, addressing: .indirectIndexed, cycle: 5, exec: bitwiseExclusiveOR)
        case 0x09:
            return Instruction(mnemonic: .ORA, addressing: .immediate, cycle: 2, exec: bitwiseORwithAccumulator)
        case 0x05:
            return Instruction(mnemonic: .ORA, addressing: .zeroPage, cycle: 3, exec: bitwiseORwithAccumulator)
        case 0x15:
            return Instruction(mnemonic: .ORA, addressing: .zeroPageX, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x0D:
            return Instruction(mnemonic: .ORA, addressing: .absolute, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x1D:
            return Instruction(mnemonic: .ORA, addressing: .absoluteX, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x19:
            return Instruction(mnemonic: .ORA, addressing: .absoluteY, cycle: 4, exec: bitwiseORwithAccumulator)
        case 0x01:
            return Instruction(mnemonic: .ORA, addressing: .indexedIndirect, cycle: 6, exec: bitwiseORwithAccumulator)
        case 0x11:
            return Instruction(mnemonic: .ORA, addressing: .indirectIndexed, cycle: 5, exec: bitwiseORwithAccumulator)
        case 0x24:
            return Instruction(mnemonic: .BIT, addressing: .zeroPage, cycle: 3, exec: testBits)
        case 0x2C:
            return Instruction(mnemonic: .BIT, addressing: .absolute, cycle: 4, exec: testBits)

        case 0x69:
            return Instruction(mnemonic: .ADC, addressing: .immediate, cycle: 2, exec: addWithCarry)
        case 0x65:
            return Instruction(mnemonic: .ADC, addressing: .zeroPage, cycle: 3, exec: addWithCarry)
        case 0x75:
            return Instruction(mnemonic: .ADC, addressing: .zeroPageX, cycle: 4, exec: addWithCarry)
        case 0x6D:
            return Instruction(mnemonic: .ADC, addressing: .absolute, cycle: 4, exec: addWithCarry)
        case 0x7D:
            return Instruction(mnemonic: .ADC, addressing: .absoluteX, cycle: 4, exec: addWithCarry)
        case 0x79:
            return Instruction(mnemonic: .ADC, addressing: .absoluteY, cycle: 4, exec: addWithCarry)
        case 0x61:
            return Instruction(mnemonic: .ADC, addressing: .indexedIndirect, cycle: 6, exec: addWithCarry)
        case 0x71:
            return Instruction(mnemonic: .ADC, addressing: .indirectIndexed, cycle: 5, exec: addWithCarry)
        case 0xE9:
            return Instruction(mnemonic: .SBC, addressing: .immediate, cycle: 2, exec: subtractWithCarry)
        case 0xE5:
            return Instruction(mnemonic: .SBC, addressing: .zeroPage, cycle: 3, exec: subtractWithCarry)
        case 0xF5:
            return Instruction(mnemonic: .SBC, addressing: .zeroPageX, cycle: 4, exec: subtractWithCarry)
        case 0xED:
            return Instruction(mnemonic: .SBC, addressing: .absolute, cycle: 4, exec: subtractWithCarry)
        case 0xFD:
            return Instruction(mnemonic: .SBC, addressing: .absoluteX, cycle: 4, exec: subtractWithCarry)
        case 0xF9:
            return Instruction(mnemonic: .SBC, addressing: .absoluteY, cycle: 4, exec: subtractWithCarry)
        case 0xE1:
            return Instruction(mnemonic: .SBC, addressing: .indexedIndirect, cycle: 6, exec: subtractWithCarry)
        case 0xF1:
            return Instruction(mnemonic: .SBC, addressing: .indirectIndexed, cycle: 5, exec: subtractWithCarry)
        case 0xC9:
            return Instruction(mnemonic: .CMP, addressing: .immediate, cycle: 2, exec: compareAccumulator)
        case 0xC5:
            return Instruction(mnemonic: .CMP, addressing: .zeroPage, cycle: 3, exec: compareAccumulator)
        case 0xD5:
            return Instruction(mnemonic: .CMP, addressing: .zeroPageX, cycle: 4, exec: compareAccumulator)
        case 0xCD:
            return Instruction(mnemonic: .CMP, addressing: .absolute, cycle: 4, exec: compareAccumulator)
        case 0xDD:
            return Instruction(mnemonic: .CMP, addressing: .absoluteX, cycle: 4, exec: compareAccumulator)
        case 0xD9:
            return Instruction(mnemonic: .CMP, addressing: .absoluteY, cycle: 4, exec: compareAccumulator)
        case 0xC1:
            return Instruction(mnemonic: .CMP, addressing: .indexedIndirect, cycle: 6, exec: compareAccumulator)
        case 0xD1:
            return Instruction(mnemonic: .CMP, addressing: .indirectIndexed, cycle: 5, exec: compareAccumulator)
        case 0xE0:
            return Instruction(mnemonic: .CPX, addressing: .immediate, cycle: 2, exec: compareXRegister)
        case 0xE4:
            return Instruction(mnemonic: .CPX, addressing: .zeroPage, cycle: 3, exec: compareXRegister)
        case 0xEC:
            return Instruction(mnemonic: .CPX, addressing: .absolute, cycle: 4, exec: compareXRegister)
        case 0xC0:
            return Instruction(mnemonic: .CPY, addressing: .immediate, cycle: 2, exec: compareYRegister)
        case 0xC4:
            return Instruction(mnemonic: .CPY, addressing: .zeroPage, cycle: 3, exec: compareYRegister)
        case 0xCC:
            return Instruction(mnemonic: .CPY, addressing: .absolute, cycle: 4, exec: compareYRegister)

        case 0xE6:
            return Instruction(mnemonic: .INC, addressing: .zeroPage, cycle: 5, exec: incrementMemory)
        case 0xF6:
            return Instruction(mnemonic: .INC, addressing: .zeroPageX, cycle: 6, exec: incrementMemory)
        case 0xEE:
            return Instruction(mnemonic: .INC, addressing: .absolute, cycle: 6, exec: incrementMemory)
        case 0xFE:
            return Instruction(mnemonic: .INC, addressing: .absoluteX, cycle: 7, exec: incrementMemory)
        case 0xE8:
            return Instruction(mnemonic: .INX, addressing: .implicit, cycle: 2, exec: incrementX)
        case 0xC8:
            return Instruction(mnemonic: .INY, addressing: .implicit, cycle: 2, exec: incrementY)
        case 0xC6:
            return Instruction(mnemonic: .DEC, addressing: .zeroPage, cycle: 5, exec: decrementMemory)
        case 0xD6:
            return Instruction(mnemonic: .DEC, addressing: .zeroPageX, cycle: 6, exec: decrementMemory)
        case 0xCE:
            return Instruction(mnemonic: .DEC, addressing: .absolute, cycle: 6, exec: decrementMemory)
        case 0xDE:
            return Instruction(mnemonic: .DEC, addressing: .absoluteX, cycle: 7, exec: decrementMemory)
        case 0xCA:
            return Instruction(mnemonic: .DEX, addressing: .implicit, cycle: 2, exec: decrementX)
        case 0x88:
            return Instruction(mnemonic: .DEY, addressing: .implicit, cycle: 2, exec: decrementY)

        case 0x0A:
            return Instruction(mnemonic: .ASL, addressing: .accumulator, cycle: 2, exec: arithmeticShiftLeftForAccumulator)
        case 0x06:
            return Instruction(mnemonic: .ASL, addressing: .zeroPage, cycle: 5, exec: arithmeticShiftLeft)
        case 0x16:
            return Instruction(mnemonic: .ASL, addressing: .zeroPageX, cycle: 6, exec: arithmeticShiftLeft)
        case 0x0E:
            return Instruction(mnemonic: .ASL, addressing: .absolute, cycle: 6, exec: arithmeticShiftLeft)
        case 0x1E:
            return Instruction(mnemonic: .ASL, addressing: .absoluteX, cycle: 7, exec: arithmeticShiftLeft)
        case 0x4A:
            return Instruction(mnemonic: .LSR, addressing: .accumulator, cycle: 2, exec: logicalShiftRightForAccumulator)
        case 0x46:
            return Instruction(mnemonic: .LSR, addressing: .zeroPage, cycle: 5, exec: logicalShiftRight)
        case 0x56:
            return Instruction(mnemonic: .LSR, addressing: .zeroPageX, cycle: 6, exec: logicalShiftRight)
        case 0x4E:
            return Instruction(mnemonic: .LSR, addressing: .absolute, cycle: 6, exec: logicalShiftRight)
        case 0x5E:
            return Instruction(mnemonic: .LSR, addressing: .absoluteX, cycle: 7, exec: logicalShiftRight)
        case 0x2A:
            return Instruction(mnemonic: .ROL, addressing: .accumulator, cycle: 2, exec: rotateLeftForAccumulator)
        case 0x26:
            return Instruction(mnemonic: .ROL, addressing: .zeroPage, cycle: 5, exec: rotateLeft)
        case 0x36:
            return Instruction(mnemonic: .ROL, addressing: .zeroPageX, cycle: 6, exec: rotateLeft)
        case 0x2E:
            return Instruction(mnemonic: .ROL, addressing: .absolute, cycle: 6, exec: rotateLeft)
        case 0x3E:
            return Instruction(mnemonic: .ROL, addressing: .absoluteX, cycle: 7, exec: rotateLeft)
        case 0x6A:
            return Instruction(mnemonic: .ROR, addressing: .accumulator, cycle: 2, exec: rotateRightForAccumulator)
        case 0x66:
            return Instruction(mnemonic: .ROR, addressing: .zeroPage, cycle: 5, exec: rotateRight)
        case 0x76:
            return Instruction(mnemonic: .ROR, addressing: .zeroPageX, cycle: 6, exec: rotateRight)
        case 0x6E:
            return Instruction(mnemonic: .ROR, addressing: .absolute, cycle: 6, exec: rotateRight)
        case 0x7E:
            return Instruction(mnemonic: .ROR, addressing: .absoluteX, cycle: 7, exec: rotateRight)

        case 0x4C:
            return Instruction(mnemonic: .JMP, addressing: .absolute, cycle: 3, exec: jump)
        case 0x6C:
            return Instruction(mnemonic: .JMP, addressing: .indirect, cycle: 5, exec: jump)
        case 0x20:
            return Instruction(mnemonic: .JSR, addressing: .absolute, cycle: 6, exec: jumpToSubroutine)
        case 0x60:
            return Instruction(mnemonic: .RTS, addressing: .implicit, cycle: 6, exec: returnFromSubroutine)
        case 0x40:
            return Instruction(mnemonic: .RTI, addressing: .implicit, cycle: 6, exec: returnFromInterrupt)

        case 0x90:
            return Instruction(mnemonic: .BCC, addressing: .relative, cycle: 2, exec: branchIfCarryClear)
        case 0xB0:
            return Instruction(mnemonic: .BCS, addressing: .relative, cycle: 2, exec: branchIfCarrySet)
        case 0xF0:
            return Instruction(mnemonic: .BEQ, addressing: .relative, cycle: 2, exec: branchIfEqual)
        case 0x30:
            return Instruction(mnemonic: .BMI, addressing: .relative, cycle: 2, exec: branchIfMinus)
        case 0xD0:
            return Instruction(mnemonic: .BNE, addressing: .relative, cycle: 2, exec: branchIfNotEqual)
        case 0x10:
            return Instruction(mnemonic: .BPL, addressing: .relative, cycle: 2, exec: branchIfPlus)
        case 0x50:
            return Instruction(mnemonic: .BVC, addressing: .relative, cycle: 2, exec: branchIfOverflowClear)
        case 0x70:
            return Instruction(mnemonic: .BVS, addressing: .relative, cycle: 2, exec: branchIfOverflowSet)

        case 0x18:
            return Instruction(mnemonic: .CLC, addressing: .implicit, cycle: 2, exec: clearCarry)
        case 0xD8:
            return Instruction(mnemonic: .CLD, addressing: .implicit, cycle: 2, exec: clearDecimal)
        case 0x58:
            return Instruction(mnemonic: .CLI, addressing: .implicit, cycle: 2, exec: clearInterrupt)
        case 0xB8:
            return Instruction(mnemonic: .CLV, addressing: .implicit, cycle: 2, exec: clearOverflow)

        case 0x38:
            return Instruction(mnemonic: .SEC, addressing: .implicit, cycle: 2, exec: setCarryFlag)
        case 0xF8:
            return Instruction(mnemonic: .SED, addressing: .implicit, cycle: 2, exec: setDecimalFlag)
        case 0x78:
            return Instruction(mnemonic: .SEI, addressing: .implicit, cycle: 2, exec: setInterruptDisable)

        case 0x00:
            return Instruction(mnemonic: .BRK, addressing: .implicit, cycle: 2, exec: forceInterrupt)
        case 0xEA:
            return .NOP

        default:
            return nil
        }
    }
}

// http://obelisk.me.uk/6502/reference.html
enum Mnemonic {
    // MARK: - Load/Store Operations

    /// Load Accumulator
    case LDA
    /// Load X Register
    case LDX
    /// Load Y Register
    case LDY
    /// Store Accumulator
    case STA
    /// Store X Register
    case STX
    /// Store Y Register
    case STY

    // MARK: - Register Operations

    /// Transfer Accumulator to X
    case TAX
    /// Transfer Accumulator to Y
    case TAY
    /// Transfer X to Accumulator
    case TXA
    /// Transfer Y to Accumulator
    case TYA

    // MARK: - Stack instructions

    /// Push Accumulator
    case PHA
    /// Push Processor Status
    case PHP
    /// Pull Accumulator
    case PLA
    /// Pull Processor Status
    case PLP

    // MARK: - Logical instructions

    /// Logical AND
    case AND
    /// Exclusive OR
    case EOR
    /// Logical Inclusive OR
    case ORA
    /// Branch if Carry Clear
    case BIT

    // MARK: - Arithmetic instructions

    /// Add with Carry
    case ADC
    /// Subtract with Carry
    case SBC
    /// Compare
    case CMP
    /// Compare X Register
    case CPX
    /// Compare Y Register
    case CPY

    // MARK: - Increment/Decrement instructions

    /// Increment Memory
    case INC
    /// Increment X Register
    case INX
    /// Increment Y Register
    case INY
    /// Decrement Memory
    case DEC
    /// Decrement X Register
    case DEX
    /// Decrement Y Register
    case DEY

    // MARK: - Shift instructions

    /// Arithmetic Shift Left
    case ASL
    /// Logical Shift Right
    case LSR
    /// Rotate Left
    case ROL
    /// Rotate Right
    case ROR

    // MARK: - Jump instructions

    /// Jump
    case JMP
    /// Jump to Subroutine
    case JSR
    /// Return from Subroutine
    case RTS
    /// Return from Interrupt
    case RTI

    // MARK: - Branch instructions

    /// Branch if Carry Clear
    case BCC
    /// Branch if Carry Set
    case BCS
    /// Branch if Equal
    case BEQ
    /// Branch if Minus
    case BMI
    /// Branch if Not Equal
    case BNE
    /// Branch if Positive
    case BPL
    /// Branch if Overflow Clear
    case BVC
    /// Branch if Overflow Set
    case BVS

    // MARK: - Flag control instructions

    /// Clear Carry Flag
    case CLC
    /// Clear Decimal Mode
    case CLD
    /// Clear Interrupt Disable
    case CLI
    /// Clear Overflow Flag
    case CLV
    ///  Set Carry Flag
    case SEC
    ///  Set Decimal Flag
    case SED
    ///  Set Interrupt Disable
    case SEI

    // MARK: - Misc

    /// Force Interrupt
    case BRK
    /// No Operation
    case NOP
}
