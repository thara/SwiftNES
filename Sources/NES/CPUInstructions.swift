typealias OpCode = UInt8
typealias Operand = UInt16

private typealias Status = CPUStatus

// MARK: Addressing mode
extension Emulator {

    @inline(__always)
    mutating func implicit() -> UInt16 {
        return 0x00
    }

    @inline(__always)
    mutating func accumulator() -> UInt16 {
        return nes.cpu.A.u16
    }

    @inline(__always)
    mutating func immediate() -> UInt16 {
        let operand = nes.cpu.PC
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPage() -> UInt16 {
        let operand = M.cpuRead(at: nes.cpu.PC, from: &nes).u16 & 0xFF
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageX() -> UInt16 {
        tick()

        let operand = (M.cpuRead(at: nes.cpu.PC, from: &nes).u16 &+ nes.cpu.X.u16) & 0xFF
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageY() -> UInt16 {
        tick()

        let operand = (M.cpuRead(at: nes.cpu.PC, from: &nes).u16 &+ nes.cpu.Y.u16) & 0xFF
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func absolute() -> UInt16 {
        let operand = M.cpuReadWord(at: nes.cpu.PC, from: &nes)
        nes.cpu.PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func absoluteX() -> UInt16 {
        let data = M.cpuReadWord(at: nes.cpu.PC, from: &nes)
        let operand = data &+ nes.cpu.X.u16 & 0xFFFF
        nes.cpu.PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteXWithPenalty() -> UInt16 {
        let data = M.cpuReadWord(at: nes.cpu.PC, from: &nes)
        let operand = data &+ nes.cpu.X.u16 & 0xFFFF
        nes.cpu.PC &+= 2

        if pageCrossed(value: data, operand: nes.cpu.X) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func absoluteY() -> UInt16 {
        let data = M.cpuReadWord(at: nes.cpu.PC, from: &nes)
        let operand = data &+ nes.cpu.Y.u16 & 0xFFFF
        nes.cpu.PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteYWithPenalty() -> UInt16 {
        let data = M.cpuReadWord(at: nes.cpu.PC, from: &nes)
        let operand = data &+ nes.cpu.Y.u16 & 0xFFFF
        nes.cpu.PC &+= 2

        if pageCrossed(value: data, operand: nes.cpu.Y) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func relative() -> UInt16 {
        let operand = M.cpuRead(at: nes.cpu.PC, from: &nes).u16
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func indirect() -> UInt16 {
        let data = M.cpuReadWord(at: nes.cpu.PC, from: &nes)
        let operand = readOnIndirect(operand: data)
        nes.cpu.PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func indexedIndirect() -> UInt16 {
        let data = M.cpuRead(at: nes.cpu.PC, from: &nes)
        let operand = readOnIndirect(operand: (data &+ nes.cpu.X).u16 & 0xFF)
        nes.cpu.PC &+= 1

        tick()

        return operand
    }

    @inline(__always)
    mutating func indirectIndexed() -> UInt16 {
        let data = M.cpuRead(at: nes.cpu.PC, from: &nes).u16
        let operand = readOnIndirect(operand: data) &+ nes.cpu.Y.u16
        nes.cpu.PC &+= 1

        if pageCrossed(value: operand &- nes.cpu.Y.u16, operand: nes.cpu.Y) {
            tick()
        }
        return operand
    }

    mutating func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = M.cpuRead(at: operand, from: &nes).u16
        let high = M.cpuRead(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF), from: &nes).u16 &<< 8  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}

private func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
    return pageCrossed(value: value, operand: operand.u16)
}

private func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

private func pageCrossed(value: Int, operand: Int) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

//MARK: Instructions
extension Emulator {

    mutating func fetchOperand() -> OpCode {
        let opcode = M.cpuRead(at: nes.cpu.PC, from: &nes)
        nes.cpu.PC &+= 1
        return opcode
    }

    mutating func excuteInstruction(opcode: OpCode) {
        switch opcode {
        case 0xA9:
            LDA(operand: immediate())
        case 0xA5:
            LDA(operand: zeroPage())
        case 0xB5:
            LDA(operand: zeroPageX())
        case 0xAD:
            LDA(operand: absolute())
        case 0xBD:
            LDA(operand: absoluteXWithPenalty())
        case 0xB9:
            LDA(operand: absoluteYWithPenalty())
        case 0xA1:
            LDA(operand: indexedIndirect())
        case 0xB1:
            LDA(operand: indirectIndexed())
        case 0xA2:
            LDX(operand: immediate())
        case 0xA6:
            LDX(operand: zeroPage())
        case 0xB6:
            LDX(operand: zeroPageY())
        case 0xAE:
            LDX(operand: absolute())
        case 0xBE:
            LDX(operand: absoluteYWithPenalty())
        case 0xA0:
            LDY(operand: immediate())
        case 0xA4:
            LDY(operand: zeroPage())
        case 0xB4:
            LDY(operand: zeroPageX())
        case 0xAC:
            LDY(operand: absolute())
        case 0xBC:
            LDY(operand: absoluteXWithPenalty())
        case 0x85:
            STA(operand: zeroPage())
        case 0x95:
            STA(operand: zeroPageX())
        case 0x8D:
            STA(operand: absolute())
        case 0x9D:
            STA(operand: absoluteX())
        case 0x99:
            STA(operand: absoluteY())
        case 0x81:
            STA(operand: indexedIndirect())
        case 0x91:
            STAWithTick(operand: indirectIndexed())
        case 0x86:
            STX(operand: zeroPage())
        case 0x96:
            STX(operand: zeroPageY())
        case 0x8E:
            STX(operand: absolute())
        case 0x84:
            STY(operand: zeroPage())
        case 0x94:
            STY(operand: zeroPageX())
        case 0x8C:
            STY(operand: absolute())
        case 0xAA:
            TAX(operand: implicit())
        case 0xBA:
            TSX(operand: implicit())
        case 0xA8:
            TAY(operand: implicit())
        case 0x8A:
            TXA(operand: implicit())
        case 0x9A:
            TXS(operand: implicit())
        case 0x98:
            TYA(operand: implicit())

        case 0x48:
            PHA(operand: implicit())
        case 0x08:
            PHP(operand: implicit())
        case 0x68:
            PLA(operand: implicit())
        case 0x28:
            PLP(operand: implicit())

        case 0x29:
            AND(operand: immediate())
        case 0x25:
            AND(operand: zeroPage())
        case 0x35:
            AND(operand: zeroPageX())
        case 0x2D:
            AND(operand: absolute())
        case 0x3D:
            AND(operand: absoluteXWithPenalty())
        case 0x39:
            AND(operand: absoluteYWithPenalty())
        case 0x21:
            AND(operand: indexedIndirect())
        case 0x31:
            AND(operand: indirectIndexed())
        case 0x49:
            EOR(operand: immediate())
        case 0x45:
            EOR(operand: zeroPage())
        case 0x55:
            EOR(operand: zeroPageX())
        case 0x4D:
            EOR(operand: absolute())
        case 0x5D:
            EOR(operand: absoluteXWithPenalty())
        case 0x59:
            EOR(operand: absoluteYWithPenalty())
        case 0x41:
            EOR(operand: indexedIndirect())
        case 0x51:
            EOR(operand: indirectIndexed())
        case 0x09:
            ORA(operand: immediate())
        case 0x05:
            ORA(operand: zeroPage())
        case 0x15:
            ORA(operand: zeroPageX())
        case 0x0D:
            ORA(operand: absolute())
        case 0x1D:
            ORA(operand: absoluteXWithPenalty())
        case 0x19:
            ORA(operand: absoluteYWithPenalty())
        case 0x01:
            ORA(operand: indexedIndirect())
        case 0x11:
            ORA(operand: indirectIndexed())
        case 0x24:
            BIT(operand: zeroPage())
        case 0x2C:
            BIT(operand: absolute())

        case 0x69:
            ADC(operand: immediate())
        case 0x65:
            ADC(operand: zeroPage())
        case 0x75:
            ADC(operand: zeroPageX())
        case 0x6D:
            ADC(operand: absolute())
        case 0x7D:
            ADC(operand: absoluteXWithPenalty())
        case 0x79:
            ADC(operand: absoluteYWithPenalty())
        case 0x61:
            ADC(operand: indexedIndirect())
        case 0x71:
            ADC(operand: indirectIndexed())
        case 0xE9:
            SBC(operand: immediate())
        case 0xE5:
            SBC(operand: zeroPage())
        case 0xF5:
            SBC(operand: zeroPageX())
        case 0xED:
            SBC(operand: absolute())
        case 0xFD:
            SBC(operand: absoluteXWithPenalty())
        case 0xF9:
            SBC(operand: absoluteYWithPenalty())
        case 0xE1:
            SBC(operand: indexedIndirect())
        case 0xF1:
            SBC(operand: indirectIndexed())
        case 0xC9:
            CMP(operand: immediate())
        case 0xC5:
            CMP(operand: zeroPage())
        case 0xD5:
            CMP(operand: zeroPageX())
        case 0xCD:
            CMP(operand: absolute())
        case 0xDD:
            CMP(operand: absoluteXWithPenalty())
        case 0xD9:
            CMP(operand: absoluteYWithPenalty())
        case 0xC1:
            CMP(operand: indexedIndirect())
        case 0xD1:
            CMP(operand: indirectIndexed())
        case 0xE0:
            CPX(operand: immediate())
        case 0xE4:
            CPX(operand: zeroPage())
        case 0xEC:
            CPX(operand: absolute())
        case 0xC0:
            CPY(operand: immediate())
        case 0xC4:
            CPY(operand: zeroPage())
        case 0xCC:
            CPY(operand: absolute())

        case 0xE6:
            INC(operand: zeroPage())
        case 0xF6:
            INC(operand: zeroPageX())
        case 0xEE:
            INC(operand: absolute())
        case 0xFE:
            INC(operand: absoluteX())
        case 0xE8:
            INX(operand: implicit())
        case 0xC8:
            INY(operand: implicit())
        case 0xC6:
            DEC(operand: zeroPage())
        case 0xD6:
            DEC(operand: zeroPageX())
        case 0xCE:
            DEC(operand: absolute())
        case 0xDE:
            DEC(operand: absoluteX())
        case 0xCA:
            DEX(operand: implicit())
        case 0x88:
            DEY(operand: implicit())

        case 0x0A:
            ASLForAccumulator(operand: accumulator())
        case 0x06:
            ASL(operand: zeroPage())
        case 0x16:
            ASL(operand: zeroPageX())
        case 0x0E:
            ASL(operand: absolute())
        case 0x1E:
            ASL(operand: absoluteX())
        case 0x4A:
            LSRForAccumulator(operand: accumulator())
        case 0x46:
            LSR(operand: zeroPage())
        case 0x56:
            LSR(operand: zeroPageX())
        case 0x4E:
            LSR(operand: absolute())
        case 0x5E:
            LSR(operand: absoluteX())
        case 0x2A:
            ROLForAccumulator(operand: accumulator())
        case 0x26:
            ROL(operand: zeroPage())
        case 0x36:
            ROL(operand: zeroPageX())
        case 0x2E:
            ROL(operand: absolute())
        case 0x3E:
            ROL(operand: absoluteX())
        case 0x6A:
            RORForAccumulator(operand: accumulator())
        case 0x66:
            ROR(operand: zeroPage())
        case 0x76:
            ROR(operand: zeroPageX())
        case 0x6E:
            ROR(operand: absolute())
        case 0x7E:
            ROR(operand: absoluteX())

        case 0x4C:
            JMP(operand: absolute())
        case 0x6C:
            JMP(operand: indirect())
        case 0x20:
            JSR(operand: absolute())
        case 0x60:
            RTS(operand: implicit())
        case 0x40:
            RTI(operand: implicit())

        case 0x90:
            BCC(operand: relative())
        case 0xB0:
            BCS(operand: relative())
        case 0xF0:
            BEQ(operand: relative())
        case 0x30:
            BMI(operand: relative())
        case 0xD0:
            BNE(operand: relative())
        case 0x10:
            BPL(operand: relative())
        case 0x50:
            BVC(operand: relative())
        case 0x70:
            BVS(operand: relative())

        case 0x18:
            CLC(operand: implicit())
        case 0xD8:
            CLD(operand: implicit())
        case 0x58:
            CLI(operand: implicit())
        case 0xB8:
            CLV(operand: implicit())

        case 0x38:
            SEC(operand: implicit())
        case 0xF8:
            SED(operand: implicit())
        case 0x78:
            SEI(operand: implicit())

        case 0x00:
            BRK(operand: implicit())

        // Undocumented

        case 0xEB:
            SBC(operand: immediate())

        case 0x04, 0x44, 0x64:
            NOP(operand: zeroPage())
        case 0x0C:
            NOP(operand: absolute())
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            NOP(operand: zeroPageX())
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            NOP(operand: implicit())
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            NOP(operand: absoluteXWithPenalty())
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            NOP(operand: immediate())

        case 0xA3:
            LAX(operand: indexedIndirect())
        case 0xA7:
            LAX(operand: zeroPage())
        case 0xAF:
            LAX(operand: absolute())
        case 0xB3:
            LAX(operand: indirectIndexed())
        case 0xB7:
            LAX(operand: zeroPageY())
        case 0xBF:
            LAX(operand: absoluteYWithPenalty())

        case 0x83:
            SAX(operand: indexedIndirect())
        case 0x87:
            SAX(operand: zeroPage())
        case 0x8F:
            SAX(operand: absolute())
        case 0x97:
            SAX(operand: zeroPageY())

        case 0xC3:
            DCP(operand: indexedIndirect())
        case 0xC7:
            DCP(operand: zeroPage())
        case 0xCF:
            DCP(operand: absolute())
        case 0xD3:
            DCP(operand: indirectIndexed())
        case 0xD7:
            DCP(operand: zeroPageX())
        case 0xDB:
            DCP(operand: absoluteY())
        case 0xDF:
            DCP(operand: absoluteX())

        case 0xE3:
            ISB(operand: indexedIndirect())
        case 0xE7:
            ISB(operand: zeroPage())
        case 0xEF:
            ISB(operand: absolute())
        case 0xF3:
            ISB(operand: indirectIndexed())
        case 0xF7:
            ISB(operand: zeroPageX())
        case 0xFB:
            ISB(operand: absoluteY())
        case 0xFF:
            ISB(operand: absoluteX())

        case 0x03:
            SLO(operand: indexedIndirect())
        case 0x07:
            SLO(operand: zeroPage())
        case 0x0F:
            SLO(operand: absolute())
        case 0x13:
            SLO(operand: indirectIndexed())
        case 0x17:
            SLO(operand: zeroPageX())
        case 0x1B:
            SLO(operand: absoluteY())
        case 0x1F:
            SLO(operand: absoluteX())

        case 0x23:
            RLA(operand: indexedIndirect())
        case 0x27:
            RLA(operand: zeroPage())
        case 0x2F:
            RLA(operand: absolute())
        case 0x33:
            RLA(operand: indirectIndexed())
        case 0x37:
            RLA(operand: zeroPageX())
        case 0x3B:
            RLA(operand: absoluteY())
        case 0x3F:
            RLA(operand: absoluteX())

        case 0x43:
            SRE(operand: indexedIndirect())
        case 0x47:
            SRE(operand: zeroPage())
        case 0x4F:
            SRE(operand: absolute())
        case 0x53:
            SRE(operand: indirectIndexed())
        case 0x57:
            SRE(operand: zeroPageX())
        case 0x5B:
            SRE(operand: absoluteY())
        case 0x5F:
            SRE(operand: absoluteX())

        case 0x63:
            RRA(operand: indexedIndirect())
        case 0x67:
            RRA(operand: zeroPage())
        case 0x6F:
            RRA(operand: absolute())
        case 0x73:
            RRA(operand: indirectIndexed())
        case 0x77:
            RRA(operand: zeroPageX())
        case 0x7B:
            RRA(operand: absoluteY())
        case 0x7F:
            RRA(operand: absoluteX())

        default:
            NOP(operand: implicit())
        }
    }
}

extension Emulator {

    // MARK: - Operations

    // Implements for Load/Store Operations

    /// loadAccumulator
    mutating func LDA(operand: Operand) {
        nes.cpu.A = M.cpuRead(at: operand, from: &nes)
    }

    /// loadXRegister
    mutating func LDX(operand: Operand) {
        nes.cpu.X = M.cpuRead(at: operand, from: &nes)
    }

    /// loadYRegister
    mutating func LDY(operand: Operand) {
        nes.cpu.Y = M.cpuRead(at: operand, from: &nes)
    }

    /// storeAccumulator
    mutating func STA(operand: Operand) {
        M.cpuWrite(nes.cpu.A, at: operand, to: &nes)
    }

    mutating func STAWithTick(operand: Operand) {
        M.cpuWrite(nes.cpu.A, at: operand, to: &nes)
        tick()
    }

    /// storeXRegister
    mutating func STX(operand: Operand) {
        M.cpuWrite(nes.cpu.X, at: operand, to: &nes)
    }

    /// storeYRegister
    mutating func STY(operand: Operand) {
        M.cpuWrite(nes.cpu.Y, at: operand, to: &nes)
    }

    // MARK: - Register Operations

    /// transferAccumulatorToX
    mutating func TAX(operand: Operand) {
        nes.cpu.X = nes.cpu.A
        tick()
    }

    /// transferStackPointerToX
    mutating func TSX(operand: Operand) {
        nes.cpu.X = nes.cpu.S
        tick()
    }

    /// transferAccumulatorToY
    mutating func TAY(operand: Operand) {
        nes.cpu.Y = nes.cpu.A
        tick()
    }

    /// transferXtoAccumulator
    mutating func TXA(operand: Operand) {
        nes.cpu.A = nes.cpu.X
        tick()
    }

    /// transferXtoStackPointer
    mutating func TXS(operand: Operand) {
        nes.cpu.S = nes.cpu.X
        tick()
    }

    /// transferYtoAccumulator
    mutating func TYA(operand: Operand) {
        nes.cpu.A = nes.cpu.Y
        tick()
    }

    // MARK: - Stack instructions

    /// pushAccumulator
    mutating func PHA(operand: Operand) {
        pushStack(nes.cpu.A)
        tick()
    }

    /// pushProcessorStatus
    mutating func PHP(operand: Operand) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | Status.operatedB.rawValue)
        tick()
    }

    /// pullAccumulator
    mutating func PLA(operand: Operand) {
        nes.cpu.A = pullStack()
        tick(count: 2)
    }

    /// pullProcessorStatus
    mutating func PLP(operand: Operand) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        nes.cpu.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        tick(count: 2)
    }

    // MARK: - Logical instructions

    /// bitwiseANDwithAccumulator
    mutating func AND(operand: Operand) {
        nes.cpu.A &= M.cpuRead(at: operand, from: &nes)
    }

    /// bitwiseExclusiveOR
    mutating func EOR(operand: Operand) {
        nes.cpu.A ^= M.cpuRead(at: operand, from: &nes)
    }

    /// bitwiseORwithAccumulator
    mutating func ORA(operand: Operand) {
        nes.cpu.A |= M.cpuRead(at: operand, from: &nes)
    }

    /// testBits
    mutating func BIT(operand: Operand) {
        let value = M.cpuRead(at: operand, from: &nes)
        let data = nes.cpu.A & value
        nes.cpu.P.remove([.Z, .V, .N])
        if data == 0 {
            nes.cpu.P.formUnion(.Z)
        } else {
            nes.cpu.P.remove(.Z)
        }
        if value[6] == 1 {
            nes.cpu.P.formUnion(.V)
        } else {
            nes.cpu.P.remove(.V)
        }
        if value[7] == 1 {
            nes.cpu.P.formUnion(.N)
        } else {
            nes.cpu.P.remove(.N)
        }
    }

    // MARK: - Arithmetic instructions

    /// addWithCarry
    mutating func ADC(operand: Operand) {
        let a = nes.cpu.A
        let val = M.cpuRead(at: operand, from: &nes)
        var result = a &+ val

        if nes.cpu.P.contains(.C) {
            result &+= 1
        }

        nes.cpu.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 {
            nes.cpu.P.formUnion(.C)
        }
        if c6 ^ c7 == 1 {
            nes.cpu.P.formUnion(.V)
        }

        nes.cpu.A = result
    }

    /// subtractWithCarry
    mutating func SBC(operand: Operand) {
        let a = nes.cpu.A
        let val = ~M.cpuRead(at: operand, from: &nes)
        var result = a &+ val

        if nes.cpu.P.contains(.C) {
            result &+= 1
        }

        nes.cpu.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 {
            nes.cpu.P.formUnion(.C)
        }
        if c6 ^ c7 == 1 {
            nes.cpu.P.formUnion(.V)
        }

        nes.cpu.A = result
    }

    /// compareAccumulator
    mutating func CMP(operand: Operand) {
        let cmp = Int16(nes.cpu.A) &- Int16(M.cpuRead(at: operand, from: &nes))

        nes.cpu.P.remove([.C, .Z, .N])
        nes.cpu.P.setZN(cmp)
        if 0 <= cmp {
            nes.cpu.P.formUnion(.C)
        } else {
            nes.cpu.P.remove(.C)
        }

    }

    /// compareXRegister
    mutating func CPX(operand: Operand) {
        let value = M.cpuRead(at: operand, from: &nes)
        let cmp = nes.cpu.X &- value

        nes.cpu.P.remove([.C, .Z, .N])
        nes.cpu.P.setZN(cmp)
        if nes.cpu.X >= value {
            nes.cpu.P.formUnion(.C)
        } else {
            nes.cpu.P.remove(.C)
        }

    }

    /// compareYRegister
    mutating func CPY(operand: Operand) {
        let value = M.cpuRead(at: operand, from: &nes)
        let cmp = nes.cpu.Y &- value

        nes.cpu.P.remove([.C, .Z, .N])
        nes.cpu.P.setZN(cmp)
        if nes.cpu.Y >= value {
            nes.cpu.P.formUnion(.C)
        } else {
            nes.cpu.P.remove(.C)
        }

    }

    // MARK: - Increment/Decrement instructions

    /// incrementMemory
    mutating func INC(operand: Operand) {
        let result = M.cpuRead(at: operand, from: &nes) &+ 1

        nes.cpu.P.setZN(result)
        M.cpuWrite(result, at: operand, to: &nes)

        tick()

    }

    /// incrementX
    mutating func INX(operand: Operand) {
        nes.cpu.X = nes.cpu.X &+ 1
        tick()
    }

    /// incrementY
    mutating func INY(operand: Operand) {
        nes.cpu.Y = nes.cpu.Y &+ 1
        tick()
    }

    /// decrementMemory
    mutating func DEC(operand: Operand) {
        let result = M.cpuRead(at: operand, from: &nes) &- 1
        nes.cpu.P.setZN(result)

        M.cpuWrite(result, at: operand, to: &nes)
        tick()
    }

    /// decrementX
    mutating func DEX(operand: Operand) {
        nes.cpu.X = nes.cpu.X &- 1
        tick()
    }

    /// decrementY
    mutating func DEY(operand: Operand) {
        nes.cpu.Y = nes.cpu.Y &- 1
        tick()
    }

    // MARK: - Shift instructions

    /// arithmeticShiftLeft
    mutating func ASL(operand: Operand) {
        var data = M.cpuRead(at: operand, from: &nes)

        nes.cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 {
            nes.cpu.P.formUnion(.C)
        }

        data <<= 1

        nes.cpu.P.setZN(data)

        M.cpuWrite(data, at: operand, to: &nes)

        tick()
    }

    mutating func ASLForAccumulator(operand: Operand) {
        nes.cpu.P.remove([.C, .Z, .N])
        if nes.cpu.A[7] == 1 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.A <<= 1

        tick()
    }

    /// logicalShiftRight
    mutating func LSR(operand: Operand) {
        var data = M.cpuRead(at: operand, from: &nes)

        nes.cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 {
            nes.cpu.P.formUnion(.C)
        }

        data >>= 1

        nes.cpu.P.setZN(data)

        M.cpuWrite(data, at: operand, to: &nes)

        tick()
    }

    mutating func LSRForAccumulator(operand: Operand) {
        nes.cpu.P.remove([.C, .Z, .N])
        if nes.cpu.A[0] == 1 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.A >>= 1

        tick()
    }

    /// rotateLeft
    mutating func ROL(operand: Operand) {
        var data = M.cpuRead(at: operand, from: &nes)
        let c = data & 0x80

        data <<= 1
        if nes.cpu.P.contains(.C) {
            data |= 0x01
        }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 0x80 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.P.setZN(data)

        M.cpuWrite(data, at: operand, to: &nes)

        tick()
    }

    mutating func ROLForAccumulator(operand: Operand) {
        let c = nes.cpu.A & 0x80

        var a = nes.cpu.A << 1
        if nes.cpu.P.contains(.C) {
            a |= 0x01
        }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 0x80 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.A = a

        tick()
    }

    /// rotateRight
    mutating func ROR(operand: Operand) {
        var data = M.cpuRead(at: operand, from: &nes)
        let c = data & 0x01

        data >>= 1
        if nes.cpu.P.contains(.C) {
            data |= 0x80
        }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 1 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.P.setZN(data)

        M.cpuWrite(data, at: operand, to: &nes)

        tick()
    }

    mutating func RORForAccumulator(operand: Operand) {
        let c = nes.cpu.A & 0x01

        var a = nes.cpu.A >> 1
        if nes.cpu.P.contains(.C) {
            a |= 0x80
        }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 1 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.A = a

        tick()
    }

    // MARK: - Jump instructions

    /// jump
    mutating func JMP(operand: Operand) {
        nes.cpu.PC = operand
    }

    /// jumpToSubroutine
    mutating func JSR(operand: Operand) {
        pushStack(word: nes.cpu.PC &- 1)
        tick()
        nes.cpu.PC = operand
    }

    /// returnFromSubroutine
    mutating func RTS(operand: Operand) {
        tick(count: 3)
        nes.cpu.PC = pullStack() &+ 1
    }

    /// returnFromInterrupt
    mutating func RTI(operand: Operand) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        tick(count: 2)
        nes.cpu.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        nes.cpu.PC = pullStack()
    }

    // MARK: - Branch instructions

    private mutating func branch(operand: Operand, test: Bool) {
        if test {
            tick()
            let pc = Int(nes.cpu.PC)
            let offset = Int(operand.i8)
            if pageCrossed(value: pc, operand: offset) {
                tick()
            }
            nes.cpu.PC = UInt16(pc &+ offset)
        }
    }

    /// branchIfCarryClear
    mutating func BCC(operand: Operand) {
        branch(operand: operand, test: !nes.cpu.P.contains(.C))
    }

    /// branchIfCarrySet
    mutating func BCS(operand: Operand) {
        branch(operand: operand, test: nes.cpu.P.contains(.C))
    }

    /// branchIfEqual
    mutating func BEQ(operand: Operand) {
        branch(operand: operand, test: nes.cpu.P.contains(.Z))
    }

    /// branchIfMinus
    mutating func BMI(operand: Operand) {
        branch(operand: operand, test: nes.cpu.P.contains(.N))
    }

    /// branchIfNotEqual
    mutating func BNE(operand: Operand) {
        branch(operand: operand, test: !nes.cpu.P.contains(.Z))
    }

    /// branchIfPlus
    mutating func BPL(operand: Operand) {
        branch(operand: operand, test: !nes.cpu.P.contains(.N))
    }

    /// branchIfOverflowClear
    mutating func BVC(operand: Operand) {
        branch(operand: operand, test: !nes.cpu.P.contains(.V))
    }

    /// branchIfOverflowSet
    mutating func BVS(operand: Operand) {
        branch(operand: operand, test: nes.cpu.P.contains(.V))
    }

    // MARK: - Flag control instructions

    /// clearCarry
    mutating func CLC(operand: Operand) {
        nes.cpu.P.remove(.C)
        tick()
    }

    /// clearDecimal
    mutating func CLD(operand: Operand) {
        nes.cpu.P.remove(.D)
        tick()
    }

    /// clearInterrupt
    mutating func CLI(operand: Operand) {
        nes.cpu.P.remove(.I)
        tick()
    }

    /// clearOverflow
    mutating func CLV(operand: Operand) {
        nes.cpu.P.remove(.V)
        tick()
    }

    /// setCarryFlag
    mutating func SEC(operand: Operand) {
        nes.cpu.P.formUnion(.C)
        tick()
    }

    /// setDecimalFlag
    mutating func SED(operand: Operand) {
        nes.cpu.P.formUnion(.D)
        tick()
    }

    /// setInterruptDisable
    mutating func SEI(operand: Operand) {
        nes.cpu.P.formUnion(.I)
        tick()
    }

    // MARK: - Misc

    /// forceInterrupt
    mutating func BRK(operand: Operand) {
        pushStack(word: nes.cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | Status.interruptedB.rawValue)
        tick()
        nes.cpu.PC = M.cpuReadWord(at: 0xFFFE, from: &nes)
    }

    /// doNothing
    mutating func NOP(operand: Operand) {
        tick()
    }

    // MARK: - Unofficial

    /// loadAccumulatorAndX
    mutating func LAX(operand: Operand) {
        let data = M.cpuRead(at: operand, from: &nes)
        nes.cpu.A = data
        nes.cpu.X = data
    }

    /// storeAccumulatorAndX
    mutating func SAX(operand: Operand) {
        M.cpuWrite(nes.cpu.A & nes.cpu.X, at: operand, to: &nes)
    }

    /// decrementMemoryAndCompareAccumulator
    mutating func DCP(operand: Operand) {
        // decrementMemory excluding tick
        let result = M.cpuRead(at: operand, from: &nes) &- 1
        nes.cpu.P.setZN(result)
        M.cpuWrite(result, at: operand, to: &nes)

        CMP(operand: operand)
    }

    /// incrementMemoryAndSubtractWithCarry
    mutating func ISB(operand: Operand) {
        // incrementMemory excluding tick
        let result = M.cpuRead(at: operand, from: &nes) &+ 1
        nes.cpu.P.setZN(result)
        M.cpuWrite(result, at: operand, to: &nes)

        SBC(operand: operand)
    }

    /// arithmeticShiftLeftAndBitwiseORwithAccumulator
    mutating func SLO(operand: Operand) {
        // arithmeticShiftLeft excluding tick
        var data = M.cpuRead(at: operand, from: &nes)
        nes.cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 {
            nes.cpu.P.formUnion(.C)
        }

        data <<= 1
        nes.cpu.P.setZN(data)
        M.cpuWrite(data, at: operand, to: &nes)

        ORA(operand: operand)
    }

    /// rotateLeftAndBitwiseANDwithAccumulator
    mutating func RLA(operand: Operand) {
        // rotateLeft excluding tick
        var data = M.cpuRead(at: operand, from: &nes)
        let c = data & 0x80

        data <<= 1
        if nes.cpu.P.contains(.C) {
            data |= 0x01
        }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 0x80 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.P.setZN(data)
        M.cpuWrite(data, at: operand, to: &nes)

        AND(operand: operand)
    }

    /// logicalShiftRightAndBitwiseExclusiveOR
    mutating func SRE(operand: Operand) {
        // logicalShiftRight excluding tick
        var data = M.cpuRead(at: operand, from: &nes)
        nes.cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 {
            nes.cpu.P.formUnion(.C)
        }

        data >>= 1

        nes.cpu.P.setZN(data)
        M.cpuWrite(data, at: operand, to: &nes)

        EOR(operand: operand)
    }

    /// rotateRightAndAddWithCarry
    mutating func RRA(operand: Operand) {
        // rotateRight excluding tick
        var data = M.cpuRead(at: operand, from: &nes)
        let c = data & 0x01

        data >>= 1
        if nes.cpu.P.contains(.C) {
            data |= 0x80
        }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 1 {
            nes.cpu.P.formUnion(.C)
        }

        nes.cpu.P.setZN(data)
        M.cpuWrite(data, at: operand, to: &nes)

        ADC(operand: operand)
    }
}
