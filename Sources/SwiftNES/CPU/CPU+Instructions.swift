typealias OpCode = UInt8

typealias Operand = UInt16

// swiftlint:disable file_length cyclomatic_complexity function_body_length
extension CPU {

    @inline(__always)
    static func fetchOperand(from cpu: inout CPU) -> OpCode {
        let opcode = cpu.read(at: cpu.PC)
        cpu.PC &+= 1
        return opcode
    }

    @inline(__always)
    static func excuteInstruction(opcode: OpCode, on cpu: inout CPU) {
        switch opcode {
        case 0xA9:
            CPU.LDA(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0xA5:
            CPU.LDA(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xB5:
            CPU.LDA(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xAD:
            CPU.LDA(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xBD:
            CPU.LDA(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0xB9:
            CPU.LDA(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0xA1:
            CPU.LDA(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0xB1:
            CPU.LDA(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0xA2:
            CPU.LDX(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0xA6:
            CPU.LDX(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xB6:
            CPU.LDX(operand: CPU.zeroPageY(on: &cpu), on: &cpu)
        case 0xAE:
            CPU.LDX(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xBE:
            CPU.LDX(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0xA0:
            CPU.LDY(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0xA4:
            CPU.LDY(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xB4:
            CPU.LDY(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xAC:
            CPU.LDY(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xBC:
            CPU.LDY(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0x85:
            CPU.STA(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x95:
            CPU.STA(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x8D:
            CPU.STA(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x9D:
            CPU.STA(operand: CPU.absoluteX(on: &cpu), on: &cpu)
        case 0x99:
            CPU.STA(operand: CPU.absoluteY(on: &cpu), on: &cpu)
        case 0x81:
            CPU.STA(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x91:
            CPU.STAWithTick(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x86:
            CPU.STX(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x96:
            CPU.STX(operand: CPU.zeroPageY(on: &cpu), on: &cpu)
        case 0x8E:
            CPU.STX(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x84:
            CPU.STY(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x94:
            CPU.STY(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x8C:
            CPU.STY(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xAA:
            CPU.TAX(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0xBA:
            CPU.TSX(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0xA8:
            CPU.TAY(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x8A:
            CPU.TXA(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x9A:
            CPU.TXS(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x98:
            CPU.TYA(operand: CPU.implicit(on: &cpu), on: &cpu)

        case 0x48:
            CPU.PHA(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x08:
            CPU.PHP(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x68:
            CPU.PLA(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x28:
            CPU.PLP(operand: CPU.implicit(on: &cpu), on: &cpu)

        case 0x29:
            CPU.AND(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0x25:
            CPU.AND(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x35:
            CPU.AND(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x2D:
            CPU.AND(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x3D:
            CPU.AND(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0x39:
            CPU.AND(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0x21:
            CPU.AND(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x31:
            CPU.AND(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x49:
            CPU.EOR(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0x45:
            CPU.EOR(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x55:
            CPU.EOR(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x4D:
            CPU.EOR(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x5D:
            CPU.EOR(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0x59:
            CPU.EOR(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0x41:
            CPU.EOR(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x51:
            CPU.EOR(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x09:
            CPU.ORA(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0x05:
            CPU.ORA(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x15:
            CPU.ORA(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x0D:
            CPU.ORA(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x1D:
            CPU.ORA(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0x19:
            CPU.ORA(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0x01:
            CPU.ORA(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x11:
            CPU.ORA(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x24:
            CPU.BIT(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x2C:
            CPU.BIT(operand: CPU.absolute(on: &cpu), on: &cpu)

        case 0x69:
            CPU.ADC(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0x65:
            CPU.ADC(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x75:
            CPU.ADC(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x6D:
            CPU.ADC(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x7D:
            CPU.ADC(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0x79:
            CPU.ADC(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0x61:
            CPU.ADC(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x71:
            CPU.ADC(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0xE9:
            CPU.SBC(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0xE5:
            CPU.SBC(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xF5:
            CPU.SBC(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xED:
            CPU.SBC(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xFD:
            CPU.SBC(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0xF9:
            CPU.SBC(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0xE1:
            CPU.SBC(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0xF1:
            CPU.SBC(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0xC9:
            CPU.CMP(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0xC5:
            CPU.CMP(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xD5:
            CPU.CMP(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xCD:
            CPU.CMP(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xDD:
            CPU.CMP(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0xD9:
            CPU.CMP(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)
        case 0xC1:
            CPU.CMP(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0xD1:
            CPU.CMP(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0xE0:
            CPU.CPX(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0xE4:
            CPU.CPX(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xEC:
            CPU.CPX(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xC0:
            CPU.CPY(operand: CPU.immediate(on: &cpu), on: &cpu)
        case 0xC4:
            CPU.CPY(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xCC:
            CPU.CPY(operand: CPU.absolute(on: &cpu), on: &cpu)

        case 0xE6:
            CPU.INC(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xF6:
            CPU.INC(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xEE:
            CPU.INC(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xFE:
            CPU.INC(operand: CPU.absoluteX(on: &cpu), on: &cpu)
        case 0xE8:
            CPU.INX(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0xC8:
            CPU.INY(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0xC6:
            CPU.DEC(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xD6:
            CPU.DEC(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xCE:
            CPU.DEC(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xDE:
            CPU.DEC(operand: CPU.absoluteX(on: &cpu), on: &cpu)
        case 0xCA:
            CPU.DEX(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x88:
            CPU.DEY(operand: CPU.implicit(on: &cpu), on: &cpu)

        case 0x0A:
            CPU.ASLForAccumulator(operand: CPU.accumulator(on: &cpu), on: &cpu)
        case 0x06:
            CPU.ASL(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x16:
            CPU.ASL(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x0E:
            CPU.ASL(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x1E:
            CPU.ASL(operand: CPU.absoluteX(on: &cpu), on: &cpu)
        case 0x4A:
            CPU.LSRForAccumulator(operand: CPU.accumulator(on: &cpu), on: &cpu)
        case 0x46:
            CPU.LSR(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x56:
            CPU.LSR(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x4E:
            CPU.LSR(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x5E:
            CPU.LSR(operand: CPU.absoluteX(on: &cpu), on: &cpu)
        case 0x2A:
            CPU.ROLForAccumulator(operand: CPU.accumulator(on: &cpu), on: &cpu)
        case 0x26:
            CPU.ROL(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x36:
            CPU.ROL(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x2E:
            CPU.ROL(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x3E:
            CPU.ROL(operand: CPU.absoluteX(on: &cpu), on: &cpu)
        case 0x6A:
            CPU.RORForAccumulator(operand: CPU.accumulator(on: &cpu), on: &cpu)
        case 0x66:
            CPU.ROR(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x76:
            CPU.ROR(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x6E:
            CPU.ROR(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x7E:
            CPU.ROR(operand: CPU.absoluteX(on: &cpu), on: &cpu)

        case 0x4C:
            CPU.JMP(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x6C:
            CPU.JMP(operand: CPU.indirect(on: &cpu), on: &cpu)
        case 0x20:
            CPU.JSR(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x60:
            CPU.RTS(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x40:
            CPU.RTI(operand: CPU.implicit(on: &cpu), on: &cpu)

        case 0x90:
            CPU.BCC(operand: CPU.relative(on: &cpu), on: &cpu)
        case 0xB0:
            CPU.BCS(operand: CPU.relative(on: &cpu), on: &cpu)
        case 0xF0:
            CPU.BEQ(operand: CPU.relative(on: &cpu), on: &cpu)
        case 0x30:
            CPU.BMI(operand: CPU.relative(on: &cpu), on: &cpu)
        case 0xD0:
            CPU.BNE(operand: CPU.relative(on: &cpu), on: &cpu)
        case 0x10:
            CPU.BPL(operand: CPU.relative(on: &cpu), on: &cpu)
        case 0x50:
            CPU.BVC(operand: CPU.relative(on: &cpu), on: &cpu)
        case 0x70:
            CPU.BVS(operand: CPU.relative(on: &cpu), on: &cpu)

        case 0x18:
            CPU.CLC(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0xD8:
            CPU.CLD(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x58:
            CPU.CLI(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0xB8:
            CPU.CLV(operand: CPU.implicit(on: &cpu), on: &cpu)

        case 0x38:
            CPU.SEC(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0xF8:
            CPU.SED(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x78:
            CPU.SEI(operand: CPU.implicit(on: &cpu), on: &cpu)

        case 0x00:
            CPU.BRK(operand: CPU.implicit(on: &cpu), on: &cpu)

        // Undocumented

        case 0xEB:
            CPU.SBC(operand: CPU.immediate(on: &cpu), on: &cpu)

        case 0x04, 0x44, 0x64:
            CPU.NOP(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x0C:
            CPU.NOP(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            CPU.NOP(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            CPU.NOP(operand: CPU.implicit(on: &cpu), on: &cpu)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            CPU.NOP(operand: CPU.absoluteXWithPenalty(on: &cpu), on: &cpu)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            CPU.NOP(operand: CPU.immediate(on: &cpu), on: &cpu)

        case 0xA3:
            CPU.LAX(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0xA7:
            CPU.LAX(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xAF:
            CPU.LAX(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xB3:
            CPU.LAX(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0xB7:
            CPU.LAX(operand: CPU.zeroPageY(on: &cpu), on: &cpu)
        case 0xBF:
            CPU.LAX(operand: CPU.absoluteYWithPenalty(on: &cpu), on: &cpu)

        case 0x83:
            CPU.SAX(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x87:
            CPU.SAX(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x8F:
            CPU.SAX(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x97:
            CPU.SAX(operand: CPU.zeroPageY(on: &cpu), on: &cpu)

        case 0xC3:
            CPU.DCP(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0xC7:
            CPU.DCP(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xCF:
            CPU.DCP(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xD3:
            CPU.DCP(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0xD7:
            CPU.DCP(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xDB:
            CPU.DCP(operand: CPU.absoluteY(on: &cpu), on: &cpu)
        case 0xDF:
            CPU.DCP(operand: CPU.absoluteX(on: &cpu), on: &cpu)

        case 0xE3:
            CPU.ISB(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0xE7:
            CPU.ISB(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0xEF:
            CPU.ISB(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0xF3:
            CPU.ISB(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0xF7:
            CPU.ISB(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0xFB:
            CPU.ISB(operand: CPU.absoluteY(on: &cpu), on: &cpu)
        case 0xFF:
            CPU.ISB(operand: CPU.absoluteX(on: &cpu), on: &cpu)

        case 0x03:
            CPU.SLO(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x07:
            CPU.SLO(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x0F:
            CPU.SLO(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x13:
            CPU.SLO(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x17:
            CPU.SLO(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x1B:
            CPU.SLO(operand: CPU.absoluteY(on: &cpu), on: &cpu)
        case 0x1F:
            CPU.SLO(operand: CPU.absoluteX(on: &cpu), on: &cpu)

        case 0x23:
            CPU.RLA(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x27:
            CPU.RLA(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x2F:
            CPU.RLA(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x33:
            CPU.RLA(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x37:
            CPU.RLA(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x3B:
            CPU.RLA(operand: CPU.absoluteY(on: &cpu), on: &cpu)
        case 0x3F:
            CPU.RLA(operand: CPU.absoluteX(on: &cpu), on: &cpu)

        case 0x43:
            CPU.SRE(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x47:
            CPU.SRE(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x4F:
            CPU.SRE(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x53:
            CPU.SRE(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x57:
            CPU.SRE(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x5B:
            CPU.SRE(operand: CPU.absoluteY(on: &cpu), on: &cpu)
        case 0x5F:
            CPU.SRE(operand: CPU.absoluteX(on: &cpu), on: &cpu)

        case 0x63:
            CPU.RRA(operand: CPU.indexedIndirect(on: &cpu), on: &cpu)
        case 0x67:
            CPU.RRA(operand: CPU.zeroPage(on: &cpu), on: &cpu)
        case 0x6F:
            CPU.RRA(operand: CPU.absolute(on: &cpu), on: &cpu)
        case 0x73:
            CPU.RRA(operand: CPU.indirectIndexed(on: &cpu), on: &cpu)
        case 0x77:
            CPU.RRA(operand: CPU.zeroPageX(on: &cpu), on: &cpu)
        case 0x7B:
            CPU.RRA(operand: CPU.absoluteY(on: &cpu), on: &cpu)
        case 0x7F:
            CPU.RRA(operand: CPU.absoluteX(on: &cpu), on: &cpu)

        default:
            CPU.NOP(operand: CPU.implicit(on: &cpu), on: &cpu)
        }
    }
}

// MARK: - Operations
extension CPU {
    // Implements for Load/Store Operations

    /// loadAccumulator
    static func LDA(operand: Operand, on cpu: inout CPU) {
        cpu.A = cpu.read(at: operand)
    }

    /// loadXRegister
    static func LDX(operand: Operand, on cpu: inout CPU) {
        cpu.X = cpu.read(at: operand)
    }

    /// loadYRegister
    static func LDY(operand: Operand, on cpu: inout CPU) {
        cpu.Y = cpu.read(at: operand)
    }

    /// storeAccumulator
    static func STA(operand: Operand, on cpu: inout CPU) {
        cpu.write(cpu.A, at: operand)
    }

    static func STAWithTick(operand: Operand, on cpu: inout CPU) {
        cpu.write(cpu.A, at: operand)
        cpu.tick()
    }

    /// storeXRegister
    static func STX(operand: Operand, on cpu: inout CPU) {
        cpu.write(cpu.X, at: operand)
    }

    /// storeYRegister
    static func STY(operand: Operand, on cpu: inout CPU) {
        cpu.write(cpu.Y, at: operand)
    }

    // MARK: - Register Operations

    /// transferAccumulatorToX
    static func TAX(operand: Operand, on cpu: inout CPU) {
        cpu.X = cpu.A
        cpu.tick()
    }

    /// transferStackPointerToX
    static func TSX(operand: Operand, on cpu: inout CPU) {
        cpu.X = cpu.S
        cpu.tick()
    }

    /// transferAccumulatorToY
    static func TAY(operand: Operand, on cpu: inout CPU) {
        cpu.Y = cpu.A
        cpu.tick()
    }

    /// transferXtoAccumulator
    static func TXA(operand: Operand, on cpu: inout CPU) {
        cpu.A = cpu.X
        cpu.tick()
    }

    /// transferXtoStackPointer
    static func TXS(operand: Operand, on cpu: inout CPU) {
        cpu.S = cpu.X
        cpu.tick()
    }

    /// transferYtoAccumulator
    static func TYA(operand: Operand, on cpu: inout CPU) {
        cpu.A = cpu.Y
        cpu.tick()
    }

    // MARK: - Stack instructions

    /// pushAccumulator
    static func PHA(operand: Operand, on cpu: inout CPU) {
        pushStack(cpu.A, to: &cpu)
        cpu.tick()
    }

    /// pushProcessorStatus
    static func PHP(operand: Operand, on cpu: inout CPU) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | Status.operatedB.rawValue, to: &cpu)
        cpu.tick()
    }

    /// pullAccumulator
    static func PLA(operand: Operand, on cpu: inout CPU) {
        cpu.A = pullStack(from: &cpu)
        cpu.tick(count: 2)
    }

    /// pullProcessorStatus
    static func PLP(operand: Operand, on cpu: inout CPU) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.P = Status(rawValue: pullStack(from: &cpu) & ~Status.B.rawValue | Status.R.rawValue)
        cpu.tick(count: 2)
    }

    // MARK: - Logical instructions

    /// bitwiseANDwithAccumulator
    static func AND(operand: Operand, on cpu: inout CPU) {
        cpu.A &= cpu.read(at: operand)
    }

    /// bitwiseExclusiveOR
    static func EOR(operand: Operand, on cpu: inout CPU) {
        cpu.A ^= cpu.read(at: operand)
    }

    /// bitwiseORwithAccumulator
    static func ORA(operand: Operand, on cpu: inout CPU) {
        cpu.A |= cpu.read(at: operand)
    }

    /// testBits
    static func BIT(operand: Operand, on cpu: inout CPU) {
        let value = cpu.read(at: operand)
        let data = cpu.A & value
        cpu.P.remove([.Z, .V, .N])
        if data == 0 { cpu.P.formUnion(.Z) } else { cpu.P.remove(.Z) }
        if value[6] == 1 { cpu.P.formUnion(.V) } else { cpu.P.remove(.V) }
        if value[7] == 1 { cpu.P.formUnion(.N) } else { cpu.P.remove(.N) }
    }

    // MARK: - Arithmetic instructions

    /// addWithCarry
    static func ADC(operand: Operand, on cpu: inout CPU) {
        let a = cpu.A
        let val = cpu.read(at: operand)
        var result = a &+ val

        if cpu.P.contains(.C) { result &+= 1 }

        cpu.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { cpu.P.formUnion(.C) }
        if c6 ^ c7 == 1 { cpu.P.formUnion(.V) }

        cpu.A = result
    }

    /// subtractWithCarry
    static func SBC(operand: Operand, on cpu: inout CPU) {
        let a = cpu.A
        let val = ~cpu.read(at: operand)
        var result = a &+ val

        if cpu.P.contains(.C) { result &+= 1 }

        cpu.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { cpu.P.formUnion(.C) }
        if c6 ^ c7 == 1 { cpu.P.formUnion(.V) }

        cpu.A = result
    }

    /// compareAccumulator
    static func CMP(operand: Operand, on cpu: inout CPU) {
        let cmp = Int16(cpu.A) &- Int16(cpu.read(at: operand))

        cpu.P.remove([.C, .Z, .N])
        cpu.P.setZN(cmp)
        if 0 <= cmp { cpu.P.formUnion(.C) } else { cpu.P.remove(.C) }

    }

    /// compareXRegister
    static func CPX(operand: Operand, on cpu: inout CPU) {
        let value = cpu.read(at: operand)
        let cmp = cpu.X &- value

        cpu.P.remove([.C, .Z, .N])
        cpu.P.setZN(cmp)
        if cpu.X >= value { cpu.P.formUnion(.C) } else { cpu.P.remove(.C) }

    }

    /// compareYRegister
    static func CPY(operand: Operand, on cpu: inout CPU) {
        let value = cpu.read(at: operand)
        let cmp = cpu.Y &- value

        cpu.P.remove([.C, .Z, .N])
        cpu.P.setZN(cmp)
        if cpu.Y >= value { cpu.P.formUnion(.C) } else { cpu.P.remove(.C) }

    }

    // MARK: - Increment/Decrement instructions

    /// incrementMemory
    static func INC(operand: Operand, on cpu: inout CPU) {
        let result = cpu.read(at: operand) &+ 1

        cpu.P.setZN(result)
        cpu.write(result, at: operand)

        cpu.tick()

    }

    /// incrementX
    static func INX(operand: Operand, on cpu: inout CPU) {
        cpu.X = cpu.X &+ 1
        cpu.tick()
    }

    /// incrementY
    static func INY(operand: Operand, on cpu: inout CPU) {
        cpu.Y = cpu.Y &+ 1
        cpu.tick()
    }

    /// decrementMemory
    static func DEC(operand: Operand, on cpu: inout CPU) {
        let result = cpu.read(at: operand) &- 1
        cpu.P.setZN(result)

        cpu.write(result, at: operand)
        cpu.tick()
    }

    /// decrementX
    static func DEX(operand: Operand, on cpu: inout CPU) {
        cpu.X = cpu.X &- 1
        cpu.tick()
    }

    /// decrementY
    static func DEY(operand: Operand, on cpu: inout CPU) {
        cpu.Y = cpu.Y &- 1
        cpu.tick()
    }

    // MARK: - Shift instructions

    /// arithmeticShiftLeft
    static func ASL(operand: Operand, on cpu: inout CPU) {
        var data = cpu.read(at: operand)

        cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 { cpu.P.formUnion(.C) }

        data <<= 1

        cpu.P.setZN(data)

        cpu.write(data, at: operand)

        cpu.tick()
    }

    static func ASLForAccumulator(operand: Operand, on cpu: inout CPU) {
        cpu.P.remove([.C, .Z, .N])
        if cpu.A[7] == 1 { cpu.P.formUnion(.C) }

        cpu.A <<= 1

        cpu.tick()
    }

    /// logicalShiftRight
    static func LSR(operand: Operand, on cpu: inout CPU) {
        var data = cpu.read(at: operand)

        cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 { cpu.P.formUnion(.C) }

        data >>= 1

        cpu.P.setZN(data)

        cpu.write(data, at: operand)

        cpu.tick()
    }

    static func LSRForAccumulator(operand: Operand, on cpu: inout CPU) {
        cpu.P.remove([.C, .Z, .N])
        if cpu.A[0] == 1 { cpu.P.formUnion(.C) }

        cpu.A >>= 1

        cpu.tick()
    }

    /// rotateLeft
    static func ROL(operand: Operand, on cpu: inout CPU) {
        var data = cpu.read(at: operand)
        let c = data & 0x80

        data <<= 1
        if cpu.P.contains(.C) { data |= 0x01 }

        cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)

        cpu.write(data, at: operand)

        cpu.tick()
    }

    static func ROLForAccumulator(operand: Operand, on cpu: inout CPU) {
        let c = cpu.A & 0x80

        var a = cpu.A << 1
        if cpu.P.contains(.C) { a |= 0x01 }

        cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { cpu.P.formUnion(.C) }

        cpu.A = a

        cpu.tick()
    }

    /// rotateRight
    static func ROR(operand: Operand, on cpu: inout CPU) {
        var data = cpu.read(at: operand)
        let c = data & 0x01

        data >>= 1
        if cpu.P.contains(.C) { data |= 0x80 }

        cpu.P.remove([.C, .Z, .N])
        if c == 1 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)

        cpu.write(data, at: operand)

        cpu.tick()
    }

    static func RORForAccumulator(operand: Operand, on cpu: inout CPU) {
        let c = cpu.A & 0x01

        var a = cpu.A >> 1
        if cpu.P.contains(.C) { a |= 0x80 }

        cpu.P.remove([.C, .Z, .N])
        if c == 1 { cpu.P.formUnion(.C) }

        cpu.A = a

        cpu.tick()
    }

    // MARK: - Jump instructions

    /// jump
    static func JMP(operand: Operand, on cpu: inout CPU) {
        cpu.PC = operand
    }

    /// jumpToSubroutine
    static func JSR(operand: Operand, on cpu: inout CPU) {
        pushStack(word: cpu.PC &- 1, to: &cpu)
        cpu.tick()
        cpu.PC = operand
    }

    /// returnFromSubroutine
    static func RTS(operand: Operand, on cpu: inout CPU) {
        cpu.tick(count: 3)
        cpu.PC = pullStack(from: &cpu) &+ 1
    }

    /// returnFromInterrupt
    static func RTI(operand: Operand, on cpu: inout CPU) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.tick(count: 2)
        cpu.P = Status(rawValue: pullStack(from: &cpu) & ~Status.B.rawValue | Status.R.rawValue)
        cpu.PC = pullStack(from: &cpu)
    }

    // MARK: - Branch instructions

    private static func branch(operand: Operand, test: Bool, on cpu: inout CPU) {
        if test {
            cpu.tick()
            let pc = Int(cpu.PC)
            let offset = Int(operand.i8)
            if pageCrossed(value: pc, operand: offset) {
                cpu.tick()
            }
            cpu.PC = UInt16(pc &+ offset)
        }
    }

    /// branchIfCarryClear
    static func BCC(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: !cpu.P.contains(.C), on: &cpu)
    }

    /// branchIfCarrySet
    static func BCS(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: cpu.P.contains(.C), on: &cpu)
    }

    /// branchIfEqual
    static func BEQ(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: cpu.P.contains(.Z), on: &cpu)
    }

    /// branchIfMinus
    static func BMI(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: cpu.P.contains(.N), on: &cpu)
    }

    /// branchIfNotEqual
    static func BNE(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: !cpu.P.contains(.Z), on: &cpu)
    }

    /// branchIfPlus
    static func BPL(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: !cpu.P.contains(.N), on: &cpu)
    }

    /// branchIfOverflowClear
    static func BVC(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: !cpu.P.contains(.V), on: &cpu)
    }

    /// branchIfOverflowSet
    static func BVS(operand: Operand, on cpu: inout CPU) {
        branch(operand: operand, test: cpu.P.contains(.V), on: &cpu)
    }

    // MARK: - Flag control instructions

    /// clearCarry
    static func CLC(operand: Operand, on cpu: inout CPU) {
        cpu.P.remove(.C)
        cpu.tick()
    }

    /// clearDecimal
    static func CLD(operand: Operand, on cpu: inout CPU) {
        cpu.P.remove(.D)
        cpu.tick()
    }

    /// clearInterrupt
    static func CLI(operand: Operand, on cpu: inout CPU) {
        cpu.P.remove(.I)
        cpu.tick()
    }

    /// clearOverflow
    static func CLV(operand: Operand, on cpu: inout CPU) {
        cpu.P.remove(.V)
        cpu.tick()
    }

    /// setCarryFlag
    static func SEC(operand: Operand, on cpu: inout CPU) {
        cpu.P.formUnion(.C)
        cpu.tick()
    }

    /// setDecimalFlag
    static func SED(operand: Operand, on cpu: inout CPU) {
        cpu.P.formUnion(.D)
        cpu.tick()
    }

    /// setInterruptDisable
    static func SEI(operand: Operand, on cpu: inout CPU) {
        cpu.P.formUnion(.I)
        cpu.tick()
    }

    // MARK: - Misc

    /// forceInterrupt
    static func BRK(operand: Operand, on cpu: inout CPU) {
        pushStack(word: cpu.PC, to: &cpu)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | Status.interruptedB.rawValue, to: &cpu)
        cpu.tick()
        cpu.PC = cpu.readWord(at: 0xFFFE)
    }

    /// doNothing
    static func NOP(operand: Operand, on cpu: inout CPU) {
        cpu.tick()
    }

    // MARK: - Unofficial

    /// loadAccumulatorAndX
    static func LAX(operand: Operand, on cpu: inout CPU) {
        let data = cpu.read(at: operand)
        cpu.A = data
        cpu.X = data
    }

    /// storeAccumulatorAndX
    static func SAX(operand: Operand, on cpu: inout CPU) {
        cpu.write(cpu.A & cpu.X, at: operand)
    }

    /// decrementMemoryAndCompareAccumulator
    static func DCP(operand: Operand, on cpu: inout CPU) {
        // decrementMemory excluding cpu.tick
        let result = cpu.read(at: operand) &- 1
        cpu.P.setZN(result)
        cpu.write(result, at: operand)

        CMP(operand: operand, on: &cpu)
    }

    /// incrementMemoryAndSubtractWithCarry
    static func ISB(operand: Operand, on cpu: inout CPU) {
        // incrementMemory excluding cpu.tick
        let result = cpu.read(at: operand) &+ 1
        cpu.P.setZN(result)
        cpu.write(result, at: operand)

        SBC(operand: operand, on: &cpu)
    }

    /// arithmeticShiftLeftAndBitwiseORwithAccumulator
    static func SLO(operand: Operand, on cpu: inout CPU) {
        // arithmeticShiftLeft excluding cpu.tick
        var data = cpu.read(at: operand)
        cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 { cpu.P.formUnion(.C) }

        data <<= 1
        cpu.P.setZN(data)
        cpu.write(data, at: operand)

        ORA(operand: operand, on: &cpu)
    }

    /// rotateLeftAndBitwiseANDwithAccumulator
    static func RLA(operand: Operand, on cpu: inout CPU) {
        // rotateLeft excluding cpu.tick
        var data = cpu.read(at: operand)
        let c = data & 0x80

        data <<= 1
        if cpu.P.contains(.C) { data |= 0x01 }

        cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)
        cpu.write(data, at: operand)

        AND(operand: operand, on: &cpu)
    }

    /// logicalShiftRightAndBitwiseExclusiveOR
    static func SRE(operand: Operand, on cpu: inout CPU) {
        // logicalShiftRight excluding cpu.tick
        var data = cpu.read(at: operand)
        cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 { cpu.P.formUnion(.C) }

        data >>= 1

        cpu.P.setZN(data)
        cpu.write(data, at: operand)

        EOR(operand: operand, on: &cpu)
    }

    /// rotateRightAndAddWithCarry
    static func RRA(operand: Operand, on cpu: inout CPU) {
        // rotateRight excluding cpu.tick
        var data = cpu.read(at: operand)
        let c = data & 0x01

        data >>= 1
        if cpu.P.contains(.C) { data |= 0x80 }

        cpu.P.remove([.C, .Z, .N])
        if c == 1 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)
        cpu.write(data, at: operand)

        ADC(operand: operand, on: &cpu)
    }
}

// MARK: - Stack
@inline(__always)
func pushStack(_ value: UInt8, to cpu: inout CPU) {
    cpu.write(value, at: cpu.S.u16 &+ 0x100)
    cpu.S &-= 1
}

@inline(__always)
func pushStack(word: UInt16, to cpu: inout CPU) {
    pushStack(UInt8(word >> 8), to: &cpu)
    pushStack(UInt8(word & 0xFF), to: &cpu)
}

@inline(__always)
func pullStack(from cpu: inout CPU) -> UInt8 {
    cpu.S &+= 1
    return cpu.read(at: cpu.S.u16 &+ 0x100)
}

@inline(__always)
func pullStack(from cpu: inout CPU) -> UInt16 {
    let lo: UInt8 = pullStack(from: &cpu)
    let ho: UInt8 = pullStack(from: &cpu)
    return ho.u16 &<< 8 | lo.u16
}
