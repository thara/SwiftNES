typealias OpCode = UInt8

typealias Operand = UInt16

// MARK: CPU Addressing modes

// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
extension CPU {

    @inline(__always)
    mutating func implicit() -> UInt16 {
        return 0x00
    }

    @inline(__always)
    mutating func accumulator() -> UInt16 {
        return A.u16
    }

    @inline(__always)
    mutating func immediate() -> UInt16 {
        let operand = PC
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPage<M: Memory>(with mem: M) -> UInt16 {
        let operand = read(at: PC, with: mem).u16 & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageX<M: Memory>(with mem: M) -> UInt16 {
        tick()

        let operand = (read(at: PC, with: mem).u16 &+ X.u16) & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageY<M: Memory>(with mem: M) -> UInt16 {
        tick()

        let operand = (read(at: PC, with: mem).u16 &+ Y.u16) & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func absolute<M: Memory>(with mem: M) -> UInt16 {
        let operand = readWord(at: PC, with: mem)
        PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func absoluteX<M: Memory>(with mem: M) -> UInt16 {
        let data = readWord(at: PC, with: mem)
        let operand = data &+ X.u16 & 0xFFFF
        PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteXWithPenalty<M: Memory>(with mem: M) -> UInt16 {
        let data = readWord(at: PC, with: mem)
        let operand = data &+ X.u16 & 0xFFFF
        PC &+= 2

        if pageCrossed(value: data, operand: X) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func absoluteY<M: Memory>(with mem: M) -> UInt16 {
        let data = readWord(at: PC, with: mem)
        let operand = data &+ Y.u16 & 0xFFFF
        PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteYWithPenalty<M: Memory>(with mem: M) -> UInt16 {
        let data = readWord(at: PC, with: mem)
        let operand = data &+ Y.u16 & 0xFFFF
        PC &+= 2

        if pageCrossed(value: data, operand: Y) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func relative<M: Memory>(with mem: M) -> UInt16 {
        let operand = read(at: PC, with: mem).u16
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func indirect<M: Memory>(with mem: M) -> UInt16 {
        let data = readWord(at: PC, with: mem)
        let operand = readOnIndirect(operand: data, with: mem)
        PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func indexedIndirect<M: Memory>(with mem: M) -> UInt16 {
        let data = read(at: PC, with: mem)
        let operand = readOnIndirect(operand: (data &+ X).u16 & 0xFF, with: mem)
        PC &+= 1

        tick()

        return operand
    }

    @inline(__always)
    mutating func indirectIndexed<M: Memory>(with mem: M) -> UInt16 {
        let data = read(at: PC, with: mem).u16
        let operand = readOnIndirect(operand: data, with: mem) &+ Y.u16
        PC &+= 1

        if pageCrossed(value: operand &- Y.u16, operand: Y) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func readOnIndirect<M: Memory>(operand: UInt16, with mem: M) -> UInt16 {
        let low = read(at: operand, with: mem).u16
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF), with: mem).u16 &<< 8  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}

@inline(__always)
func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
    return pageCrossed(value: value, operand: operand.u16)
}

@inline(__always)
func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

@inline(__always)
func pageCrossed(value: Int, operand: Int) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

// MARK: CPU instructions
// swiftlint:disable file_length cyclomatic_complexity function_body_length
extension CPU {

    @inline(__always)
    mutating func fetchOperand<M: Memory>(from mem: M) -> OpCode {
        let opcode = read(at: PC, with: mem)
        PC &+= 1
        return opcode
    }

    @inline(__always)
    mutating func excuteInstruction<M: Memory>(opcode: OpCode, with mem: M) {
        switch opcode {
        case 0xA9:
            LDA(operand: immediate(), with: mem)
        case 0xA5:
            LDA(operand: zeroPage(with: mem), with: mem)
        case 0xB5:
            LDA(operand: zeroPageX(with: mem), with: mem)
        case 0xAD:
            LDA(operand: absolute(with: mem), with: mem)
        case 0xBD:
            LDA(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0xB9:
            LDA(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0xA1:
            LDA(operand: indexedIndirect(with: mem), with: mem)
        case 0xB1:
            LDA(operand: indirectIndexed(with: mem), with: mem)
        case 0xA2:
            LDX(operand: immediate(), with: mem)
        case 0xA6:
            LDX(operand: zeroPage(with: mem), with: mem)
        case 0xB6:
            LDX(operand: zeroPageY(with: mem), with: mem)
        case 0xAE:
            LDX(operand: absolute(with: mem), with: mem)
        case 0xBE:
            LDX(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0xA0:
            LDY(operand: immediate(), with: mem)
        case 0xA4:
            LDY(operand: zeroPage(with: mem), with: mem)
        case 0xB4:
            LDY(operand: zeroPageX(with: mem), with: mem)
        case 0xAC:
            LDY(operand: absolute(with: mem), with: mem)
        case 0xBC:
            LDY(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0x85:
            STA(operand: zeroPage(with: mem), with: mem)
        case 0x95:
            STA(operand: zeroPageX(with: mem), with: mem)
        case 0x8D:
            STA(operand: absolute(with: mem), with: mem)
        case 0x9D:
            STA(operand: absoluteX(with: mem), with: mem)
        case 0x99:
            STA(operand: absoluteY(with: mem), with: mem)
        case 0x81:
            STA(operand: indexedIndirect(with: mem), with: mem)
        case 0x91:
            STAWithTick(operand: indirectIndexed(with: mem), with: mem)
        case 0x86:
            STX(operand: zeroPage(with: mem), with: mem)
        case 0x96:
            STX(operand: zeroPageY(with: mem), with: mem)
        case 0x8E:
            STX(operand: absolute(with: mem), with: mem)
        case 0x84:
            STY(operand: zeroPage(with: mem), with: mem)
        case 0x94:
            STY(operand: zeroPageX(with: mem), with: mem)
        case 0x8C:
            STY(operand: absolute(with: mem), with: mem)
        case 0xAA:
            TAX(operand: implicit(), with: mem)
        case 0xBA:
            TSX(operand: implicit(), with: mem)
        case 0xA8:
            TAY(operand: implicit(), with: mem)
        case 0x8A:
            TXA(operand: implicit(), with: mem)
        case 0x9A:
            TXS(operand: implicit(), with: mem)
        case 0x98:
            TYA(operand: implicit(), with: mem)

        case 0x48:
            PHA(operand: implicit(), with: mem)
        case 0x08:
            PHP(operand: implicit(), with: mem)
        case 0x68:
            PLA(operand: implicit(), with: mem)
        case 0x28:
            PLP(operand: implicit(), with: mem)

        case 0x29:
            AND(operand: immediate(), with: mem)
        case 0x25:
            AND(operand: zeroPage(with: mem), with: mem)
        case 0x35:
            AND(operand: zeroPageX(with: mem), with: mem)
        case 0x2D:
            AND(operand: absolute(with: mem), with: mem)
        case 0x3D:
            AND(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0x39:
            AND(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0x21:
            AND(operand: indexedIndirect(with: mem), with: mem)
        case 0x31:
            AND(operand: indirectIndexed(with: mem), with: mem)
        case 0x49:
            EOR(operand: immediate(), with: mem)
        case 0x45:
            EOR(operand: zeroPage(with: mem), with: mem)
        case 0x55:
            EOR(operand: zeroPageX(with: mem), with: mem)
        case 0x4D:
            EOR(operand: absolute(with: mem), with: mem)
        case 0x5D:
            EOR(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0x59:
            EOR(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0x41:
            EOR(operand: indexedIndirect(with: mem), with: mem)
        case 0x51:
            EOR(operand: indirectIndexed(with: mem), with: mem)
        case 0x09:
            ORA(operand: immediate(), with: mem)
        case 0x05:
            ORA(operand: zeroPage(with: mem), with: mem)
        case 0x15:
            ORA(operand: zeroPageX(with: mem), with: mem)
        case 0x0D:
            ORA(operand: absolute(with: mem), with: mem)
        case 0x1D:
            ORA(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0x19:
            ORA(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0x01:
            ORA(operand: indexedIndirect(with: mem), with: mem)
        case 0x11:
            ORA(operand: indirectIndexed(with: mem), with: mem)
        case 0x24:
            BIT(operand: zeroPage(with: mem), with: mem)
        case 0x2C:
            BIT(operand: absolute(with: mem), with: mem)

        case 0x69:
            ADC(operand: immediate(), with: mem)
        case 0x65:
            ADC(operand: zeroPage(with: mem), with: mem)
        case 0x75:
            ADC(operand: zeroPageX(with: mem), with: mem)
        case 0x6D:
            ADC(operand: absolute(with: mem), with: mem)
        case 0x7D:
            ADC(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0x79:
            ADC(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0x61:
            ADC(operand: indexedIndirect(with: mem), with: mem)
        case 0x71:
            ADC(operand: indirectIndexed(with: mem), with: mem)
        case 0xE9:
            SBC(operand: immediate(), with: mem)
        case 0xE5:
            SBC(operand: zeroPage(with: mem), with: mem)
        case 0xF5:
            SBC(operand: zeroPageX(with: mem), with: mem)
        case 0xED:
            SBC(operand: absolute(with: mem), with: mem)
        case 0xFD:
            SBC(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0xF9:
            SBC(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0xE1:
            SBC(operand: indexedIndirect(with: mem), with: mem)
        case 0xF1:
            SBC(operand: indirectIndexed(with: mem), with: mem)
        case 0xC9:
            CMP(operand: immediate(), with: mem)
        case 0xC5:
            CMP(operand: zeroPage(with: mem), with: mem)
        case 0xD5:
            CMP(operand: zeroPageX(with: mem), with: mem)
        case 0xCD:
            CMP(operand: absolute(with: mem), with: mem)
        case 0xDD:
            CMP(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0xD9:
            CMP(operand: absoluteYWithPenalty(with: mem), with: mem)
        case 0xC1:
            CMP(operand: indexedIndirect(with: mem), with: mem)
        case 0xD1:
            CMP(operand: indirectIndexed(with: mem), with: mem)
        case 0xE0:
            CPX(operand: immediate(), with: mem)
        case 0xE4:
            CPX(operand: zeroPage(with: mem), with: mem)
        case 0xEC:
            CPX(operand: absolute(with: mem), with: mem)
        case 0xC0:
            CPY(operand: immediate(), with: mem)
        case 0xC4:
            CPY(operand: zeroPage(with: mem), with: mem)
        case 0xCC:
            CPY(operand: absolute(with: mem), with: mem)

        case 0xE6:
            INC(operand: zeroPage(with: mem), with: mem)
        case 0xF6:
            INC(operand: zeroPageX(with: mem), with: mem)
        case 0xEE:
            INC(operand: absolute(with: mem), with: mem)
        case 0xFE:
            INC(operand: absoluteX(with: mem), with: mem)
        case 0xE8:
            INX(operand: implicit(), with: mem)
        case 0xC8:
            INY(operand: implicit(), with: mem)
        case 0xC6:
            DEC(operand: zeroPage(with: mem), with: mem)
        case 0xD6:
            DEC(operand: zeroPageX(with: mem), with: mem)
        case 0xCE:
            DEC(operand: absolute(with: mem), with: mem)
        case 0xDE:
            DEC(operand: absoluteX(with: mem), with: mem)
        case 0xCA:
            DEX(operand: implicit(), with: mem)
        case 0x88:
            DEY(operand: implicit(), with: mem)

        case 0x0A:
            ASLForAccumulator(operand: accumulator(), with: mem)
        case 0x06:
            ASL(operand: zeroPage(with: mem), with: mem)
        case 0x16:
            ASL(operand: zeroPageX(with: mem), with: mem)
        case 0x0E:
            ASL(operand: absolute(with: mem), with: mem)
        case 0x1E:
            ASL(operand: absoluteX(with: mem), with: mem)
        case 0x4A:
            LSRForAccumulator(operand: accumulator(), with: mem)
        case 0x46:
            LSR(operand: zeroPage(with: mem), with: mem)
        case 0x56:
            LSR(operand: zeroPageX(with: mem), with: mem)
        case 0x4E:
            LSR(operand: absolute(with: mem), with: mem)
        case 0x5E:
            LSR(operand: absoluteX(with: mem), with: mem)
        case 0x2A:
            ROLForAccumulator(operand: accumulator(), with: mem)
        case 0x26:
            ROL(operand: zeroPage(with: mem), with: mem)
        case 0x36:
            ROL(operand: zeroPageX(with: mem), with: mem)
        case 0x2E:
            ROL(operand: absolute(with: mem), with: mem)
        case 0x3E:
            ROL(operand: absoluteX(with: mem), with: mem)
        case 0x6A:
            RORForAccumulator(operand: accumulator(), with: mem)
        case 0x66:
            ROR(operand: zeroPage(with: mem), with: mem)
        case 0x76:
            ROR(operand: zeroPageX(with: mem), with: mem)
        case 0x6E:
            ROR(operand: absolute(with: mem), with: mem)
        case 0x7E:
            ROR(operand: absoluteX(with: mem), with: mem)

        case 0x4C:
            JMP(operand: absolute(with: mem), with: mem)
        case 0x6C:
            JMP(operand: indirect(with: mem), with: mem)
        case 0x20:
            JSR(operand: absolute(with: mem), with: mem)
        case 0x60:
            RTS(operand: implicit(), with: mem)
        case 0x40:
            RTI(operand: implicit(), with: mem)

        case 0x90:
            BCC(operand: relative(with: mem), with: mem)
        case 0xB0:
            BCS(operand: relative(with: mem), with: mem)
        case 0xF0:
            BEQ(operand: relative(with: mem), with: mem)
        case 0x30:
            BMI(operand: relative(with: mem), with: mem)
        case 0xD0:
            BNE(operand: relative(with: mem), with: mem)
        case 0x10:
            BPL(operand: relative(with: mem), with: mem)
        case 0x50:
            BVC(operand: relative(with: mem), with: mem)
        case 0x70:
            BVS(operand: relative(with: mem), with: mem)

        case 0x18:
            CLC(operand: implicit(), with: mem)
        case 0xD8:
            CLD(operand: implicit(), with: mem)
        case 0x58:
            CLI(operand: implicit(), with: mem)
        case 0xB8:
            CLV(operand: implicit(), with: mem)

        case 0x38:
            SEC(operand: implicit(), with: mem)
        case 0xF8:
            SED(operand: implicit(), with: mem)
        case 0x78:
            SEI(operand: implicit(), with: mem)

        case 0x00:
            BRK(operand: implicit(), with: mem)

        // Undocumented

        case 0xEB:
            SBC(operand: immediate(), with: mem)

        case 0x04, 0x44, 0x64:
            NOP(operand: zeroPage(with: mem), with: mem)
        case 0x0C:
            NOP(operand: absolute(with: mem), with: mem)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            NOP(operand: zeroPageX(with: mem), with: mem)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            NOP(operand: implicit(), with: mem)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            NOP(operand: absoluteXWithPenalty(with: mem), with: mem)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            NOP(operand: immediate(), with: mem)

        case 0xA3:
            LAX(operand: indexedIndirect(with: mem), with: mem)
        case 0xA7:
            LAX(operand: zeroPage(with: mem), with: mem)
        case 0xAF:
            LAX(operand: absolute(with: mem), with: mem)
        case 0xB3:
            LAX(operand: indirectIndexed(with: mem), with: mem)
        case 0xB7:
            LAX(operand: zeroPageY(with: mem), with: mem)
        case 0xBF:
            LAX(operand: absoluteYWithPenalty(with: mem), with: mem)

        case 0x83:
            SAX(operand: indexedIndirect(with: mem), with: mem)
        case 0x87:
            SAX(operand: zeroPage(with: mem), with: mem)
        case 0x8F:
            SAX(operand: absolute(with: mem), with: mem)
        case 0x97:
            SAX(operand: zeroPageY(with: mem), with: mem)

        case 0xC3:
            DCP(operand: indexedIndirect(with: mem), with: mem)
        case 0xC7:
            DCP(operand: zeroPage(with: mem), with: mem)
        case 0xCF:
            DCP(operand: absolute(with: mem), with: mem)
        case 0xD3:
            DCP(operand: indirectIndexed(with: mem), with: mem)
        case 0xD7:
            DCP(operand: zeroPageX(with: mem), with: mem)
        case 0xDB:
            DCP(operand: absoluteY(with: mem), with: mem)
        case 0xDF:
            DCP(operand: absoluteX(with: mem), with: mem)

        case 0xE3:
            ISB(operand: indexedIndirect(with: mem), with: mem)
        case 0xE7:
            ISB(operand: zeroPage(with: mem), with: mem)
        case 0xEF:
            ISB(operand: absolute(with: mem), with: mem)
        case 0xF3:
            ISB(operand: indirectIndexed(with: mem), with: mem)
        case 0xF7:
            ISB(operand: zeroPageX(with: mem), with: mem)
        case 0xFB:
            ISB(operand: absoluteY(with: mem), with: mem)
        case 0xFF:
            ISB(operand: absoluteX(with: mem), with: mem)

        case 0x03:
            SLO(operand: indexedIndirect(with: mem), with: mem)
        case 0x07:
            SLO(operand: zeroPage(with: mem), with: mem)
        case 0x0F:
            SLO(operand: absolute(with: mem), with: mem)
        case 0x13:
            SLO(operand: indirectIndexed(with: mem), with: mem)
        case 0x17:
            SLO(operand: zeroPageX(with: mem), with: mem)
        case 0x1B:
            SLO(operand: absoluteY(with: mem), with: mem)
        case 0x1F:
            SLO(operand: absoluteX(with: mem), with: mem)

        case 0x23:
            RLA(operand: indexedIndirect(with: mem), with: mem)
        case 0x27:
            RLA(operand: zeroPage(with: mem), with: mem)
        case 0x2F:
            RLA(operand: absolute(with: mem), with: mem)
        case 0x33:
            RLA(operand: indirectIndexed(with: mem), with: mem)
        case 0x37:
            RLA(operand: zeroPageX(with: mem), with: mem)
        case 0x3B:
            RLA(operand: absoluteY(with: mem), with: mem)
        case 0x3F:
            RLA(operand: absoluteX(with: mem), with: mem)

        case 0x43:
            SRE(operand: indexedIndirect(with: mem), with: mem)
        case 0x47:
            SRE(operand: zeroPage(with: mem), with: mem)
        case 0x4F:
            SRE(operand: absolute(with: mem), with: mem)
        case 0x53:
            SRE(operand: indirectIndexed(with: mem), with: mem)
        case 0x57:
            SRE(operand: zeroPageX(with: mem), with: mem)
        case 0x5B:
            SRE(operand: absoluteY(with: mem), with: mem)
        case 0x5F:
            SRE(operand: absoluteX(with: mem), with: mem)

        case 0x63:
            RRA(operand: indexedIndirect(with: mem), with: mem)
        case 0x67:
            RRA(operand: zeroPage(with: mem), with: mem)
        case 0x6F:
            RRA(operand: absolute(with: mem), with: mem)
        case 0x73:
            RRA(operand: indirectIndexed(with: mem), with: mem)
        case 0x77:
            RRA(operand: zeroPageX(with: mem), with: mem)
        case 0x7B:
            RRA(operand: absoluteY(with: mem), with: mem)
        case 0x7F:
            RRA(operand: absoluteX(with: mem), with: mem)

        default:
            NOP(operand: implicit(), with: mem)
        }
    }
}

// MARK: - Operations
extension CPU {
    // Implements for Load/Store Operations

    /// loadAccumulator
    mutating func  LDA<M: Memory>(operand: Operand, with mem: M) {
        A = read(at: operand, with: mem)
    }

    /// loadXRegister
    mutating func  LDX<M: Memory>(operand: Operand, with mem: M) {
        X = read(at: operand, with: mem)
    }

    /// loadYRegister
    mutating func  LDY<M: Memory>(operand: Operand, with mem: M) {
        Y = read(at: operand, with: mem)
    }

    /// storeAccumulator
    mutating func  STA<M: Memory>(operand: Operand, with mem: M) {
        write(A, at: operand, with: mem)
    }

    mutating func  STAWithTick<M: Memory>(operand: Operand, with mem: M) {
        write(A, at: operand, with: mem)
        tick()
    }

    /// storeXRegister
    mutating func  STX<M: Memory>(operand: Operand, with mem: M) {
        write(X, at: operand, with: mem)
    }

    /// storeYRegister
    mutating func  STY<M: Memory>(operand: Operand, with mem: M) {
        write(Y, at: operand, with: mem)
    }

    // MARK: - Register Operations

    /// transferAccumulatorToX
    mutating func  TAX<M: Memory>(operand: Operand, with mem: M) {
        X = A
        tick()
    }

    /// transferStackPointerToX
    mutating func  TSX<M: Memory>(operand: Operand, with mem: M) {
        X = S
        tick()
    }

    /// transferAccumulatorToY
    mutating func  TAY<M: Memory>(operand: Operand, with mem: M) {
        Y = A
        tick()
    }

    /// transferXtoAccumulator
    mutating func  TXA<M: Memory>(operand: Operand, with mem: M) {
        A = X
        tick()
    }

    /// transferXtoStackPointer
    mutating func  TXS<M: Memory>(operand: Operand, with mem: M) {
        S = X
        tick()
    }

    /// transferYtoAccumulator
    mutating func  TYA<M: Memory>(operand: Operand, with mem: M) {
        A = Y
        tick()
    }

    // MARK: - Stack instructions

    /// pushAccumulator
    mutating func  PHA<M: Memory>(operand: Operand, with mem: M) {
        pushStack(A, with: mem)
        tick()
    }

    /// pushProcessorStatus
    mutating func  PHP<M: Memory>(operand: Operand, with mem: M) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | Status.operatedB.rawValue, with: mem)
        tick()
    }

    /// pullAccumulator
    mutating func  PLA<M: Memory>(operand: Operand, with mem: M) {
        A = pullStack(with: mem)
        tick(count: 2)
    }

    /// pullProcessorStatus
    mutating func  PLP<M: Memory>(operand: Operand, with mem: M) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        P = Status(rawValue: pullStack(with: mem) & ~Status.B.rawValue | Status.R.rawValue)
        tick(count: 2)
    }

    // MARK: - Logical instructions

    /// bitwiseANDwithAccumulator
    mutating func  AND<M: Memory>(operand: Operand, with mem: M) {
        A &= read(at: operand, with: mem)
    }

    /// bitwiseExclusiveOR
    mutating func  EOR<M: Memory>(operand: Operand, with mem: M) {
        A ^= read(at: operand, with: mem)
    }

    /// bitwiseORwithAccumulator
    mutating func  ORA<M: Memory>(operand: Operand, with mem: M) {
        A |= read(at: operand, with: mem)
    }

    /// testBits
    mutating func  BIT<M: Memory>(operand: Operand, with mem: M) {
        let value = read(at: operand, with: mem)
        let data = A & value
        P.remove([.Z, .V, .N])
        if data == 0 {
            P.formUnion(.Z)
        } else {
            P.remove(.Z)
        }
        if value[6] == 1 {
            P.formUnion(.V)
        } else {
            P.remove(.V)
        }
        if value[7] == 1 {
            P.formUnion(.N)
        } else {
            P.remove(.N)
        }
    }

    // MARK: - Arithmetic instructions

    /// addWithCarry
    mutating func  ADC<M: Memory>(operand: Operand, with mem: M) {
        let a = A
        let val = read(at: operand, with: mem)
        var result = a &+ val

        if P.contains(.C) {
            result &+= 1
        }

        P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 {
            P.formUnion(.C)
        }
        if c6 ^ c7 == 1 {
            P.formUnion(.V)
        }

        A = result
    }

    /// subtractWithCarry
    mutating func  SBC<M: Memory>(operand: Operand, with mem: M) {
        let a = A
        let val = ~read(at: operand, with: mem)
        var result = a &+ val

        if P.contains(.C) {
            result &+= 1
        }

        P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 {
            P.formUnion(.C)
        }
        if c6 ^ c7 == 1 {
            P.formUnion(.V)
        }

        A = result
    }

    /// compareAccumulator
    mutating func  CMP<M: Memory>(operand: Operand, with mem: M) {
        let cmp = Int16(A) &- Int16(read(at: operand, with: mem))

        P.remove([.C, .Z, .N])
        P.setZN(cmp)
        if 0 <= cmp {
            P.formUnion(.C)
        } else {
            P.remove(.C)
        }

    }

    /// compareXRegister
    mutating func  CPX<M: Memory>(operand: Operand, with mem: M) {
        let value = read(at: operand, with: mem)
        let cmp = X &- value

        P.remove([.C, .Z, .N])
        P.setZN(cmp)
        if X >= value {
            P.formUnion(.C)
        } else {
            P.remove(.C)
        }

    }

    /// compareYRegister
    mutating func  CPY<M: Memory>(operand: Operand, with mem: M) {
        let value = read(at: operand, with: mem)
        let cmp = Y &- value

        P.remove([.C, .Z, .N])
        P.setZN(cmp)
        if Y >= value {
            P.formUnion(.C)
        } else {
            P.remove(.C)
        }

    }

    // MARK: - Increment/Decrement instructions

    /// incrementMemory
    mutating func  INC<M: Memory>(operand: Operand, with mem: M) {
        let result = read(at: operand, with: mem) &+ 1

        P.setZN(result)
        write(result, at: operand, with: mem)

        tick()

    }

    /// incrementX
    mutating func  INX<M: Memory>(operand: Operand, with mem: M) {
        X = X &+ 1
        tick()
    }

    /// incrementY
    mutating func  INY<M: Memory>(operand: Operand, with mem: M) {
        Y = Y &+ 1
        tick()
    }

    /// decrementMemory
    mutating func  DEC<M: Memory>(operand: Operand, with mem: M) {
        let result = read(at: operand, with: mem) &- 1
        P.setZN(result)

        write(result, at: operand, with: mem)
        tick()
    }

    /// decrementX
    mutating func  DEX<M: Memory>(operand: Operand, with mem: M) {
        X = X &- 1
        tick()
    }

    /// decrementY
    mutating func  DEY<M: Memory>(operand: Operand, with mem: M) {
        Y = Y &- 1
        tick()
    }

    // MARK: - Shift instructions

    /// arithmeticShiftLeft
    mutating func  ASL<M: Memory>(operand: Operand, with mem: M) {
        var data = read(at: operand, with: mem)

        P.remove([.C, .Z, .N])
        if data[7] == 1 {
            P.formUnion(.C)
        }

        data <<= 1

        P.setZN(data)

        write(data, at: operand, with: mem)

        tick()
    }

    mutating func  ASLForAccumulator<M: Memory>(operand: Operand, with mem: M) {
        P.remove([.C, .Z, .N])
        if A[7] == 1 {
            P.formUnion(.C)
        }

        A <<= 1

        tick()
    }

    /// logicalShiftRight
    mutating func  LSR<M: Memory>(operand: Operand, with mem: M) {
        var data = read(at: operand, with: mem)

        P.remove([.C, .Z, .N])
        if data[0] == 1 {
            P.formUnion(.C)
        }

        data >>= 1

        P.setZN(data)

        write(data, at: operand, with: mem)

        tick()
    }

    mutating func  LSRForAccumulator<M: Memory>(operand: Operand, with mem: M) {
        P.remove([.C, .Z, .N])
        if A[0] == 1 {
            P.formUnion(.C)
        }

        A >>= 1

        tick()
    }

    /// rotateLeft
    mutating func  ROL<M: Memory>(operand: Operand, with mem: M) {
        var data = read(at: operand, with: mem)
        let c = data & 0x80

        data <<= 1
        if P.contains(.C) {
            data |= 0x01
        }

        P.remove([.C, .Z, .N])
        if c == 0x80 {
            P.formUnion(.C)
        }

        P.setZN(data)

        write(data, at: operand, with: mem)

        tick()
    }

    mutating func  ROLForAccumulator<M: Memory>(operand: Operand, with mem: M) {
        let c = A & 0x80

        var a = A << 1
        if P.contains(.C) {
            a |= 0x01
        }

        P.remove([.C, .Z, .N])
        if c == 0x80 {
            P.formUnion(.C)
        }

        A = a

        tick()
    }

    /// rotateRight
    mutating func  ROR<M: Memory>(operand: Operand, with mem: M) {
        var data = read(at: operand, with: mem)
        let c = data & 0x01

        data >>= 1
        if P.contains(.C) {
            data |= 0x80
        }

        P.remove([.C, .Z, .N])
        if c == 1 {
            P.formUnion(.C)
        }

        P.setZN(data)

        write(data, at: operand, with: mem)

        tick()
    }

    mutating func  RORForAccumulator<M: Memory>(operand: Operand, with mem: M) {
        let c = A & 0x01

        var a = A >> 1
        if P.contains(.C) {
            a |= 0x80
        }

        P.remove([.C, .Z, .N])
        if c == 1 {
            P.formUnion(.C)
        }

        A = a

        tick()
    }

    // MARK: - Jump instructions

    /// jump
    mutating func  JMP<M: Memory>(operand: Operand, with mem: M) {
        PC = operand
    }

    /// jumpToSubroutine
    mutating func  JSR<M: Memory>(operand: Operand, with mem: M) {
        pushStack(word: PC &- 1, with: mem)
        tick()
        PC = operand
    }

    /// returnFromSubroutine
    mutating func  RTS<M: Memory>(operand: Operand, with mem: M) {
        tick(count: 3)
        PC = pullStack(with: mem) &+ 1
    }

    /// returnFromInterrupt
    mutating func  RTI<M: Memory>(operand: Operand, with mem: M) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        tick(count: 2)
        P = Status(rawValue: pullStack(with: mem) & ~Status.B.rawValue | Status.R.rawValue)
        PC = pullStack(with: mem)
    }

    // MARK: - Branch instructions

    private mutating func  branch<M: Memory>(operand: Operand, test: Bool, with mem: M) {
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
    mutating func  BCC<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: !P.contains(.C), with: mem)
    }

    /// branchIfCarrySet
    mutating func  BCS<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: P.contains(.C), with: mem)
    }

    /// branchIfEqual
    mutating func  BEQ<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: P.contains(.Z), with: mem)
    }

    /// branchIfMinus
    mutating func  BMI<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: P.contains(.N), with: mem)
    }

    /// branchIfNotEqual
    mutating func  BNE<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: !P.contains(.Z), with: mem)
    }

    /// branchIfPlus
    mutating func  BPL<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: !P.contains(.N), with: mem)
    }

    /// branchIfOverflowClear
    mutating func  BVC<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: !P.contains(.V), with: mem)
    }

    /// branchIfOverflowSet
    mutating func  BVS<M: Memory>(operand: Operand, with mem: M) {
        branch(operand: operand, test: P.contains(.V), with: mem)
    }

    // MARK: - Flag control instructions

    /// clearCarry
    mutating func  CLC<M: Memory>(operand: Operand, with mem: M) {
        P.remove(.C)
        tick()
    }

    /// clearDecimal
    mutating func  CLD<M: Memory>(operand: Operand, with mem: M) {
        P.remove(.D)
        tick()
    }

    /// clearInterrupt
    mutating func  CLI<M: Memory>(operand: Operand, with mem: M) {
        P.remove(.I)
        tick()
    }

    /// clearOverflow
    mutating func  CLV<M: Memory>(operand: Operand, with mem: M) {
        P.remove(.V)
        tick()
    }

    /// setCarryFlag
    mutating func  SEC<M: Memory>(operand: Operand, with mem: M) {
        P.formUnion(.C)
        tick()
    }

    /// setDecimalFlag
    mutating func  SED<M: Memory>(operand: Operand, with mem: M) {
        P.formUnion(.D)
        tick()
    }

    /// setInterruptDisable
    mutating func  SEI<M: Memory>(operand: Operand, with mem: M) {
        P.formUnion(.I)
        tick()
    }

    // MARK: - Misc

    /// forceInterrupt
    mutating func  BRK<M: Memory>(operand: Operand, with mem: M) {
        pushStack(word: PC, with: mem)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | Status.interruptedB.rawValue, with: mem)
        tick()
        PC = readWord(at: 0xFFFE, with: mem)
    }

    /// doNothing
    mutating func  NOP<M: Memory>(operand: Operand, with mem: M) {
        tick()
    }

    // MARK: - Unofficial

    /// loadAccumulatorAndX
    mutating func  LAX<M: Memory>(operand: Operand, with mem: M) {
        let data = read(at: operand, with: mem)
        A = data
        X = data
    }

    /// storeAccumulatorAndX
    mutating func  SAX<M: Memory>(operand: Operand, with mem: M) {
        write(A & X, at: operand, with: mem)
    }

    /// decrementMemoryAndCompareAccumulator
    mutating func  DCP<M: Memory>(operand: Operand, with mem: M) {
        // decrementMemory excluding tick
        let result = read(at: operand, with: mem) &- 1
        P.setZN(result)
        write(result, at: operand, with: mem)

        CMP(operand: operand, with: mem)
    }

    /// incrementMemoryAndSubtractWithCarry
    mutating func  ISB<M: Memory>(operand: Operand, with mem: M) {
        // incrementMemory excluding tick
        let result = read(at: operand, with: mem) &+ 1
        P.setZN(result)
        write(result, at: operand, with: mem)

        SBC(operand: operand, with: mem)
    }

    /// arithmeticShiftLeftAndBitwiseORwithAccumulator
    mutating func  SLO<M: Memory>(operand: Operand, with mem: M) {
        // arithmeticShiftLeft excluding tick
        var data = read(at: operand, with: mem)
        P.remove([.C, .Z, .N])
        if data[7] == 1 {
            P.formUnion(.C)
        }

        data <<= 1
        P.setZN(data)
        write(data, at: operand, with: mem)

        ORA(operand: operand, with: mem)
    }

    /// rotateLeftAndBitwiseANDwithAccumulator
    mutating func  RLA<M: Memory>(operand: Operand, with mem: M) {
        // rotateLeft excluding tick
        var data = read(at: operand, with: mem)
        let c = data & 0x80

        data <<= 1
        if P.contains(.C) {
            data |= 0x01
        }

        P.remove([.C, .Z, .N])
        if c == 0x80 {
            P.formUnion(.C)
        }

        P.setZN(data)
        write(data, at: operand, with: mem)

        AND(operand: operand, with: mem)
    }

    /// logicalShiftRightAndBitwiseExclusiveOR
    mutating func  SRE<M: Memory>(operand: Operand, with mem: M) {
        // logicalShiftRight excluding tick
        var data = read(at: operand, with: mem)
        P.remove([.C, .Z, .N])
        if data[0] == 1 {
            P.formUnion(.C)
        }

        data >>= 1

        P.setZN(data)
        write(data, at: operand, with: mem)

        EOR(operand: operand, with: mem)
    }

    /// rotateRightAndAddWithCarry
    mutating func  RRA<M: Memory>(operand: Operand, with mem: M) {
        // rotateRight excluding tick
        var data = read(at: operand, with: mem)
        let c = data & 0x01

        data >>= 1
        if P.contains(.C) {
            data |= 0x80
        }

        P.remove([.C, .Z, .N])
        if c == 1 {
            P.formUnion(.C)
        }

        P.setZN(data)
        write(data, at: operand, with: mem)

        ADC(operand: operand, with: mem)
    }
}
