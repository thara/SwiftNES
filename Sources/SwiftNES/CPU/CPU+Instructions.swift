// swiftlint:disable file_length cyclomatic_complexity function_body_length

extension CPU {

    mutating func fetchOpCode(from memory: inout Memory) -> OpCode {
        let opcode = read(at: PC, from: &memory)
        PC &+= 1
        return opcode
    }

    @inline(__always)
    mutating func excuteInstruction(opcode: UInt8, memory: inout Memory) {
        switch opcode {
        case 0xA9:
            LDA(operand: immediate(from: &memory), memory: &memory)
        case 0xA5:
            LDA(operand: zeroPage(from: &memory), memory: &memory)
        case 0xB5:
            LDA(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xAD:
            LDA(operand: absolute(from: &memory), memory: &memory)
        case 0xBD:
            LDA(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0xB9:
            LDA(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0xA1:
            LDA(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0xB1:
            LDA(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0xA2:
            LDX(operand: immediate(from: &memory), memory: &memory)
        case 0xA6:
            LDX(operand: zeroPage(from: &memory), memory: &memory)
        case 0xB6:
            LDX(operand: zeroPageY(from: &memory), memory: &memory)
        case 0xAE:
            LDX(operand: absolute(from: &memory), memory: &memory)
        case 0xBE:
            LDX(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0xA0:
            LDY(operand: immediate(from: &memory), memory: &memory)
        case 0xA4:
            LDY(operand: zeroPage(from: &memory), memory: &memory)
        case 0xB4:
            LDY(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xAC:
            LDY(operand: absolute(from: &memory), memory: &memory)
        case 0xBC:
            LDY(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0x85:
            STA(operand: zeroPage(from: &memory), memory: &memory)
        case 0x95:
            STA(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x8D:
            STA(operand: absolute(from: &memory), memory: &memory)
        case 0x9D:
            STA(operand: absoluteX(from: &memory), memory: &memory)
        case 0x99:
            STA(operand: absoluteY(from: &memory), memory: &memory)
        case 0x81:
            STA(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x91:
            STAWithTick(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x86:
            STX(operand: zeroPage(from: &memory), memory: &memory)
        case 0x96:
            STX(operand: zeroPageY(from: &memory), memory: &memory)
        case 0x8E:
            STX(operand: absolute(from: &memory), memory: &memory)
        case 0x84:
            STY(operand: zeroPage(from: &memory), memory: &memory)
        case 0x94:
            STY(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x8C:
            STY(operand: absolute(from: &memory), memory: &memory)
        case 0xAA:
            TAX(operand: implicit(from: &memory), memory: &memory)
        case 0xBA:
            TSX(operand: implicit(from: &memory), memory: &memory)
        case 0xA8:
            TAY(operand: implicit(from: &memory), memory: &memory)
        case 0x8A:
            TXA(operand: implicit(from: &memory), memory: &memory)
        case 0x9A:
            TXS(operand: implicit(from: &memory), memory: &memory)
        case 0x98:
            TYA(operand: implicit(from: &memory), memory: &memory)

        case 0x48:
            PHA(operand: implicit(from: &memory), memory: &memory)
        case 0x08:
            PHP(operand: implicit(from: &memory), memory: &memory)
        case 0x68:
            PLA(operand: implicit(from: &memory), memory: &memory)
        case 0x28:
            PLP(operand: implicit(from: &memory), memory: &memory)

        case 0x29:
            AND(operand: immediate(from: &memory), memory: &memory)
        case 0x25:
            AND(operand: zeroPage(from: &memory), memory: &memory)
        case 0x35:
            AND(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x2D:
            AND(operand: absolute(from: &memory), memory: &memory)
        case 0x3D:
            AND(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0x39:
            AND(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0x21:
            AND(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x31:
            AND(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x49:
            EOR(operand: immediate(from: &memory), memory: &memory)
        case 0x45:
            EOR(operand: zeroPage(from: &memory), memory: &memory)
        case 0x55:
            EOR(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x4D:
            EOR(operand: absolute(from: &memory), memory: &memory)
        case 0x5D:
            EOR(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0x59:
            EOR(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0x41:
            EOR(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x51:
            EOR(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x09:
            ORA(operand: immediate(from: &memory), memory: &memory)
        case 0x05:
            ORA(operand: zeroPage(from: &memory), memory: &memory)
        case 0x15:
            ORA(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x0D:
            ORA(operand: absolute(from: &memory), memory: &memory)
        case 0x1D:
            ORA(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0x19:
            ORA(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0x01:
            ORA(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x11:
            ORA(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x24:
            BIT(operand: zeroPage(from: &memory), memory: &memory)
        case 0x2C:
            BIT(operand: absolute(from: &memory), memory: &memory)

        case 0x69:
            ADC(operand: immediate(from: &memory), memory: &memory)
        case 0x65:
            ADC(operand: zeroPage(from: &memory), memory: &memory)
        case 0x75:
            ADC(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x6D:
            ADC(operand: absolute(from: &memory), memory: &memory)
        case 0x7D:
            ADC(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0x79:
            ADC(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0x61:
            ADC(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x71:
            ADC(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0xE9:
            SBC(operand: immediate(from: &memory), memory: &memory)
        case 0xE5:
            SBC(operand: zeroPage(from: &memory), memory: &memory)
        case 0xF5:
            SBC(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xED:
            SBC(operand: absolute(from: &memory), memory: &memory)
        case 0xFD:
            SBC(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0xF9:
            SBC(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0xE1:
            SBC(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0xF1:
            SBC(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0xC9:
            CMP(operand: immediate(from: &memory), memory: &memory)
        case 0xC5:
            CMP(operand: zeroPage(from: &memory), memory: &memory)
        case 0xD5:
            CMP(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xCD:
            CMP(operand: absolute(from: &memory), memory: &memory)
        case 0xDD:
            CMP(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0xD9:
            CMP(operand: absoluteYWithPenalty(from: &memory), memory: &memory)
        case 0xC1:
            CMP(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0xD1:
            CMP(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0xE0:
            CPX(operand: immediate(from: &memory), memory: &memory)
        case 0xE4:
            CPX(operand: zeroPage(from: &memory), memory: &memory)
        case 0xEC:
            CPX(operand: absolute(from: &memory), memory: &memory)
        case 0xC0:
            CPY(operand: immediate(from: &memory), memory: &memory)
        case 0xC4:
            CPY(operand: zeroPage(from: &memory), memory: &memory)
        case 0xCC:
            CPY(operand: absolute(from: &memory), memory: &memory)

        case 0xE6:
            INC(operand: zeroPage(from: &memory), memory: &memory)
        case 0xF6:
            INC(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xEE:
            INC(operand: absolute(from: &memory), memory: &memory)
        case 0xFE:
            INC(operand: absoluteX(from: &memory), memory: &memory)
        case 0xE8:
            INX(operand: implicit(from: &memory), memory: &memory)
        case 0xC8:
            INY(operand: implicit(from: &memory), memory: &memory)
        case 0xC6:
            DEC(operand: zeroPage(from: &memory), memory: &memory)
        case 0xD6:
            DEC(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xCE:
            DEC(operand: absolute(from: &memory), memory: &memory)
        case 0xDE:
            DEC(operand: absoluteX(from: &memory), memory: &memory)
        case 0xCA:
            DEX(operand: implicit(from: &memory), memory: &memory)
        case 0x88:
            DEY(operand: implicit(from: &memory), memory: &memory)

        case 0x0A:
            ASLForAccumulator(operand: accumulator(from: &memory), memory: &memory)
        case 0x06:
            ASL(operand: zeroPage(from: &memory), memory: &memory)
        case 0x16:
            ASL(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x0E:
            ASL(operand: absolute(from: &memory), memory: &memory)
        case 0x1E:
            ASL(operand: absoluteX(from: &memory), memory: &memory)
        case 0x4A:
            LSRForAccumulator(operand: accumulator(from: &memory), memory: &memory)
        case 0x46:
            LSR(operand: zeroPage(from: &memory), memory: &memory)
        case 0x56:
            LSR(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x4E:
            LSR(operand: absolute(from: &memory), memory: &memory)
        case 0x5E:
            LSR(operand: absoluteX(from: &memory), memory: &memory)
        case 0x2A:
            ROLForAccumulator(operand: accumulator(from: &memory), memory: &memory)
        case 0x26:
            ROL(operand: zeroPage(from: &memory), memory: &memory)
        case 0x36:
            ROL(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x2E:
            ROL(operand: absolute(from: &memory), memory: &memory)
        case 0x3E:
            ROL(operand: absoluteX(from: &memory), memory: &memory)
        case 0x6A:
            RORForAccumulator(operand: accumulator(from: &memory), memory: &memory)
        case 0x66:
            ROR(operand: zeroPage(from: &memory), memory: &memory)
        case 0x76:
            ROR(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x6E:
            ROR(operand: absolute(from: &memory), memory: &memory)
        case 0x7E:
            ROR(operand: absoluteX(from: &memory), memory: &memory)

        case 0x4C:
            JMP(operand: absolute(from: &memory), memory: &memory)
        case 0x6C:
            JMP(operand: indirect(from: &memory), memory: &memory)
        case 0x20:
            JSR(operand: absolute(from: &memory), memory: &memory)
        case 0x60:
            RTS(operand: implicit(from: &memory), memory: &memory)
        case 0x40:
            RTI(operand: implicit(from: &memory), memory: &memory)

        case 0x90:
            BCC(operand: relative(from: &memory), memory: &memory)
        case 0xB0:
            BCS(operand: relative(from: &memory), memory: &memory)
        case 0xF0:
            BEQ(operand: relative(from: &memory), memory: &memory)
        case 0x30:
            BMI(operand: relative(from: &memory), memory: &memory)
        case 0xD0:
            BNE(operand: relative(from: &memory), memory: &memory)
        case 0x10:
            BPL(operand: relative(from: &memory), memory: &memory)
        case 0x50:
            BVC(operand: relative(from: &memory), memory: &memory)
        case 0x70:
            BVS(operand: relative(from: &memory), memory: &memory)

        case 0x18:
            CLC(operand: implicit(from: &memory), memory: &memory)
        case 0xD8:
            CLD(operand: implicit(from: &memory), memory: &memory)
        case 0x58:
            CLI(operand: implicit(from: &memory), memory: &memory)
        case 0xB8:
            CLV(operand: implicit(from: &memory), memory: &memory)

        case 0x38:
            SEC(operand: implicit(from: &memory), memory: &memory)
        case 0xF8:
            SED(operand: implicit(from: &memory), memory: &memory)
        case 0x78:
            SEI(operand: implicit(from: &memory), memory: &memory)

        case 0x00:
            BRK(operand: implicit(from: &memory), memory: &memory)

        // Undocumented

        case 0xEB:
            SBC(operand: immediate(from: &memory), memory: &memory)

        case 0x04, 0x44, 0x64:
            NOP(operand: zeroPage(from: &memory), memory: &memory)
        case 0x0C:
            NOP(operand: absolute(from: &memory), memory: &memory)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            NOP(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            NOP(operand: implicit(from: &memory), memory: &memory)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            NOP(operand: absoluteXWithPenalty(from: &memory), memory: &memory)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            NOP(operand: immediate(from: &memory), memory: &memory)

        case 0xA3:
            LAX(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0xA7:
            LAX(operand: zeroPage(from: &memory), memory: &memory)
        case 0xAF:
            LAX(operand: absolute(from: &memory), memory: &memory)
        case 0xB3:
            LAX(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0xB7:
            LAX(operand: zeroPageY(from: &memory), memory: &memory)
        case 0xBF:
            LAX(operand: absoluteYWithPenalty(from: &memory), memory: &memory)

        case 0x83:
            SAX(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x87:
            SAX(operand: zeroPage(from: &memory), memory: &memory)
        case 0x8F:
            SAX(operand: absolute(from: &memory), memory: &memory)
        case 0x97:
            SAX(operand: zeroPageY(from: &memory), memory: &memory)

        case 0xC3:
            DCP(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0xC7:
            DCP(operand: zeroPage(from: &memory), memory: &memory)
        case 0xCF:
            DCP(operand: absolute(from: &memory), memory: &memory)
        case 0xD3:
            DCP(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0xD7:
            DCP(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xDB:
            DCP(operand: absoluteY(from: &memory), memory: &memory)
        case 0xDF:
            DCP(operand: absoluteX(from: &memory), memory: &memory)

        case 0xE3:
            ISB(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0xE7:
            ISB(operand: zeroPage(from: &memory), memory: &memory)
        case 0xEF:
            ISB(operand: absolute(from: &memory), memory: &memory)
        case 0xF3:
            ISB(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0xF7:
            ISB(operand: zeroPageX(from: &memory), memory: &memory)
        case 0xFB:
            ISB(operand: absoluteY(from: &memory), memory: &memory)
        case 0xFF:
            ISB(operand: absoluteX(from: &memory), memory: &memory)

        case 0x03:
            SLO(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x07:
            SLO(operand: zeroPage(from: &memory), memory: &memory)
        case 0x0F:
            SLO(operand: absolute(from: &memory), memory: &memory)
        case 0x13:
            SLO(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x17:
            SLO(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x1B:
            SLO(operand: absoluteY(from: &memory), memory: &memory)
        case 0x1F:
            SLO(operand: absoluteX(from: &memory), memory: &memory)

        case 0x23:
            RLA(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x27:
            RLA(operand: zeroPage(from: &memory), memory: &memory)
        case 0x2F:
            RLA(operand: absolute(from: &memory), memory: &memory)
        case 0x33:
            RLA(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x37:
            RLA(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x3B:
            RLA(operand: absoluteY(from: &memory), memory: &memory)
        case 0x3F:
            RLA(operand: absoluteX(from: &memory), memory: &memory)

        case 0x43:
            SRE(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x47:
            SRE(operand: zeroPage(from: &memory), memory: &memory)
        case 0x4F:
            SRE(operand: absolute(from: &memory), memory: &memory)
        case 0x53:
            SRE(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x57:
            SRE(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x5B:
            SRE(operand: absoluteY(from: &memory), memory: &memory)
        case 0x5F:
            SRE(operand: absoluteX(from: &memory), memory: &memory)

        case 0x63:
            RRA(operand: indexedIndirect(from: &memory), memory: &memory)
        case 0x67:
            RRA(operand: zeroPage(from: &memory), memory: &memory)
        case 0x6F:
            RRA(operand: absolute(from: &memory), memory: &memory)
        case 0x73:
            RRA(operand: indirectIndexed(from: &memory), memory: &memory)
        case 0x77:
            RRA(operand: zeroPageX(from: &memory), memory: &memory)
        case 0x7B:
            RRA(operand: absoluteY(from: &memory), memory: &memory)
        case 0x7F:
            RRA(operand: absoluteX(from: &memory), memory: &memory)

        default:
            NOP(operand: implicit(from: &memory), memory: &memory)
        }
    }
}

func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
    return pageCrossed(value: value, operand: operand.u16)
}

func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

func pageCrossed(value: Int, operand: Int) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

// MARK: - Operations
extension CPU {
    // Implements for Load/Store Operations

    /// loadAccumulator
    mutating func LDA(operand: Operand, memory: inout Memory) {
        A = read(at: operand, from: &memory)
    }

    /// loadXRegister
    mutating func LDX(operand: Operand, memory: inout Memory) {
        X = read(at: operand, from: &memory)
    }

    /// loadYRegister
    mutating func LDY(operand: Operand, memory: inout Memory) {
        Y = read(at: operand, from: &memory)
    }

    /// storeAccumulator
    mutating func STA(operand: Operand, memory: inout Memory) {
        write(A, at: operand, to: &memory)
    }

    mutating func STAWithTick(operand: Operand, memory: inout Memory) {
        write(A, at: operand, to: &memory)
        tick()
    }

    /// storeXRegister
    mutating func STX(operand: Operand, memory: inout Memory) {
        write(X, at: operand, to: &memory)
    }

    /// storeYRegister
    mutating func STY(operand: Operand, memory: inout Memory) {
        write(Y, at: operand, to: &memory)
    }

    // MARK: - Register Operations

    /// transferAccumulatorToX
    mutating func TAX(operand: Operand, memory: inout Memory) {
        X = A
        tick()
    }

    /// transferStackPointerToX
    mutating func TSX(operand: Operand, memory: inout Memory) {
        X = S
        tick()
    }

    /// transferAccumulatorToY
    mutating func TAY(operand: Operand, memory: inout Memory) {
        Y = A
        tick()
    }

    /// transferXtoAccumulator
    mutating func TXA(operand: Operand, memory: inout Memory) {
        A = X
        tick()
    }

    /// transferXtoStackPointer
    mutating func TXS(operand: Operand, memory: inout Memory) {
        S = X
        tick()
    }

    /// transferYtoAccumulator
    mutating func TYA(operand: Operand, memory: inout Memory) {
        A = Y
        tick()
    }

    // MARK: - Stack instructions

    /// pushAccumulator
    mutating func PHA(operand: Operand, memory: inout Memory) {
        pushStack(A, to: &memory)
        tick()
    }

    /// pushProcessorStatus
    mutating func PHP(operand: Operand, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | Status.operatedB.rawValue, to: &memory)
        tick()
    }

    /// pullAccumulator
    mutating func PLA(operand: Operand, memory: inout Memory) {
        A = pullStack(from: &memory)
        tick(count: 2)
    }

    /// pullProcessorStatus
    mutating func PLP(operand: Operand, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        P = Status(rawValue: pullStack(from: &memory) & ~Status.B.rawValue | Status.R.rawValue)
        tick(count: 2)
    }

    // MARK: - Logical instructions

    /// bitwiseANDwithAccumulator
    mutating func AND(operand: Operand, memory: inout Memory) {
        A &= read(at: operand, from: &memory)
    }

    /// bitwiseExclusiveOR
    mutating func EOR(operand: Operand, memory: inout Memory) {
        A ^= read(at: operand, from: &memory)
    }

    /// bitwiseORwithAccumulator
    mutating func ORA(operand: Operand, memory: inout Memory) {
        A |= read(at: operand, from: &memory)
    }

    /// testBits
    mutating func BIT(operand: Operand, memory: inout Memory) {
        let value = read(at: operand, from: &memory)
        let data = A & value
        P.remove([.Z, .V, .N])
        if data == 0 { P.formUnion(.Z) } else { P.remove(.Z) }
        if value[6] == 1 { P.formUnion(.V) } else { P.remove(.V) }
        if value[7] == 1 { P.formUnion(.N) } else { P.remove(.N) }
    }

    // MARK: - Arithmetic instructions

    /// addWithCarry
    mutating func ADC(operand: Operand, memory: inout Memory) {
        let a = A
        let val = read(at: operand, from: &memory)
        var result = a &+ val

        if P.contains(.C) { result &+= 1 }

        P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { P.formUnion(.C) }
        if c6 ^ c7 == 1 { P.formUnion(.V) }

        A = result
    }

    /// subtractWithCarry
    mutating func SBC(operand: Operand, memory: inout Memory) {
        let a = A
        let val = ~read(at: operand, from: &memory)
        var result = a &+ val

        if P.contains(.C) { result &+= 1 }

        P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { P.formUnion(.C) }
        if c6 ^ c7 == 1 { P.formUnion(.V) }

        A = result
    }

    /// compareAccumulator
    mutating func CMP(operand: Operand, memory: inout Memory) {
        let cmp = Int16(A) &- Int16(read(at: operand, from: &memory))

        P.remove([.C, .Z, .N])
        P.setZN(cmp)
        if 0 <= cmp { P.formUnion(.C) } else { P.remove(.C) }

    }

    /// compareXRegister
    mutating func CPX(operand: Operand, memory: inout Memory) {
        let value = read(at: operand, from: &memory)
        let cmp = X &- value

        P.remove([.C, .Z, .N])
        P.setZN(cmp)
        if X >= value { P.formUnion(.C) } else { P.remove(.C) }

    }

    /// compareYRegister
    mutating func CPY(operand: Operand, memory: inout Memory) {
        let value = read(at: operand, from: &memory)
        let cmp = Y &- value

        P.remove([.C, .Z, .N])
        P.setZN(cmp)
        if Y >= value { P.formUnion(.C) } else { P.remove(.C) }

    }

    // MARK: - Increment/Decrement instructions

    /// incrementMemory
    mutating func INC(operand: Operand, memory: inout Memory) {
        let result = read(at: operand, from: &memory) &+ 1

        P.setZN(result)
        write(result, at: operand, to: &memory)

        tick()

    }

    /// incrementX
    mutating func INX(operand: Operand, memory: inout Memory) {
        X = X &+ 1
        tick()
    }

    /// incrementY
    mutating func INY(operand: Operand, memory: inout Memory) {
        Y = Y &+ 1
        tick()
    }

    /// decrementMemory
    mutating func DEC(operand: Operand, memory: inout Memory) {
        let result = read(at: operand, from: &memory) &- 1
        P.setZN(result)

        write(result, at: operand, to: &memory)
        tick()
    }

    /// decrementX
    mutating func DEX(operand: Operand, memory: inout Memory) {
        X = X &- 1
        tick()
    }

    /// decrementY
    mutating func DEY(operand: Operand, memory: inout Memory) {
        Y = Y &- 1
        tick()
    }

    // MARK: - Shift instructions

    /// arithmeticShiftLeft
    mutating func ASL(operand: Operand, memory: inout Memory) {
        var data = read(at: operand, from: &memory)

        P.remove([.C, .Z, .N])
        if data[7] == 1 { P.formUnion(.C) }

        data <<= 1

        P.setZN(data)

        write(data, at: operand, to: &memory)

        tick()
    }

    mutating func ASLForAccumulator(operand: Operand, memory: inout Memory) {
        P.remove([.C, .Z, .N])
        if A[7] == 1 { P.formUnion(.C) }

        A <<= 1

        tick()
    }

    /// logicalShiftRight
    mutating func LSR(operand: Operand, memory: inout Memory) {
        var data = read(at: operand, from: &memory)

        P.remove([.C, .Z, .N])
        if data[0] == 1 { P.formUnion(.C) }

        data >>= 1

        P.setZN(data)

        write(data, at: operand, to: &memory)

        tick()
    }

    mutating func LSRForAccumulator(operand: Operand, memory: inout Memory) {
        P.remove([.C, .Z, .N])
        if A[0] == 1 { P.formUnion(.C) }

        A >>= 1

        tick()
    }

    /// rotateLeft
    mutating func ROL(operand: Operand, memory: inout Memory) {
        var data = read(at: operand, from: &memory)
        let c = data & 0x80

        data <<= 1
        if P.contains(.C) { data |= 0x01 }

        P.remove([.C, .Z, .N])
        if c == 0x80 { P.formUnion(.C) }

        P.setZN(data)

        write(data, at: operand, to: &memory)

        tick()
    }

    mutating func ROLForAccumulator(operand: Operand, memory: inout Memory) {
        let c = A & 0x80

        var a = A << 1
        if P.contains(.C) { a |= 0x01 }

        P.remove([.C, .Z, .N])
        if c == 0x80 { P.formUnion(.C) }

        A = a

        tick()
    }

    /// rotateRight
    mutating func ROR(operand: Operand, memory: inout Memory) {
        var data = read(at: operand, from: &memory)
        let c = data & 0x01

        data >>= 1
        if P.contains(.C) { data |= 0x80 }

        P.remove([.C, .Z, .N])
        if c == 1 { P.formUnion(.C) }

        P.setZN(data)

        write(data, at: operand, to: &memory)

        tick()
    }

    mutating func RORForAccumulator(operand: Operand, memory: inout Memory) {
        let c = A & 0x01

        var a = A >> 1
        if P.contains(.C) { a |= 0x80 }

        P.remove([.C, .Z, .N])
        if c == 1 { P.formUnion(.C) }

        A = a

        tick()
    }

    // MARK: - Jump instructions

    /// jump
    mutating func JMP(operand: Operand, memory: inout Memory) {
        PC = operand
    }

    /// jumpToSubroutine
    mutating func JSR(operand: Operand, memory: inout Memory) {
        pushStack(word: PC &- 1, to: &memory)
        tick()
        PC = operand
    }

    /// returnFromSubroutine
    mutating func RTS(operand: Operand, memory: inout Memory) {
        tick(count: 3)
        PC = pullStack(from: &memory) &+ 1
    }

    /// returnFromInterrupt
    mutating func RTI(operand: Operand, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        tick(count: 2)
        P = Status(rawValue: pullStack(from: &memory) & ~Status.B.rawValue | Status.R.rawValue)
        PC = pullStack(from: &memory)
    }

    // MARK: - Branch instructions

    private mutating func branch(operand: Operand, test: Bool) {
        if test {
            tick()
            let pc = Int(PC)
            let offset = Int(operand.i8)
            if pageCrossed(value: pc, operand: offset) {
                tick()
            }
            PC = UInt16(pc &+ offset)
        }
    }

    /// branchIfCarryClear
    mutating func BCC(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: !P.contains(.C))
    }

    /// branchIfCarrySet
    mutating func BCS(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: P.contains(.C))
    }

    /// branchIfEqual
    mutating func BEQ(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: P.contains(.Z))
    }

    /// branchIfMinus
    mutating func BMI(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: P.contains(.N))
    }

    /// branchIfNotEqual
    mutating func BNE(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: !P.contains(.Z))
    }

    /// branchIfPlus
    mutating func BPL(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: !P.contains(.N))
    }

    /// branchIfOverflowClear
    mutating func BVC(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: !P.contains(.V))
    }

    /// branchIfOverflowSet
    mutating func BVS(operand: Operand, memory: inout Memory) {
        branch(operand: operand, test: P.contains(.V))
    }

    // MARK: - Flag control instructions

    /// clearCarry
    mutating func CLC(operand: Operand, memory: inout Memory) {
        P.remove(.C)
        tick()
    }

    /// clearDecimal
    mutating func CLD(operand: Operand, memory: inout Memory) {
        P.remove(.D)
        tick()
    }

    /// clearInterrupt
    mutating func CLI(operand: Operand, memory: inout Memory) {
        P.remove(.I)
        tick()
    }

    /// clearOverflow
    mutating func CLV(operand: Operand, memory: inout Memory) {
        P.remove(.V)
        tick()
    }

    /// setCarryFlag
    mutating func SEC(operand: Operand, memory: inout Memory) {
        P.formUnion(.C)
        tick()
    }

    /// setDecimalFlag
    mutating func SED(operand: Operand, memory: inout Memory) {
        P.formUnion(.D)
        tick()
    }

    /// setInterruptDisable
    mutating func SEI(operand: Operand, memory: inout Memory) {
        P.formUnion(.I)
        tick()
    }

    // MARK: - Misc

    /// forceInterrupt
    mutating func BRK(operand: Operand, memory: inout Memory) {
        pushStack(word: PC, to: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | Status.interruptedB.rawValue, to: &memory)
        tick()
        PC = readWord(at: 0xFFFE, from: &memory)
    }

    /// doNothing
    mutating func NOP(operand: Operand, memory: inout Memory) {
        tick()
    }

    // MARK: - Unofficial

    /// loadAccumulatorAndX
    mutating func LAX(operand: Operand, memory: inout Memory) {
        let data = read(at: operand, from: &memory)
        A = data
        X = data
    }

    /// storeAccumulatorAndX
    mutating func SAX(operand: Operand, memory: inout Memory) {
        write(A & X, at: operand, to: &memory)
    }

    /// decrementMemoryAndCompareAccumulator
    mutating func DCP(operand: Operand, memory: inout Memory) {
        // decrementMemory excluding tick
        let result = read(at: operand, from: &memory) &- 1
        P.setZN(result)
        write(result, at: operand, to: &memory)

        CMP(operand: operand, memory: &memory)
    }

    /// incrementMemoryAndSubtractWithCarry
    mutating func ISB(operand: Operand, memory: inout Memory) {
        // incrementMemory excluding tick
        let result = read(at: operand, from: &memory) &+ 1
        P.setZN(result)
        write(result, at: operand, to: &memory)

        SBC(operand: operand, memory: &memory)
    }

    /// arithmeticShiftLeftAndBitwiseORwithAccumulator
    mutating func SLO(operand: Operand, memory: inout Memory) {
        // arithmeticShiftLeft excluding tick
        var data = read(at: operand, from: &memory)
        P.remove([.C, .Z, .N])
        if data[7] == 1 { P.formUnion(.C) }

        data <<= 1
        P.setZN(data)
        write(data, at: operand, to: &memory)

        ORA(operand: operand, memory: &memory)
    }

    /// rotateLeftAndBitwiseANDwithAccumulator
    mutating func RLA(operand: Operand, memory: inout Memory) {
        // rotateLeft excluding tick
        var data = read(at: operand, from: &memory)
        let c = data & 0x80

        data <<= 1
        if P.contains(.C) { data |= 0x01 }

        P.remove([.C, .Z, .N])
        if c == 0x80 { P.formUnion(.C) }

        P.setZN(data)
        write(data, at: operand, to: &memory)

        AND(operand: operand, memory: &memory)
    }

    /// logicalShiftRightAndBitwiseExclusiveOR
    mutating func SRE(operand: Operand, memory: inout Memory) {
        // logicalShiftRight excluding tick
        var data = read(at: operand, from: &memory)
        P.remove([.C, .Z, .N])
        if data[0] == 1 { P.formUnion(.C) }

        data >>= 1

        P.setZN(data)
        write(data, at: operand, to: &memory)

        EOR(operand: operand, memory: &memory)
    }

    /// rotateRightAndAddWithCarry
    mutating func RRA(operand: Operand, memory: inout Memory) {
        // rotateRight excluding tick
        var data = read(at: operand, from: &memory)
        let c = data & 0x01

        data >>= 1
        if P.contains(.C) { data |= 0x80 }

        P.remove([.C, .Z, .N])
        if c == 1 { P.formUnion(.C) }

        P.setZN(data)
        write(data, at: operand, to: &memory)

        ADC(operand: operand, memory: &memory)
    }
}

// MARK: - Stack
extension CPU {
    @inline(__always)
    mutating func pushStack(_ value: UInt8, to memory: inout Memory) {
        write(value, at: S.u16 &+ 0x100, to: &memory)
        S &-= 1
    }

    @inline(__always)
    mutating func pushStack(word: UInt16, to memory: inout Memory) {
        pushStack(UInt8(word >> 8), to: &memory)
        pushStack(UInt8(word & 0xFF), to: &memory)
    }

    @inline(__always)
    mutating func pullStack(from memory: inout Memory) -> UInt8 {
        S &+= 1
        return read(at: S.u16 &+ 0x100, from: &memory)
    }

    @inline(__always)
    mutating func pullStack(from memory: inout Memory) -> UInt16 {
        let lo: UInt8 = pullStack(from: &memory)
        let ho: UInt8 = pullStack(from: &memory)
        return ho.u16 &<< 8 | lo.u16
    }
}
