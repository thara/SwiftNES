// swiftlint:disable file_length cyclomatic_complexity function_body_length

@inline(__always)
func excuteInstruction(opcode: UInt8, cpu: inout CPU, memory: inout Memory) {
    switch opcode {
    case 0xA9:
        LDA(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA5:
        LDA(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB5:
        LDA(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xAD:
        LDA(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xBD:
        LDA(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB9:
        LDA(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA1:
        LDA(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB1:
        LDA(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA2:
        LDX(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA6:
        LDX(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB6:
        LDX(operand: .zeroPageY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xAE:
        LDX(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xBE:
        LDX(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA0:
        LDY(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA4:
        LDY(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB4:
        LDY(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xAC:
        LDY(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xBC:
        LDY(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x85:
        STA(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x95:
        STA(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x8D:
        STA(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x9D:
        STA(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x99:
        STA(operand: .absoluteY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x81:
        STA(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x91:
        STAWithTick(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x86:
        STX(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x96:
        STX(operand: .zeroPageY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x8E:
        STX(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x84:
        STY(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x94:
        STY(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x8C:
        STY(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xAA:
        TAX(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xBA:
        TSX(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA8:
        TAY(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x8A:
        TXA(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x9A:
        TXS(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x98:
        TYA(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x48:
        PHA(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x08:
        PHP(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x68:
        PLA(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x28:
        PLP(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x29:
        AND(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x25:
        AND(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x35:
        AND(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x2D:
        AND(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x3D:
        AND(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x39:
        AND(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x21:
        AND(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x31:
        AND(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x49:
        EOR(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x45:
        EOR(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x55:
        EOR(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x4D:
        EOR(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x5D:
        EOR(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x59:
        EOR(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x41:
        EOR(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x51:
        EOR(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x09:
        ORA(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x05:
        ORA(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x15:
        ORA(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x0D:
        ORA(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x1D:
        ORA(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x19:
        ORA(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x01:
        ORA(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x11:
        ORA(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x24:
        BIT(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x2C:
        BIT(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x69:
        ADC(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x65:
        ADC(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x75:
        ADC(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x6D:
        ADC(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x7D:
        ADC(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x79:
        ADC(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x61:
        ADC(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x71:
        ADC(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xE9:
        SBC(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xE5:
        SBC(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF5:
        SBC(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xED:
        SBC(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xFD:
        SBC(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF9:
        SBC(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xE1:
        SBC(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF1:
        SBC(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC9:
        CMP(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC5:
        CMP(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD5:
        CMP(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xCD:
        CMP(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xDD:
        CMP(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD9:
        CMP(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC1:
        CMP(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD1:
        CMP(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xE0:
        CPX(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xE4:
        CPX(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xEC:
        CPX(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC0:
        CPY(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC4:
        CPY(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xCC:
        CPY(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0xE6:
        INC(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF6:
        INC(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xEE:
        INC(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xFE:
        INC(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xE8:
        INX(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC8:
        INY(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC6:
        DEC(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD6:
        DEC(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xCE:
        DEC(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xDE:
        DEC(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xCA:
        DEX(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x88:
        DEY(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x0A:
        ASLForAccumulator(operand: .accumulator(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x06:
        ASL(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x16:
        ASL(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x0E:
        ASL(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x1E:
        ASL(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x4A:
        LSRForAccumulator(operand: .accumulator(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x46:
        LSR(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x56:
        LSR(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x4E:
        LSR(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x5E:
        LSR(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x2A:
        ROLForAccumulator(operand: .accumulator(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x26:
        ROL(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x36:
        ROL(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x2E:
        ROL(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x3E:
        ROL(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x6A:
        RORForAccumulator(operand: .accumulator(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x66:
        ROR(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x76:
        ROR(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x6E:
        ROR(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x7E:
        ROR(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x4C:
        JMP(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x6C:
        JMP(operand: .indirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x20:
        JSR(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x60:
        RTS(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x40:
        RTI(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x90:
        BCC(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB0:
        BCS(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF0:
        BEQ(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x30:
        BMI(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD0:
        BNE(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x10:
        BPL(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x50:
        BVC(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x70:
        BVS(operand: .relative(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x18:
        CLC(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD8:
        CLD(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x58:
        CLI(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB8:
        CLV(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x38:
        SEC(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF8:
        SED(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x78:
        SEI(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x00:
        BRK(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    // Undocumented

    case 0xEB:
        SBC(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x04, 0x44, 0x64:
        NOP(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x0C:
        NOP(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
        NOP(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
        NOP(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
        NOP(operand: .absoluteXWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x80, 0x82, 0x89, 0xC2, 0xE2:
        NOP(operand: .immediate(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0xA3:
        LAX(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xA7:
        LAX(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xAF:
        LAX(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB3:
        LAX(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xB7:
        LAX(operand: .zeroPageY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xBF:
        LAX(operand: .absoluteYWithPenalty(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x83:
        SAX(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x87:
        SAX(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x8F:
        SAX(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x97:
        SAX(operand: .zeroPageY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0xC3:
        DCP(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xC7:
        DCP(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xCF:
        DCP(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD3:
        DCP(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xD7:
        DCP(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xDB:
        DCP(operand: .absoluteY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xDF:
        DCP(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0xE3:
        ISB(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xE7:
        ISB(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xEF:
        ISB(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF3:
        ISB(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xF7:
        ISB(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xFB:
        ISB(operand: .absoluteY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0xFF:
        ISB(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x03:
        SLO(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x07:
        SLO(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x0F:
        SLO(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x13:
        SLO(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x17:
        SLO(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x1B:
        SLO(operand: .absoluteY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x1F:
        SLO(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x23:
        RLA(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x27:
        RLA(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x2F:
        RLA(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x33:
        RLA(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x37:
        RLA(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x3B:
        RLA(operand: .absoluteY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x3F:
        RLA(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x43:
        SRE(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x47:
        SRE(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x4F:
        SRE(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x53:
        SRE(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x57:
        SRE(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x5B:
        SRE(operand: .absoluteY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x5F:
        SRE(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    case 0x63:
        RRA(operand: .indexedIndirect(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x67:
        RRA(operand: .zeroPage(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x6F:
        RRA(operand: .absolute(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x73:
        RRA(operand: .indirectIndexed(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x77:
        RRA(operand: .zeroPageX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x7B:
        RRA(operand: .absoluteY(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    case 0x7F:
        RRA(operand: .absoluteX(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)

    default:
        NOP(operand: .implicit(cpu: &cpu, memory: &memory), cpu: &cpu, memory: &memory)
    }
}

// MARK: - Addressing Mode
extension Operand {

    static func implicit(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        return 0x00
    }

    static func accumulator(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        return cpu.A.u16
    }

    static func immediate(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.PC
        cpu.PC &+= 1
        return operand
    }

    static func zeroPage(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.read(at: cpu.PC, from: &memory).u16 & 0xFF
        cpu.PC &+= 1
        return operand
    }

    static func zeroPageX(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        cpu.tick()

        let operand = (cpu.read(at: cpu.PC, from: &memory).u16 &+ cpu.X.u16) & 0xFF
        cpu.PC &+= 1
        return operand
    }

    static func zeroPageY(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        cpu.tick()

        let operand = (cpu.read(at: cpu.PC, from: &memory).u16 &+ cpu.Y.u16) & 0xFF
        cpu.PC &+= 1
        return operand
    }

    static func absolute(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.readWord(at: cpu.PC, from: &memory)
        cpu.PC &+= 2
        return operand
    }

    static func absoluteX(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC, from: &memory)
        let operand = data &+ cpu.X.u16 & 0xFFFF
        cpu.PC &+= 2
        cpu.tick()
        return operand
    }

    static func absoluteXWithPenalty(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC, from: &memory)
        let operand = data &+ cpu.X.u16 & 0xFFFF
        cpu.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.X) {
            cpu.tick()
        }
        return operand
    }

    static func absoluteY(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC, from: &memory)
        let operand = data &+ cpu.Y.u16 & 0xFFFF
        cpu.PC &+= 2
        cpu.tick()
        return operand
    }

    static func absoluteYWithPenalty(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC, from: &memory)
        let operand = data &+ cpu.Y.u16 & 0xFFFF
        cpu.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }

    static func relative(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.read(at: cpu.PC, from: &memory).u16
        cpu.PC &+= 1
        return operand
    }

    static func indirect(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC, from: &memory)
        let operand = cpu.readOnIndirect(operand: data, from: &memory)
        cpu.PC &+= 2
        return operand
    }

    static func indexedIndirect(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.read(at: cpu.PC, from: &memory)
        let operand = cpu.readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF, from: &memory)
        cpu.PC &+= 1

        cpu.tick()

        return operand
    }

    static func indirectIndexed(cpu: inout CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.read(at: cpu.PC, from: &memory).u16
        let operand = cpu.readOnIndirect(operand: data, from: &memory) &+ cpu.Y.u16
        cpu.PC &+= 1

        if CPU.pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }

}

extension CPU {
    static func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
        return CPU.pageCrossed(value: value, operand: operand.u16)
    }

    static func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
        return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
    }

    static func pageCrossed(value: Int, operand: Int) -> Bool {
        return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
    }
}

// extension Memory {
//     func readOnIndirect(operand: UInt16) -> UInt16 {
//         let low = read(at: operand).u16
//         let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
//         return low | high
//     }
// }

// MARK: - Operations
    // Implements for Load/Store Operations

    /// loadAccumulator
    func LDA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.A = cpu.read(at: operand, from: &memory)
    }

    /// loadXRegister
    func LDX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.X = cpu.read(at: operand, from: &memory)
    }

    /// loadYRegister
    func LDY(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.Y = cpu.read(at: operand, from: &memory)
    }

    /// storeAccumulator
    func STA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.write(cpu.A, at: operand, to: &memory)
    }

    func STAWithTick(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.write(cpu.A, at: operand, to: &memory)
        cpu.tick()
    }

    /// storeXRegister
    func STX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.write(cpu.X, at: operand, to: &memory)
    }

    /// storeYRegister
    func STY(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.write(cpu.Y, at: operand, to: &memory)
    }

    // MARK: - Register Operations

    /// transferAccumulatorToX
    func TAX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.X = cpu.A
        cpu.tick()
    }

    /// transferStackPointerToX
    func TSX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.X = cpu.S
        cpu.tick()
    }

    /// transferAccumulatorToY
    func TAY(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.Y = cpu.A
        cpu.tick()
    }

    /// transferXtoAccumulator
    func TXA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.A = cpu.X
        cpu.tick()
    }

    /// transferXtoStackPointer
    func TXS(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.S = cpu.X
        cpu.tick()
    }

    /// transferYtoAccumulator
    func TYA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.A = cpu.Y
        cpu.tick()
    }

    // MARK: - Stack instructions

    /// pushAccumulator
    func PHA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        pushStack(cpu.A, cpu: &cpu, memory: &memory)
        cpu.tick()
    }

    /// pushProcessorStatus
    func PHP(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | Status.operatedB.rawValue, cpu: &cpu, memory: &memory)
        cpu.tick()
    }

    /// pullAccumulator
    func PLA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.A = pullStack(cpu: &cpu, memory: &memory)
        cpu.tick(count: 2)
    }

    /// pullProcessorStatus
    func PLP(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.P = Status(rawValue: pullStack(cpu: &cpu, memory: &memory) & ~Status.B.rawValue | Status.R.rawValue)
        cpu.tick(count: 2)
    }

    // MARK: - Logical instructions

    /// bitwiseANDwithAccumulator
    func AND(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.A &= cpu.read(at: operand, from: &memory)
    }

    /// bitwiseExclusiveOR
    func EOR(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.A ^= cpu.read(at: operand, from: &memory)
    }

    /// bitwiseORwithAccumulator
    func ORA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.A |= cpu.read(at: operand, from: &memory)
    }

    /// testBits
    func BIT(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let value = cpu.read(at: operand, from: &memory)
        let data = cpu.A & value
        cpu.P.remove([.Z, .V, .N])
        if data == 0 { cpu.P.formUnion(.Z) } else { cpu.P.remove(.Z) }
        if value[6] == 1 { cpu.P.formUnion(.V) } else { cpu.P.remove(.V) }
        if value[7] == 1 { cpu.P.formUnion(.N) } else { cpu.P.remove(.N) }
    }

    // MARK: - Arithmetic instructions

    /// addWithCarry
    func ADC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let a = cpu.A
        let val = cpu.read(at: operand, from: &memory)
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
    func SBC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let a = cpu.A
        let val = ~cpu.read(at: operand, from: &memory)
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
    func CMP(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let cmp = Int16(cpu.A) &- Int16(cpu.read(at: operand, from: &memory))

        cpu.P.remove([.C, .Z, .N])
        cpu.P.setZN(cmp)
        if 0 <= cmp { cpu.P.formUnion(.C) } else { cpu.P.remove(.C) }

    }

    /// compareXRegister
    func CPX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let value = cpu.read(at: operand, from: &memory)
        let cmp = cpu.X &- value

        cpu.P.remove([.C, .Z, .N])
        cpu.P.setZN(cmp)
        if cpu.X >= value { cpu.P.formUnion(.C) } else { cpu.P.remove(.C) }

    }

    /// compareYRegister
    func CPY(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let value = cpu.read(at: operand, from: &memory)
        let cmp = cpu.Y &- value

        cpu.P.remove([.C, .Z, .N])
        cpu.P.setZN(cmp)
        if cpu.Y >= value { cpu.P.formUnion(.C) } else { cpu.P.remove(.C) }

    }

    // MARK: - Increment/Decrement instructions

    /// incrementMemory
    func INC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let result = cpu.read(at: operand, from: &memory) &+ 1

        cpu.P.setZN(result)
        cpu.write(result, at: operand, to: &memory)

        cpu.tick()

    }

    /// incrementX
    func INX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.X = cpu.X &+ 1
        cpu.tick()
    }

    /// incrementY
    func INY(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.Y = cpu.Y &+ 1
        cpu.tick()
    }

    /// decrementMemory
    func DEC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let result = cpu.read(at: operand, from: &memory) &- 1

        cpu.P.setZN(result)

        cpu.write(result, at: operand, to: &memory)

        cpu.tick()

    }

    /// decrementX
    func DEX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.X = cpu.X &- 1
        cpu.tick()
    }

    /// decrementY
    func DEY(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.Y = cpu.Y &- 1
        cpu.tick()
    }

    // MARK: - Shift instructions

    /// arithmeticShiftLeft
    func ASL(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        var data = cpu.read(at: operand, from: &memory)

        cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 { cpu.P.formUnion(.C) }

        data <<= 1

        cpu.P.setZN(data)

        cpu.write(data, at: operand, to: &memory)

        cpu.tick()
    }

    func ASLForAccumulator(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.remove([.C, .Z, .N])
        if cpu.A[7] == 1 { cpu.P.formUnion(.C) }

        cpu.A <<= 1

        cpu.tick()
    }

    /// logicalShiftRight
    func LSR(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        var data = cpu.read(at: operand, from: &memory)

        cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 { cpu.P.formUnion(.C) }

        data >>= 1

        cpu.P.setZN(data)

        cpu.write(data, at: operand, to: &memory)

        cpu.tick()
    }

    func LSRForAccumulator(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.remove([.C, .Z, .N])
        if cpu.A[0] == 1 { cpu.P.formUnion(.C) }

        cpu.A >>= 1

        cpu.tick()
    }

    /// rotateLeft
    func ROL(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        var data = cpu.read(at: operand, from: &memory)
        let c = data & 0x80

        data <<= 1
        if cpu.P.contains(.C) { data |= 0x01 }

        cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)

        cpu.write(data, at: operand, to: &memory)

        cpu.tick()
    }

    func ROLForAccumulator(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let c = cpu.A & 0x80

        var a = cpu.A << 1
        if cpu.P.contains(.C) { a |= 0x01 }

        cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { cpu.P.formUnion(.C) }

        cpu.A = a

        cpu.tick()
    }

    /// rotateRight
    func ROR(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        var data = cpu.read(at: operand, from: &memory)
        let c = data & 0x01

        data >>= 1
        if cpu.P.contains(.C) { data |= 0x80 }

        cpu.P.remove([.C, .Z, .N])
        if c == 1 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)

        cpu.write(data, at: operand, to: &memory)

        cpu.tick()
    }

    func RORForAccumulator(operand: Operand, cpu: inout CPU, memory: inout Memory) {
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
    func JMP(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.PC = operand
    }

    /// jumpToSubroutine
    func JSR(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        pushStack(word: cpu.PC &- 1, cpu: &cpu, memory: &memory)
        cpu.tick()
        cpu.PC = operand
    }

    /// returnFromSubroutine
    func RTS(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.tick(count: 3)
        cpu.PC = pullStack(cpu: &cpu, memory: &memory) &+ 1
    }

    /// returnFromInterrupt
    func RTI(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.tick(count: 2)
        cpu.P = Status(rawValue: pullStack(cpu: &cpu, memory: &memory) & ~Status.B.rawValue | Status.R.rawValue)
        cpu.PC = pullStack(cpu: &cpu, memory: &memory)
    }

    // MARK: - Branch instructions

    private func branch(operand: Operand, cpu: inout CPU, test: Bool) {
        if test {
            cpu.tick()
            let pc = Int(cpu.PC)
            let offset = Int(operand.i8)
            if CPU.pageCrossed(value: pc, operand: offset) {
                cpu.tick()
            }
            cpu.PC = UInt16(pc &+ offset)
        }
    }

    /// branchIfCarryClear
    func BCC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: !cpu.P.contains(.C))
    }

    /// branchIfCarrySet
    func BCS(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: cpu.P.contains(.C))
    }

    /// branchIfEqual
    func BEQ(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: cpu.P.contains(.Z))
    }

    /// branchIfMinus
    func BMI(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: cpu.P.contains(.N))
    }

    /// branchIfNotEqual
    func BNE(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: !cpu.P.contains(.Z))
    }

    /// branchIfPlus
    func BPL(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: !cpu.P.contains(.N))
    }

    /// branchIfOverflowClear
    func BVC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: !cpu.P.contains(.V))
    }

    /// branchIfOverflowSet
    func BVS(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        branch(operand: operand, cpu: &cpu, test: cpu.P.contains(.V))
    }

    // MARK: - Flag control instructions

    /// clearCarry
    func CLC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.remove(.C)
        cpu.tick()
    }

    /// clearDecimal
    func CLD(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.remove(.D)
        cpu.tick()
    }

    /// clearInterrupt
    func CLI(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.remove(.I)
        cpu.tick()
    }

    /// clearOverflow
    func CLV(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.remove(.V)
        cpu.tick()
    }

    /// setCarryFlag
    func SEC(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.formUnion(.C)
        cpu.tick()
    }

    /// setDecimalFlag
    func SED(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.formUnion(.D)
        cpu.tick()
    }

    /// setInterruptDisable
    func SEI(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.P.formUnion(.I)
        cpu.tick()
    }

    // MARK: - Misc

    /// forceInterrupt
    func BRK(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        pushStack(word: cpu.PC, cpu: &cpu, memory: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | Status.interruptedB.rawValue, cpu: &cpu, memory: &memory)
        cpu.tick()
        cpu.PC = cpu.readWord(at: 0xFFFE, from: &memory)
    }

    /// doNothing
    func NOP(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.tick()
    }

    // MARK: - Unofficial

    /// loadAccumulatorAndX
    func LAX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        let data = cpu.read(at: operand, from: &memory)
        cpu.A = data
        cpu.X = data
    }

    /// storeAccumulatorAndX
    func SAX(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        cpu.write(cpu.A & cpu.X, at: operand, to: &memory)
    }

    /// decrementMemoryAndCompareAccumulator
    func DCP(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // decrementMemory excluding tick
        let result = cpu.read(at: operand, from: &memory) &- 1
        cpu.P.setZN(result)
        cpu.write(result, at: operand, to: &memory)

        CMP(operand: operand, cpu: &cpu, memory: &memory)
    }

    /// incrementMemoryAndSubtractWithCarry
    func ISB(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // incrementMemory excluding tick
        let result = cpu.read(at: operand, from: &memory) &+ 1
        cpu.P.setZN(result)
        cpu.write(result, at: operand, to: &memory)

        SBC(operand: operand, cpu: &cpu, memory: &memory)
    }

    /// arithmeticShiftLeftAndBitwiseORwithAccumulator
    func SLO(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // arithmeticShiftLeft excluding tick
        var data = cpu.read(at: operand, from: &memory)
        cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 { cpu.P.formUnion(.C) }

        data <<= 1
        cpu.P.setZN(data)
        cpu.write(data, at: operand, to: &memory)

        ORA(operand: operand, cpu: &cpu, memory: &memory)
    }

    /// rotateLeftAndBitwiseANDwithAccumulator
    func RLA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // rotateLeft excluding tick
        var data = cpu.read(at: operand, from: &memory)
        let c = data & 0x80

        data <<= 1
        if cpu.P.contains(.C) { data |= 0x01 }

        cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)
        cpu.write(data, at: operand, to: &memory)

        AND(operand: operand, cpu: &cpu, memory: &memory)
    }

    /// logicalShiftRightAndBitwiseExclusiveOR
    func SRE(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // logicalShiftRight excluding tick
        var data = cpu.read(at: operand, from: &memory)
        cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 { cpu.P.formUnion(.C) }

        data >>= 1

        cpu.P.setZN(data)
        cpu.write(data, at: operand, to: &memory)

        EOR(operand: operand, cpu: &cpu, memory: &memory)
    }

    /// rotateRightAndAddWithCarry
    func RRA(operand: Operand, cpu: inout CPU, memory: inout Memory) {
        // rotateRight excluding tick
        var data = cpu.read(at: operand, from: &memory)
        let c = data & 0x01

        data >>= 1
        if cpu.P.contains(.C) { data |= 0x80 }

        cpu.P.remove([.C, .Z, .N])
        if c == 1 { cpu.P.formUnion(.C) }

        cpu.P.setZN(data)
        cpu.write(data, at: operand, to: &memory)

        ADC(operand: operand, cpu: &cpu, memory: &memory)
    }

// MARK: - Stack
func pushStack(_ value: UInt8, cpu: inout CPU, memory: inout Memory) {
    cpu.write(value, at: cpu.S.u16 &+ 0x100, to: &memory)
    cpu.S &-= 1
}

func pushStack(word: UInt16, cpu: inout CPU, memory: inout Memory) {
    pushStack(UInt8(word >> 8), cpu: &cpu, memory: &memory)
    pushStack(UInt8(word & 0xFF), cpu: &cpu, memory: &memory)
}

func pullStack(cpu: inout CPU, memory: inout Memory) -> UInt8 {
    cpu.S &+= 1
    return cpu.read(at: cpu.S.u16 &+ 0x100, from: &memory)
}

func pullStack(cpu: inout CPU, memory: inout Memory) -> UInt16 {
    let lo: UInt8 = pullStack(cpu: &cpu, memory: &memory)
    let ho: UInt8 = pullStack(cpu: &cpu, memory: &memory)
    return ho.u16 &<< 8 | lo.u16
}
