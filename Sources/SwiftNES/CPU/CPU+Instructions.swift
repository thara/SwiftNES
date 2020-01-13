// swiftlint:disable file_length cyclomatic_complexity function_body_length

extension CPU {

    @inline(__always)
    static func excuteInstruction(opcode: UInt8, cpu: CPU, memory: inout Memory) {
        switch opcode {
        case 0xA9:
            LDA(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA5:
            LDA(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB5:
            LDA(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xAD:
            LDA(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xBD:
            LDA(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB9:
            LDA(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA1:
            LDA(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB1:
            LDA(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA2:
            LDX(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA6:
            LDX(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB6:
            LDX(operand: .zeroPageY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xAE:
            LDX(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xBE:
            LDX(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA0:
            LDY(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA4:
            LDY(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB4:
            LDY(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xAC:
            LDY(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xBC:
            LDY(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x85:
            STA(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x95:
            STA(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x8D:
            STA(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x9D:
            STA(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x99:
            STA(operand: .absoluteY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x81:
            STA(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x91:
            STAWithTick(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x86:
            STX(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x96:
            STX(operand: .zeroPageY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x8E:
            STX(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x84:
            STY(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x94:
            STY(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x8C:
            STY(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xAA:
            TAX(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xBA:
            TSX(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA8:
            TAY(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x8A:
            TXA(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x9A:
            TXS(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x98:
            TYA(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x48:
            PHA(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x08:
            PHP(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x68:
            PLA(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x28:
            PLP(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x29:
            AND(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x25:
            AND(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x35:
            AND(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x2D:
            AND(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x3D:
            AND(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x39:
            AND(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x21:
            AND(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x31:
            AND(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x49:
            EOR(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x45:
            EOR(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x55:
            EOR(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x4D:
            EOR(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x5D:
            EOR(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x59:
            EOR(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x41:
            EOR(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x51:
            EOR(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x09:
            ORA(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x05:
            ORA(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x15:
            ORA(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x0D:
            ORA(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x1D:
            ORA(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x19:
            ORA(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x01:
            ORA(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x11:
            ORA(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x24:
            BIT(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x2C:
            BIT(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x69:
            ADC(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x65:
            ADC(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x75:
            ADC(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x6D:
            ADC(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x7D:
            ADC(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x79:
            ADC(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x61:
            ADC(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x71:
            ADC(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xE9:
            SBC(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xE5:
            SBC(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF5:
            SBC(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xED:
            SBC(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xFD:
            SBC(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF9:
            SBC(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xE1:
            SBC(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF1:
            SBC(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC9:
            CMP(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC5:
            CMP(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD5:
            CMP(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xCD:
            CMP(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xDD:
            CMP(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD9:
            CMP(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC1:
            CMP(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD1:
            CMP(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xE0:
            CPX(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xE4:
            CPX(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xEC:
            CPX(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC0:
            CPY(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC4:
            CPY(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xCC:
            CPY(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0xE6:
            INC(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF6:
            INC(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xEE:
            INC(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xFE:
            INC(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xE8:
            INX(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC8:
            INY(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC6:
            DEC(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD6:
            DEC(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xCE:
            DEC(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xDE:
            DEC(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xCA:
            DEX(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x88:
            DEY(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x0A:
            ASLForAccumulator(operand: .accumulator(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x06:
            ASL(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x16:
            ASL(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x0E:
            ASL(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x1E:
            ASL(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x4A:
            LSRForAccumulator(operand: .accumulator(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x46:
            LSR(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x56:
            LSR(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x4E:
            LSR(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x5E:
            LSR(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x2A:
            ROLForAccumulator(operand: .accumulator(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x26:
            ROL(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x36:
            ROL(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x2E:
            ROL(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x3E:
            ROL(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x6A:
            RORForAccumulator(operand: .accumulator(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x66:
            ROR(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x76:
            ROR(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x6E:
            ROR(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x7E:
            ROR(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x4C:
            JMP(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x6C:
            JMP(operand: .indirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x20:
            JSR(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x60:
            RTS(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x40:
            RTI(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x90:
            BCC(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB0:
            BCS(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF0:
            BEQ(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x30:
            BMI(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD0:
            BNE(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x10:
            BPL(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x50:
            BVC(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x70:
            BVS(operand: .relative(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x18:
            CLC(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD8:
            CLD(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x58:
            CLI(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB8:
            CLV(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x38:
            SEC(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF8:
            SED(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x78:
            SEI(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x00:
            BRK(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        // Undocumented

        case 0xEB:
            SBC(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x04, 0x44, 0x64:
            NOP(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x0C:
            NOP(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            NOP(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            NOP(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            NOP(operand: .absoluteXWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            NOP(operand: .immediate(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0xA3:
            LAX(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xA7:
            LAX(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xAF:
            LAX(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB3:
            LAX(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xB7:
            LAX(operand: .zeroPageY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xBF:
            LAX(operand: .absoluteYWithPenalty(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x83:
            SAX(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x87:
            SAX(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x8F:
            SAX(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x97:
            SAX(operand: .zeroPageY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0xC3:
            DCP(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xC7:
            DCP(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xCF:
            DCP(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD3:
            DCP(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xD7:
            DCP(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xDB:
            DCP(operand: .absoluteY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xDF:
            DCP(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0xE3:
            ISB(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xE7:
            ISB(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xEF:
            ISB(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF3:
            ISB(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xF7:
            ISB(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xFB:
            ISB(operand: .absoluteY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0xFF:
            ISB(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x03:
            SLO(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x07:
            SLO(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x0F:
            SLO(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x13:
            SLO(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x17:
            SLO(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x1B:
            SLO(operand: .absoluteY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x1F:
            SLO(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x23:
            RLA(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x27:
            RLA(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x2F:
            RLA(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x33:
            RLA(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x37:
            RLA(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x3B:
            RLA(operand: .absoluteY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x3F:
            RLA(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x43:
            SRE(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x47:
            SRE(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x4F:
            SRE(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x53:
            SRE(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x57:
            SRE(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x5B:
            SRE(operand: .absoluteY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x5F:
            SRE(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        case 0x63:
            RRA(operand: .indexedIndirect(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x67:
            RRA(operand: .zeroPage(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x6F:
            RRA(operand: .absolute(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x73:
            RRA(operand: .indirectIndexed(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x77:
            RRA(operand: .zeroPageX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x7B:
            RRA(operand: .absoluteY(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        case 0x7F:
            RRA(operand: .absoluteX(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)

        default:
            NOP(operand: .implicit(cpu: cpu, memory: &memory), registers: &cpu.registers, memory: &memory)
        }
    }
}

// MARK: - Addressing Mode
extension Operand {

    static func implicit(cpu: CPU, memory: inout Memory) -> UInt16 {
        return 0x00
    }

    static func accumulator(cpu: CPU, memory: inout Memory) -> UInt16 {
        return cpu.registers.A.u16
    }

    static func immediate(cpu: CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.registers.PC
        cpu.registers.PC &+= 1
        return operand
    }

    static func zeroPage(cpu: CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.registers.read(at: cpu.registers.PC, from: &memory).u16 & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static func zeroPageX(cpu: CPU, memory: inout Memory) -> UInt16 {
        cpu.registers.tick()

        let operand = (cpu.registers.read(at: cpu.registers.PC, from: &memory).u16 &+ cpu.registers.X.u16) & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static func zeroPageY(cpu: CPU, memory: inout Memory) -> UInt16 {
        cpu.registers.tick()

        let operand = (cpu.registers.read(at: cpu.registers.PC, from: &memory).u16 &+ cpu.registers.Y.u16) & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static func absolute(cpu: CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.registers.readWord(at: cpu.registers.PC, from: &memory)
        cpu.registers.PC &+= 2
        return operand
    }

    static func absoluteX(cpu: CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.registers.readWord(at: cpu.registers.PC, from: &memory)
        let operand = data &+ cpu.registers.X.u16 & 0xFFFF
        cpu.registers.PC &+= 2
        cpu.registers.tick()
        return operand
    }

    static func absoluteXWithPenalty(cpu: CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.registers.readWord(at: cpu.registers.PC, from: &memory)
        let operand = data &+ cpu.registers.X.u16 & 0xFFFF
        cpu.registers.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.registers.X) {
            cpu.registers.tick()
        }
        return operand
    }

    static func absoluteY(cpu: CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.registers.readWord(at: cpu.registers.PC, from: &memory)
        let operand = data &+ cpu.registers.Y.u16 & 0xFFFF
        cpu.registers.PC &+= 2
        cpu.registers.tick()
        return operand
    }

    static func absoluteYWithPenalty(cpu: CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.registers.readWord(at: cpu.registers.PC, from: &memory)
        let operand = data &+ cpu.registers.Y.u16 & 0xFFFF
        cpu.registers.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.registers.Y) {
            cpu.registers.tick()
        }
        return operand
    }

    static func relative(cpu: CPU, memory: inout Memory) -> UInt16 {
        let operand = cpu.registers.read(at: cpu.registers.PC, from: &memory).u16
        cpu.registers.PC &+= 1
        return operand
    }

    static func indirect(cpu: CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.registers.readWord(at: cpu.registers.PC, from: &memory)
        let operand = cpu.registers.readOnIndirect(operand: data, from: &memory)
        cpu.registers.PC &+= 2
        return operand
    }

    static func indexedIndirect(cpu: CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.registers.read(at: cpu.registers.PC, from: &memory)
        let operand = cpu.registers.readOnIndirect(operand: (data &+ cpu.registers.X).u16 & 0xFF, from: &memory)
        cpu.registers.PC &+= 1

        cpu.registers.tick()

        return operand
    }

    static func indirectIndexed(cpu: CPU, memory: inout Memory) -> UInt16 {
        let data = cpu.registers.read(at: cpu.registers.PC, from: &memory).u16
        let operand = cpu.registers.readOnIndirect(operand: data, from: &memory) &+ cpu.registers.Y.u16
        cpu.registers.PC &+= 1

        if CPU.pageCrossed(value: operand &- cpu.registers.Y.u16, operand: cpu.registers.Y) {
            cpu.registers.tick()
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
    func LDA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.A = registers.read(at: operand, from: &memory)
    }

    /// loadXRegister
    func LDX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.X = registers.read(at: operand, from: &memory)
    }

    /// loadYRegister
    func LDY(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.Y = registers.read(at: operand, from: &memory)
    }

    /// storeAccumulator
    func STA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.write(registers.A, at: operand, to: &memory)
    }

    func STAWithTick(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.write(registers.A, at: operand, to: &memory)
        registers.tick()
    }

    /// storeXRegister
    func STX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.write(registers.X, at: operand, to: &memory)
    }

    /// storeYRegister
    func STY(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.write(registers.Y, at: operand, to: &memory)
    }

    // MARK: - Register Operations

    /// transferAccumulatorToX
    func TAX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.X = registers.A
        registers.tick()
    }

    /// transferStackPointerToX
    func TSX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.X = registers.S
        registers.tick()
    }

    /// transferAccumulatorToY
    func TAY(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.Y = registers.A
        registers.tick()
    }

    /// transferXtoAccumulator
    func TXA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.A = registers.X
        registers.tick()
    }

    /// transferXtoStackPointer
    func TXS(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.S = registers.X
        registers.tick()
    }

    /// transferYtoAccumulator
    func TYA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.A = registers.Y
        registers.tick()
    }

    // MARK: - Stack instructions

    /// pushAccumulator
    func PHA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        pushStack(registers.A, registers: &registers, memory: &memory)
        registers.tick()
    }

    /// pushProcessorStatus
    func PHP(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.operatedB.rawValue, registers: &registers, memory: &memory)
        registers.tick()
    }

    /// pullAccumulator
    func PLA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.A = pullStack(registers: &registers, memory: &memory)
        registers.tick(count: 2)
    }

    /// pullProcessorStatus
    func PLP(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.P = Status(rawValue: pullStack(registers: &registers, memory: &memory) & ~Status.B.rawValue | Status.R.rawValue)
        registers.tick(count: 2)
    }

    // MARK: - Logical instructions

    /// bitwiseANDwithAccumulator
    func AND(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.A &= registers.read(at: operand, from: &memory)
    }

    /// bitwiseExclusiveOR
    func EOR(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.A ^= registers.read(at: operand, from: &memory)
    }

    /// bitwiseORwithAccumulator
    func ORA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.A |= registers.read(at: operand, from: &memory)
    }

    /// testBits
    func BIT(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let value = registers.read(at: operand, from: &memory)
        let data = registers.A & value
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) } else { registers.P.remove(.Z) }
        if value[6] == 1 { registers.P.formUnion(.V) } else { registers.P.remove(.V) }
        if value[7] == 1 { registers.P.formUnion(.N) } else { registers.P.remove(.N) }
    }

    // MARK: - Arithmetic instructions

    /// addWithCarry
    func ADC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let a = registers.A
        let val = registers.read(at: operand, from: &memory)
        var result = a &+ val

        if registers.P.contains(.C) { result &+= 1 }

        registers.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { registers.P.formUnion(.C) }
        if c6 ^ c7 == 1 { registers.P.formUnion(.V) }

        registers.A = result
    }

    /// subtractWithCarry
    func SBC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let a = registers.A
        let val = ~registers.read(at: operand, from: &memory)
        var result = a &+ val

        if registers.P.contains(.C) { result &+= 1 }

        registers.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { registers.P.formUnion(.C) }
        if c6 ^ c7 == 1 { registers.P.formUnion(.V) }

        registers.A = result
    }

    /// compareAccumulator
    func CMP(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let cmp = Int16(registers.A) &- Int16(registers.read(at: operand, from: &memory))

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if 0 <= cmp { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

    }

    /// compareXRegister
    func CPX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let value = registers.read(at: operand, from: &memory)
        let cmp = registers.X &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.X >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

    }

    /// compareYRegister
    func CPY(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let value = registers.read(at: operand, from: &memory)
        let cmp = registers.Y &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.Y >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

    }

    // MARK: - Increment/Decrement instructions

    /// incrementMemory
    func INC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let result = registers.read(at: operand, from: &memory) &+ 1

        registers.P.setZN(result)
        registers.write(result, at: operand, to: &memory)

        registers.tick()

    }

    /// incrementX
    func INX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.X = registers.X &+ 1
        registers.tick()
    }

    /// incrementY
    func INY(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.Y = registers.Y &+ 1
        registers.tick()
    }

    /// decrementMemory
    func DEC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let result = registers.read(at: operand, from: &memory) &- 1

        registers.P.setZN(result)

        registers.write(result, at: operand, to: &memory)

        registers.tick()

    }

    /// decrementX
    func DEX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.X = registers.X &- 1
        registers.tick()
    }

    /// decrementY
    func DEY(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.Y = registers.Y &- 1
        registers.tick()
    }

    // MARK: - Shift instructions

    /// arithmeticShiftLeft
    func ASL(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        var data = registers.read(at: operand, from: &memory)

        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1

        registers.P.setZN(data)

        registers.write(data, at: operand, to: &memory)

        registers.tick()
    }

    func ASLForAccumulator(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.remove([.C, .Z, .N])
        if registers.A[7] == 1 { registers.P.formUnion(.C) }

        registers.A <<= 1

        registers.tick()
    }

    /// logicalShiftRight
    func LSR(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        var data = registers.read(at: operand, from: &memory)

        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)

        registers.write(data, at: operand, to: &memory)

        registers.tick()
    }

    func LSRForAccumulator(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.remove([.C, .Z, .N])
        if registers.A[0] == 1 { registers.P.formUnion(.C) }

        registers.A >>= 1

        registers.tick()
    }

    /// rotateLeft
    func ROL(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        var data = registers.read(at: operand, from: &memory)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        registers.write(data, at: operand, to: &memory)

        registers.tick()
    }

    func ROLForAccumulator(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let c = registers.A & 0x80

        var a = registers.A << 1
        if registers.P.contains(.C) { a |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.A = a

        registers.tick()
    }

    /// rotateRight
    func ROR(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        var data = registers.read(at: operand, from: &memory)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        registers.write(data, at: operand, to: &memory)

        registers.tick()
    }

    func RORForAccumulator(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let c = registers.A & 0x01

        var a = registers.A >> 1
        if registers.P.contains(.C) { a |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a

        registers.tick()
    }

    // MARK: - Jump instructions

    /// jump
    func JMP(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.PC = operand
    }

    /// jumpToSubroutine
    func JSR(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        pushStack(word: registers.PC &- 1, registers: &registers, memory: &memory)
        registers.tick()
        registers.PC = operand
    }

    /// returnFromSubroutine
    func RTS(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.tick(count: 3)
        registers.PC = pullStack(registers: &registers, memory: &memory) &+ 1
    }

    /// returnFromInterrupt
    func RTI(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.tick(count: 2)
        registers.P = Status(rawValue: pullStack(registers: &registers, memory: &memory) & ~Status.B.rawValue | Status.R.rawValue)
        registers.PC = pullStack(registers: &registers, memory: &memory)
    }

    // MARK: - Branch instructions

    private func branch(operand: Operand, registers: inout CPURegisters, test: Bool) {
        if test {
            registers.tick()
            let pc = Int(registers.PC)
            let offset = Int(operand.i8)
            if CPU.pageCrossed(value: pc, operand: offset) {
                registers.tick()
            }
            registers.PC = UInt16(pc &+ offset)
        }
    }

    /// branchIfCarryClear
    func BCC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: !registers.P.contains(.C))
    }

    /// branchIfCarrySet
    func BCS(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: registers.P.contains(.C))
    }

    /// branchIfEqual
    func BEQ(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: registers.P.contains(.Z))
    }

    /// branchIfMinus
    func BMI(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: registers.P.contains(.N))
    }

    /// branchIfNotEqual
    func BNE(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: !registers.P.contains(.Z))
    }

    /// branchIfPlus
    func BPL(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: !registers.P.contains(.N))
    }

    /// branchIfOverflowClear
    func BVC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: !registers.P.contains(.V))
    }

    /// branchIfOverflowSet
    func BVS(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        branch(operand: operand, registers: &registers, test: registers.P.contains(.V))
    }

    // MARK: - Flag control instructions

    /// clearCarry
    func CLC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.remove(.C)
        registers.tick()
    }

    /// clearDecimal
    func CLD(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.remove(.D)
        registers.tick()
    }

    /// clearInterrupt
    func CLI(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.remove(.I)
        registers.tick()
    }

    /// clearOverflow
    func CLV(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.remove(.V)
        registers.tick()
    }

    /// setCarryFlag
    func SEC(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.formUnion(.C)
        registers.tick()
    }

    /// setDecimalFlag
    func SED(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.formUnion(.D)
        registers.tick()
    }

    /// setInterruptDisable
    func SEI(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.P.formUnion(.I)
        registers.tick()
    }

    // MARK: - Misc

    /// forceInterrupt
    func BRK(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        pushStack(word: registers.PC, registers: &registers, memory: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue, registers: &registers, memory: &memory)
        registers.tick()
        registers.PC = registers.readWord(at: 0xFFFE, from: &memory)
    }

    /// doNothing
    func NOP(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.tick()
    }

    // MARK: - Unofficial

    /// loadAccumulatorAndX
    func LAX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        let data = registers.read(at: operand, from: &memory)
        registers.A = data
        registers.X = data
    }

    /// storeAccumulatorAndX
    func SAX(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        registers.write(registers.A & registers.X, at: operand, to: &memory)
    }

    /// decrementMemoryAndCompareAccumulator
    func DCP(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // decrementMemory excluding tick
        let result = registers.read(at: operand, from: &memory) &- 1
        registers.P.setZN(result)
        registers.write(result, at: operand, to: &memory)

        CMP(operand: operand, registers: &registers, memory: &memory)
    }

    /// incrementMemoryAndSubtractWithCarry
    func ISB(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // incrementMemory excluding tick
        let result = registers.read(at: operand, from: &memory) &+ 1
        registers.P.setZN(result)
        registers.write(result, at: operand, to: &memory)

        SBC(operand: operand, registers: &registers, memory: &memory)
    }

    /// arithmeticShiftLeftAndBitwiseORwithAccumulator
    func SLO(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // arithmeticShiftLeft excluding tick
        var data = registers.read(at: operand, from: &memory)
        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1
        registers.P.setZN(data)
        registers.write(data, at: operand, to: &memory)

        ORA(operand: operand, registers: &registers, memory: &memory)
    }

    /// rotateLeftAndBitwiseANDwithAccumulator
    func RLA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // rotateLeft excluding tick
        var data = registers.read(at: operand, from: &memory)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)
        registers.write(data, at: operand, to: &memory)

        AND(operand: operand, registers: &registers, memory: &memory)
    }

    /// logicalShiftRightAndBitwiseExclusiveOR
    func SRE(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // logicalShiftRight excluding tick
        var data = registers.read(at: operand, from: &memory)
        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)
        registers.write(data, at: operand, to: &memory)

        EOR(operand: operand, registers: &registers, memory: &memory)
    }

    /// rotateRightAndAddWithCarry
    func RRA(operand: Operand, registers: inout CPURegisters, memory: inout Memory) {
        // rotateRight excluding tick
        var data = registers.read(at: operand, from: &memory)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)
        registers.write(data, at: operand, to: &memory)

        ADC(operand: operand, registers: &registers, memory: &memory)
    }

// MARK: - Stack
func pushStack(_ value: UInt8, registers: inout CPURegisters, memory: inout Memory) {
    registers.write(value, at: registers.S.u16 &+ 0x100, to: &memory)
    registers.S &-= 1
}

func pushStack(word: UInt16, registers: inout CPURegisters, memory: inout Memory) {
    pushStack(UInt8(word >> 8), registers: &registers, memory: &memory)
    pushStack(UInt8(word & 0xFF), registers: &registers, memory: &memory)
}

func pullStack(registers: inout CPURegisters, memory: inout Memory) -> UInt8 {
    registers.S &+= 1
    return registers.read(at: registers.S.u16 &+ 0x100, from: &memory)
}

func pullStack(registers: inout CPURegisters, memory: inout Memory) -> UInt16 {
    let lo: UInt8 = pullStack(registers: &registers, memory: &memory)
    let ho: UInt8 = pullStack(registers: &registers, memory: &memory)
    return ho.u16 &<< 8 | lo.u16
}
