enum Mnemonic {
    // Load/Store Operations
    case LDA, LDX, LDY, STA, STX, STY
    // Register Operations
    case TAX, TSX, TAY, TXA, TXS, TYA
    // Stack instructions
    case PHA, PHP, PLA, PLP
    // Logical instructions
    case AND, EOR, ORA, BIT
    // Arithmetic instructions
    case ADC, SBC, CMP, CPX, CPY
    // Increment/Decrement instructions
    case INC, INX, INY, DEC, DEX, DEY
    // Shift instructions
    case ASL, LSR, ROL, ROR
    // Jump instructions
    case JMP, JSR, RTS, RTI
    // Branch instructions
    case BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS
    // Flag control instructions
    case CLC, CLD, CLI, CLV, SEC, SED, SEI
    // Misc
    case BRK, NOP
    // Unofficial
    case LAX, SAX, DCP, ISB, SLO, RLA, SRE, RRA
}

// swiftlint:disable file_length cyclomatic_complexity function_body_length
func decode(opcode: OpCode) -> CPUInstruction {
    switch opcode {
    case 0xA9:
        return .init(mnemonic: .LDA, addressingMode: .immediate)
    case 0xA5:
        return .init(mnemonic: .LDA, addressingMode: .zeroPage)
    case 0xB5:
        return .init(mnemonic: .LDA, addressingMode: .zeroPageX)
    case 0xAD:
        return .init(mnemonic: .LDA, addressingMode: .absolute)
    case 0xBD:
        return .init(mnemonic: .LDA, addressingMode: .absoluteX(penalty: true))
    case 0xB9:
        return .init(mnemonic: .LDA, addressingMode: .absoluteY(penalty: true))
    case 0xA1:
        return .init(mnemonic: .LDA, addressingMode: .indexedIndirect)
    case 0xB1:
        return .init(mnemonic: .LDA, addressingMode: .indirectIndexed)
    case 0xA2:
        return .init(mnemonic: .LDX, addressingMode: .immediate)
    case 0xA6:
        return .init(mnemonic: .LDX, addressingMode: .zeroPage)
    case 0xB6:
        return .init(mnemonic: .LDX, addressingMode: .zeroPageY)
    case 0xAE:
        return .init(mnemonic: .LDX, addressingMode: .absolute)
    case 0xBE:
        return .init(mnemonic: .LDX, addressingMode: .absoluteY(penalty: true))
    case 0xA0:
        return .init(mnemonic: .LDY, addressingMode: .immediate)
    case 0xA4:
        return .init(mnemonic: .LDY, addressingMode: .zeroPage)
    case 0xB4:
        return .init(mnemonic: .LDY, addressingMode: .zeroPageX)
    case 0xAC:
        return .init(mnemonic: .LDY, addressingMode: .absolute)
    case 0xBC:
        return .init(mnemonic: .LDY, addressingMode: .absoluteX(penalty: true))
    case 0x85:
        return .init(mnemonic: .STA, addressingMode: .zeroPage)
    case 0x95:
        return .init(mnemonic: .STA, addressingMode: .zeroPageX)
    case 0x8D:
        return .init(mnemonic: .STA, addressingMode: .absolute)
    case 0x9D:
        return .init(mnemonic: .STA, addressingMode: .absoluteX(penalty: false))
    case 0x99:
        return .init(mnemonic: .STA, addressingMode: .absoluteY(penalty: false))
    case 0x81:
        return .init(mnemonic: .STA, addressingMode: .indexedIndirect)
    case 0x91:
        return .init(mnemonic: .STA, addressingMode: .indirectIndexed)
    case 0x86:
        return .init(mnemonic: .STX, addressingMode: .zeroPage)
    case 0x96:
        return .init(mnemonic: .STX, addressingMode: .zeroPageY)
    case 0x8E:
        return .init(mnemonic: .STX, addressingMode: .absolute)
    case 0x84:
        return .init(mnemonic: .STY, addressingMode: .zeroPage)
    case 0x94:
        return .init(mnemonic: .STY, addressingMode: .zeroPageX)
    case 0x8C:
        return .init(mnemonic: .STY, addressingMode: .absolute)
    case 0xAA:
        return .init(mnemonic: .TAX, addressingMode: .implicit)
    case 0xBA:
        return .init(mnemonic: .TSX, addressingMode: .implicit)
    case 0xA8:
        return .init(mnemonic: .TAY, addressingMode: .implicit)
    case 0x8A:
        return .init(mnemonic: .TXA, addressingMode: .implicit)
    case 0x9A:
        return .init(mnemonic: .TXS, addressingMode: .implicit)
    case 0x98:
        return .init(mnemonic: .TYA, addressingMode: .implicit)

    case 0x48:
        return .init(mnemonic: .PHA, addressingMode: .implicit)
    case 0x08:
        return .init(mnemonic: .PHP, addressingMode: .implicit)
    case 0x68:
        return .init(mnemonic: .PLA, addressingMode: .implicit)
    case 0x28:
        return .init(mnemonic: .PLP, addressingMode: .implicit)

    case 0x29:
        return .init(mnemonic: .AND, addressingMode: .immediate)
    case 0x25:
        return .init(mnemonic: .AND, addressingMode: .zeroPage)
    case 0x35:
        return .init(mnemonic: .AND, addressingMode: .zeroPageX)
    case 0x2D:
        return .init(mnemonic: .AND, addressingMode: .absolute)
    case 0x3D:
        return .init(mnemonic: .AND, addressingMode: .absoluteX(penalty: true))
    case 0x39:
        return .init(mnemonic: .AND, addressingMode: .absoluteY(penalty: true))
    case 0x21:
        return .init(mnemonic: .AND, addressingMode: .indexedIndirect)
    case 0x31:
        return .init(mnemonic: .AND, addressingMode: .indirectIndexed)
    case 0x49:
        return .init(mnemonic: .EOR, addressingMode: .immediate)
    case 0x45:
        return .init(mnemonic: .EOR, addressingMode: .zeroPage)
    case 0x55:
        return .init(mnemonic: .EOR, addressingMode: .zeroPageX)
    case 0x4D:
        return .init(mnemonic: .EOR, addressingMode: .absolute)
    case 0x5D:
        return .init(mnemonic: .EOR, addressingMode: .absoluteX(penalty: true))
    case 0x59:
        return .init(mnemonic: .EOR, addressingMode: .absoluteY(penalty: true))
    case 0x41:
        return .init(mnemonic: .EOR, addressingMode: .indexedIndirect)
    case 0x51:
        return .init(mnemonic: .EOR, addressingMode: .indirectIndexed)
    case 0x09:
        return .init(mnemonic: .ORA, addressingMode: .immediate)
    case 0x05:
        return .init(mnemonic: .ORA, addressingMode: .zeroPage)
    case 0x15:
        return .init(mnemonic: .ORA, addressingMode: .zeroPageX)
    case 0x0D:
        return .init(mnemonic: .ORA, addressingMode: .absolute)
    case 0x1D:
        return .init(mnemonic: .ORA, addressingMode: .absoluteX(penalty: true))
    case 0x19:
        return .init(mnemonic: .ORA, addressingMode: .absoluteY(penalty: true))
    case 0x01:
        return .init(mnemonic: .ORA, addressingMode: .indexedIndirect)
    case 0x11:
        return .init(mnemonic: .ORA, addressingMode: .indirectIndexed)
    case 0x24:
        return .init(mnemonic: .BIT, addressingMode: .zeroPage)
    case 0x2C:
        return .init(mnemonic: .BIT, addressingMode: .absolute)

    case 0x69:
        return .init(mnemonic: .ADC, addressingMode: .immediate)
    case 0x65:
        return .init(mnemonic: .ADC, addressingMode: .zeroPage)
    case 0x75:
        return .init(mnemonic: .ADC, addressingMode: .zeroPageX)
    case 0x6D:
        return .init(mnemonic: .ADC, addressingMode: .absolute)
    case 0x7D:
        return .init(mnemonic: .ADC, addressingMode: .absoluteX(penalty: true))
    case 0x79:
        return .init(mnemonic: .ADC, addressingMode: .absoluteY(penalty: true))
    case 0x61:
        return .init(mnemonic: .ADC, addressingMode: .indexedIndirect)
    case 0x71:
        return .init(mnemonic: .ADC, addressingMode: .indirectIndexed)
    case 0xE9:
        return .init(mnemonic: .SBC, addressingMode: .immediate)
    case 0xE5:
        return .init(mnemonic: .SBC, addressingMode: .zeroPage)
    case 0xF5:
        return .init(mnemonic: .SBC, addressingMode: .zeroPageX)
    case 0xED:
        return .init(mnemonic: .SBC, addressingMode: .absolute)
    case 0xFD:
        return .init(mnemonic: .SBC, addressingMode: .absoluteX(penalty: true))
    case 0xF9:
        return .init(mnemonic: .SBC, addressingMode: .absoluteY(penalty: true))
    case 0xE1:
        return .init(mnemonic: .SBC, addressingMode: .indexedIndirect)
    case 0xF1:
        return .init(mnemonic: .SBC, addressingMode: .indirectIndexed)
    case 0xC9:
        return .init(mnemonic: .CMP, addressingMode: .immediate)
    case 0xC5:
        return .init(mnemonic: .CMP, addressingMode: .zeroPage)
    case 0xD5:
        return .init(mnemonic: .CMP, addressingMode: .zeroPageX)
    case 0xCD:
        return .init(mnemonic: .CMP, addressingMode: .absolute)
    case 0xDD:
        return .init(mnemonic: .CMP, addressingMode: .absoluteX(penalty: true))
    case 0xD9:
        return .init(mnemonic: .CMP, addressingMode: .absoluteY(penalty: true))
    case 0xC1:
        return .init(mnemonic: .CMP, addressingMode: .indexedIndirect)
    case 0xD1:
        return .init(mnemonic: .CMP, addressingMode: .indirectIndexed)
    case 0xE0:
        return .init(mnemonic: .CPX, addressingMode: .immediate)
    case 0xE4:
        return .init(mnemonic: .CPX, addressingMode: .zeroPage)
    case 0xEC:
        return .init(mnemonic: .CPX, addressingMode: .absolute)
    case 0xC0:
        return .init(mnemonic: .CPY, addressingMode: .immediate)
    case 0xC4:
        return .init(mnemonic: .CPY, addressingMode: .zeroPage)
    case 0xCC:
        return .init(mnemonic: .CPY, addressingMode: .absolute)

    case 0xE6:
        return .init(mnemonic: .INC, addressingMode: .zeroPage)
    case 0xF6:
        return .init(mnemonic: .INC, addressingMode: .zeroPageX)
    case 0xEE:
        return .init(mnemonic: .INC, addressingMode: .absolute)
    case 0xFE:
        return .init(mnemonic: .INC, addressingMode: .absoluteX(penalty: false))
    case 0xE8:
        return .init(mnemonic: .INX, addressingMode: .implicit)
    case 0xC8:
        return .init(mnemonic: .INY, addressingMode: .implicit)
    case 0xC6:
        return .init(mnemonic: .DEC, addressingMode: .zeroPage)
    case 0xD6:
        return .init(mnemonic: .DEC, addressingMode: .zeroPageX)
    case 0xCE:
        return .init(mnemonic: .DEC, addressingMode: .absolute)
    case 0xDE:
        return .init(mnemonic: .DEC, addressingMode: .absoluteX(penalty: false))
    case 0xCA:
        return .init(mnemonic: .DEX, addressingMode: .implicit)
    case 0x88:
        return .init(mnemonic: .DEY, addressingMode: .implicit)

    case 0x0A:
        return .init(mnemonic: .ASL, addressingMode: .accumulator)
    case 0x06:
        return .init(mnemonic: .ASL, addressingMode: .zeroPage)
    case 0x16:
        return .init(mnemonic: .ASL, addressingMode: .zeroPageX)
    case 0x0E:
        return .init(mnemonic: .ASL, addressingMode: .absolute)
    case 0x1E:
        return .init(mnemonic: .ASL, addressingMode: .absoluteX(penalty: false))
    case 0x4A:
        return .init(mnemonic: .LSR, addressingMode: .accumulator)
    case 0x46:
        return .init(mnemonic: .LSR, addressingMode: .zeroPage)
    case 0x56:
        return .init(mnemonic: .LSR, addressingMode: .zeroPageX)
    case 0x4E:
        return .init(mnemonic: .LSR, addressingMode: .absolute)
    case 0x5E:
        return .init(mnemonic: .LSR, addressingMode: .absoluteX(penalty: false))
    case 0x2A:
        return .init(mnemonic: .ROL, addressingMode: .accumulator)
    case 0x26:
        return .init(mnemonic: .ROL, addressingMode: .zeroPage)
    case 0x36:
        return .init(mnemonic: .ROL, addressingMode: .zeroPageX)
    case 0x2E:
        return .init(mnemonic: .ROL, addressingMode: .absolute)
    case 0x3E:
        return .init(mnemonic: .ROL, addressingMode: .absoluteX(penalty: false))
    case 0x6A:
        return .init(mnemonic: .ROR, addressingMode: .accumulator)
    case 0x66:
        return .init(mnemonic: .ROR, addressingMode: .zeroPage)
    case 0x76:
        return .init(mnemonic: .ROR, addressingMode: .zeroPageX)
    case 0x6E:
        return .init(mnemonic: .ROR, addressingMode: .absolute)
    case 0x7E:
        return .init(mnemonic: .ROR, addressingMode: .absoluteX(penalty: false))

    case 0x4C:
        return .init(mnemonic: .JMP, addressingMode: .absolute)
    case 0x6C:
        return .init(mnemonic: .JMP, addressingMode: .indirect)
    case 0x20:
        return .init(mnemonic: .JSR, addressingMode: .absolute)
    case 0x60:
        return .init(mnemonic: .RTS, addressingMode: .implicit)
    case 0x40:
        return .init(mnemonic: .RTI, addressingMode: .implicit)

    case 0x90:
        return .init(mnemonic: .BCC, addressingMode: .relative)
    case 0xB0:
        return .init(mnemonic: .BCS, addressingMode: .relative)
    case 0xF0:
        return .init(mnemonic: .BEQ, addressingMode: .relative)
    case 0x30:
        return .init(mnemonic: .BMI, addressingMode: .relative)
    case 0xD0:
        return .init(mnemonic: .BNE, addressingMode: .relative)
    case 0x10:
        return .init(mnemonic: .BPL, addressingMode: .relative)
    case 0x50:
        return .init(mnemonic: .BVC, addressingMode: .relative)
    case 0x70:
        return .init(mnemonic: .BVS, addressingMode: .relative)

    case 0x18:
        return .init(mnemonic: .CLC, addressingMode: .implicit)
    case 0xD8:
        return .init(mnemonic: .CLD, addressingMode: .implicit)
    case 0x58:
        return .init(mnemonic: .CLI, addressingMode: .implicit)
    case 0xB8:
        return .init(mnemonic: .CLV, addressingMode: .implicit)

    case 0x38:
        return .init(mnemonic: .SEC, addressingMode: .implicit)
    case 0xF8:
        return .init(mnemonic: .SED, addressingMode: .implicit)
    case 0x78:
        return .init(mnemonic: .SEI, addressingMode: .implicit)

    case 0x00:
        return .init(mnemonic: .BRK, addressingMode: .implicit)

    // Undocumented
    case 0xEB:
        return .init(mnemonic: .SBC, addressingMode: .immediate)

    case 0x04, 0x44, 0x64:
        return .init(mnemonic: .NOP, addressingMode: .zeroPage)
    case 0x0C:
        return .init(mnemonic: .NOP, addressingMode: .absolute)
    case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
        return .init(mnemonic: .NOP, addressingMode: .zeroPageX)
    case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
        return .init(mnemonic: .NOP, addressingMode: .implicit)
    case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
        return .init(mnemonic: .NOP, addressingMode: .absoluteX(penalty: true))
    case 0x80, 0x82, 0x89, 0xC2, 0xE2:
        return .init(mnemonic: .NOP, addressingMode: .immediate)

    case 0xA3:
        return .init(mnemonic: .LAX, addressingMode: .indexedIndirect)
    case 0xA7:
        return .init(mnemonic: .LAX, addressingMode: .zeroPage)
    case 0xAF:
        return .init(mnemonic: .LAX, addressingMode: .absolute)
    case 0xB3:
        return .init(mnemonic: .LAX, addressingMode: .indirectIndexed)
    case 0xB7:
        return .init(mnemonic: .LAX, addressingMode: .zeroPageY)
    case 0xBF:
        return .init(mnemonic: .LAX, addressingMode: .absoluteY(penalty: true))

    case 0x83:
        return .init(mnemonic: .SAX, addressingMode: .indexedIndirect)
    case 0x87:
        return .init(mnemonic: .SAX, addressingMode: .zeroPage)
    case 0x8F:
        return .init(mnemonic: .SAX, addressingMode: .absolute)
    case 0x97:
        return .init(mnemonic: .SAX, addressingMode: .zeroPageY)

    case 0xC3:
        return .init(mnemonic: .DCP, addressingMode: .indexedIndirect)
    case 0xC7:
        return .init(mnemonic: .DCP, addressingMode: .zeroPage)
    case 0xCF:
        return .init(mnemonic: .DCP, addressingMode: .absolute)
    case 0xD3:
        return .init(mnemonic: .DCP, addressingMode: .indirectIndexed)
    case 0xD7:
        return .init(mnemonic: .DCP, addressingMode: .zeroPageX)
    case 0xDB:
        return .init(mnemonic: .DCP, addressingMode: .absoluteY(penalty: false))
    case 0xDF:
        return .init(mnemonic: .DCP, addressingMode: .absoluteX(penalty: false))

    case 0xE3:
        return .init(mnemonic: .ISB, addressingMode: .indexedIndirect)
    case 0xE7:
        return .init(mnemonic: .ISB, addressingMode: .zeroPage)
    case 0xEF:
        return .init(mnemonic: .ISB, addressingMode: .absolute)
    case 0xF3:
        return .init(mnemonic: .ISB, addressingMode: .indirectIndexed)
    case 0xF7:
        return .init(mnemonic: .ISB, addressingMode: .zeroPageX)
    case 0xFB:
        return .init(mnemonic: .ISB, addressingMode: .absoluteY(penalty: false))
    case 0xFF:
        return .init(mnemonic: .ISB, addressingMode: .absoluteX(penalty: false))

    case 0x03:
        return .init(mnemonic: .SLO, addressingMode: .indexedIndirect)
    case 0x07:
        return .init(mnemonic: .SLO, addressingMode: .zeroPage)
    case 0x0F:
        return .init(mnemonic: .SLO, addressingMode: .absolute)
    case 0x13:
        return .init(mnemonic: .SLO, addressingMode: .indirectIndexed)
    case 0x17:
        return .init(mnemonic: .SLO, addressingMode: .zeroPageX)
    case 0x1B:
        return .init(mnemonic: .SLO, addressingMode: .absoluteY(penalty: false))
    case 0x1F:
        return .init(mnemonic: .SLO, addressingMode: .absoluteX(penalty: false))

    case 0x23:
        return .init(mnemonic: .RLA, addressingMode: .indexedIndirect)
    case 0x27:
        return .init(mnemonic: .RLA, addressingMode: .zeroPage)
    case 0x2F:
        return .init(mnemonic: .RLA, addressingMode: .absolute)
    case 0x33:
        return .init(mnemonic: .RLA, addressingMode: .indirectIndexed)
    case 0x37:
        return .init(mnemonic: .RLA, addressingMode: .zeroPageX)
    case 0x3B:
        return .init(mnemonic: .RLA, addressingMode: .absoluteY(penalty: false))
    case 0x3F:
        return .init(mnemonic: .RLA, addressingMode: .absoluteX(penalty: false))

    case 0x43:
        return .init(mnemonic: .SRE, addressingMode: .indexedIndirect)
    case 0x47:
        return .init(mnemonic: .SRE, addressingMode: .zeroPage)
    case 0x4F:
        return .init(mnemonic: .SRE, addressingMode: .absolute)
    case 0x53:
        return .init(mnemonic: .SRE, addressingMode: .indirectIndexed)
    case 0x57:
        return .init(mnemonic: .SRE, addressingMode: .zeroPageX)
    case 0x5B:
        return .init(mnemonic: .SRE, addressingMode: .absoluteY(penalty: false))
    case 0x5F:
        return .init(mnemonic: .SRE, addressingMode: .absoluteX(penalty: false))

    case 0x63:
        return .init(mnemonic: .RRA, addressingMode: .indexedIndirect)
    case 0x67:
        return .init(mnemonic: .RRA, addressingMode: .zeroPage)
    case 0x6F:
        return .init(mnemonic: .RRA, addressingMode: .absolute)
    case 0x73:
        return .init(mnemonic: .RRA, addressingMode: .indirectIndexed)
    case 0x77:
        return .init(mnemonic: .RRA, addressingMode: .zeroPageX)
    case 0x7B:
        return .init(mnemonic: .RRA, addressingMode: .absoluteY(penalty: false))
    case 0x7F:
        return .init(mnemonic: .RRA, addressingMode: .absoluteX(penalty: false))

    default:
        return .init(mnemonic: .NOP, addressingMode: .implicit)
    }
}

struct CPUInstruction {
    var mnemonic: Mnemonic
    var addressingMode: AddressingMode

    func execute(cpu: inout CPU) {
        let operand = addressingMode.getOperand(from: &cpu)

        switch (self.mnemonic, self.addressingMode) {
        case (.LDA, _): LDA(cpu: &cpu, operand: operand)
        case (.LDX, _): LDX(cpu: &cpu, operand: operand)
        case (.LDY, _): LDY(cpu: &cpu, operand: operand)
        case (.STA, .indirectIndexed):
            STA(cpu: &cpu, operand: operand)
            cpu.tick()
        case (.STA, _): STA(cpu: &cpu, operand: operand)
        case (.STX, _): STX(cpu: &cpu, operand: operand)
        case (.STY, _): STY(cpu: &cpu, operand: operand)
        case (.TAX, _): TAX(cpu: &cpu)
        case (.TSX, _): TSX(cpu: &cpu)
        case (.TAY, _): TAY(cpu: &cpu)
        case (.TXA, _): TXA(cpu: &cpu)
        case (.TXS, _): TXS(cpu: &cpu)
        case (.TYA, _): TYA(cpu: &cpu)
        case (.PHA, _): PHA(cpu: &cpu)
        case (.PHP, _): PHP(cpu: &cpu)
        case (.PLA, _): PLA(cpu: &cpu)
        case (.PLP, _): PLP(cpu: &cpu)
        case (.AND, _): AND(cpu: &cpu, operand: operand)
        case (.EOR, _): EOR(cpu: &cpu, operand: operand)
        case (.ORA, _): ORA(cpu: &cpu, operand: operand)
        case (.BIT, _): BIT(cpu: &cpu, operand: operand)
        case (.ADC, _): ADC(cpu: &cpu, operand: operand)
        case (.SBC, _): SBC(cpu: &cpu, operand: operand)
        case (.CMP, _): CMP(cpu: &cpu, operand: operand)
        case (.CPX, _): CPX(cpu: &cpu, operand: operand)
        case (.CPY, _): CPY(cpu: &cpu, operand: operand)
        case (.INC, _): INC(cpu: &cpu, operand: operand)
        case (.INX, _): INX(cpu: &cpu)
        case (.INY, _): INY(cpu: &cpu)
        case (.DEC, _): DEC(cpu: &cpu, operand: operand)
        case (.DEX, _): DEX(cpu: &cpu)
        case (.DEY, _): DEY(cpu: &cpu)
        case (.ASL, .accumulator): ASLForAccumulator(cpu: &cpu)
        case (.ASL, _): ASL(cpu: &cpu, operand: operand)
        case (.LSR, .accumulator): LSRForAccumulator(cpu: &cpu)
        case (.LSR, _): LSR(cpu: &cpu, operand: operand)
        case (.ROL, .accumulator): ROLForAccumulator(cpu: &cpu)
        case (.ROL, _): ROL(cpu: &cpu, operand: operand)
        case (.ROR, .accumulator): RORForAccumulator(cpu: &cpu)
        case (.ROR, _): ROR(cpu: &cpu, operand: operand)
        case (.JMP, _): JMP(cpu: &cpu, operand: operand)
        case (.JSR, _): JSR(cpu: &cpu, operand: operand)
        case (.RTS, _): RTS(cpu: &cpu)
        case (.RTI, _): RTI(cpu: &cpu)
        case (.BCC, _): BCC(cpu: &cpu, operand: operand)
        case (.BCS, _): BCS(cpu: &cpu, operand: operand)
        case (.BEQ, _): BEQ(cpu: &cpu, operand: operand)
        case (.BMI, _): BMI(cpu: &cpu, operand: operand)
        case (.BNE, _): BNE(cpu: &cpu, operand: operand)
        case (.BPL, _): BPL(cpu: &cpu, operand: operand)
        case (.BVC, _): BVC(cpu: &cpu, operand: operand)
        case (.BVS, _): BVS(cpu: &cpu, operand: operand)
        case (.CLC, _): CLC(cpu: &cpu)
        case (.CLD, _): CLD(cpu: &cpu)
        case (.CLI, _): CLI(cpu: &cpu)
        case (.CLV, _): CLV(cpu: &cpu)
        case (.SEC, _): SEC(cpu: &cpu)
        case (.SED, _): SED(cpu: &cpu)
        case (.SEI, _): SEI(cpu: &cpu)
        case (.BRK, _): BRK(cpu: &cpu)
        case (.NOP, _): NOP(cpu: &cpu)
        case (.LAX, _): LAX(cpu: &cpu, operand: operand)
        case (.SAX, _): SAX(cpu: &cpu, operand: operand)
        case (.DCP, _): DCP(cpu: &cpu, operand: operand)
        case (.ISB, _): ISB(cpu: &cpu, operand: operand)
        case (.SLO, _): SLO(cpu: &cpu, operand: operand)
        case (.RLA, _): RLA(cpu: &cpu, operand: operand)
        case (.SRE, _): SRE(cpu: &cpu, operand: operand)
        case (.RRA, _): RRA(cpu: &cpu, operand: operand)
        }
    }
}

// MARK: - Operations

// Implements for Load/Store Operations

/// loadAccumulator
func LDA(cpu: inout CPU, operand: Operand) {
    cpu.A = cpu.read(at: operand)
}

/// loadXRegister
func LDX(cpu: inout CPU, operand: Operand) {
    cpu.X = cpu.read(at: operand)
}

/// loadYRegister
func LDY(cpu: inout CPU, operand: Operand) {
    cpu.Y = cpu.read(at: operand)
}

/// storeAccumulator
func STA(cpu: inout CPU, operand: Operand) {
    cpu.write(cpu.A, at: operand)
}

func STAWithTick(cpu: inout CPU, operand: Operand) {
    cpu.write(cpu.A, at: operand)
    cpu.tick()
}

/// storeXRegister
func STX(cpu: inout CPU, operand: Operand) {
    cpu.write(cpu.X, at: operand)
}

/// storeYRegister
func STY(cpu: inout CPU, operand: Operand) {
    cpu.write(cpu.Y, at: operand)
}

// MARK: - cpu Operations
/// transferAccumulatorToX
func TAX(cpu: inout CPU) {
    cpu.X = cpu.A
    cpu.tick()
}

/// transferStackPointerToX
func TSX(cpu: inout CPU) {
    cpu.X = cpu.S
    cpu.tick()
}

/// transferAccumulatorToY
func TAY(cpu: inout CPU) {
    cpu.Y = cpu.A
    cpu.tick()
}

/// transferXtoAccumulator
func TXA(cpu: inout CPU) {
    cpu.A = cpu.X
    cpu.tick()
}

/// transferXtoStackPointer
func TXS(cpu: inout CPU) {
    cpu.S = cpu.X
    cpu.tick()
}

/// transferYtoAccumulator
func TYA(cpu: inout CPU) {
    cpu.A = cpu.Y
    cpu.tick()
}

// MARK: - Stack instructions
/// pushAccumulator
func PHA(cpu: inout CPU) {
    cpu.pushStack(cpu.A)
    cpu.tick()
}

/// pushProcessorStatus
func PHP(cpu: inout CPU) {
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    cpu.pushStack(cpu.P.rawValue | CPU.Status.operatedB.rawValue)
    cpu.tick()
}

/// pullAccumulator
func PLA(cpu: inout CPU) {
    cpu.A = cpu.pullStack()
    cpu.tick(count: 2)
}

/// pullProcessorStatus
func PLP(cpu: inout CPU) {
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    cpu.P = CPU.Status(rawValue: cpu.pullStack() & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
    cpu.tick(count: 2)
}

// MARK: - Logical instructions
/// bitwiseANDwithAccumulator
func AND(cpu: inout CPU, operand: Operand) {
    cpu.A &= cpu.read(at: operand)
}

func executeAND(operand: Operand, cpu: inout CPU) {
    cpu.A &= cpu.read(at: operand)
}

/// bitwiseExclusiveOR
func EOR(cpu: inout CPU, operand: Operand) {
    executeEOR(operand: operand, cpu: &cpu)
}

func executeEOR(operand: Operand, cpu: inout CPU) {
    cpu.A ^= cpu.read(at: operand)
}

/// bitwiseORwithAccumulator
func ORA(cpu: inout CPU, operand: Operand) {
    executeORA(operand: operand, cpu: &cpu)
}

func executeORA(operand: Operand, cpu: inout CPU) {
    cpu.A |= cpu.read(at: operand)
}

/// testBits
func BIT(cpu: inout CPU, operand: Operand) {

    let value = cpu.read(at: operand)
    let data = cpu.A & value
    cpu.P.remove([.Z, .V, .N])
    if data == 0 {
        cpu.P.formUnion(.Z)
    } else {
        cpu.P.remove(.Z)
    }
    if value[6] == 1 {
        cpu.P.formUnion(.V)
    } else {
        cpu.P.remove(.V)
    }
    if value[7] == 1 {
        cpu.P.formUnion(.N)
    } else {
        cpu.P.remove(.N)
    }
}

// MARK: - Arithmetic instructions
/// addWithCarry
func ADC(cpu: inout CPU, operand: Operand) {
    executeAOR(operand: operand, cpu: &cpu)
}

func executeAOR(operand: Operand, cpu: inout CPU) {
    let a = cpu.A
    let val = cpu.read(at: operand)
    var result = a &+ val

    if cpu.P.contains(.C) {
        result &+= 1
    }

    cpu.P.remove([.C, .Z, .V, .N])

    // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    let a7 = a[7]
    let v7 = val[7]
    let c6 = a7 ^ v7 ^ result[7]
    let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

    if c7 == 1 {
        cpu.P.formUnion(.C)
    }
    if c6 ^ c7 == 1 {
        cpu.P.formUnion(.V)
    }

    cpu.A = result
}

/// subtractWithCarry
func SBC(cpu: inout CPU, operand: Operand) {

    let a = cpu.A
    let val = ~cpu.read(at: operand)
    var result = a &+ val

    if cpu.P.contains(.C) {
        result &+= 1
    }

    cpu.P.remove([.C, .Z, .V, .N])

    // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    let a7 = a[7]
    let v7 = val[7]
    let c6 = a7 ^ v7 ^ result[7]
    let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

    if c7 == 1 {
        cpu.P.formUnion(.C)
    }
    if c6 ^ c7 == 1 {
        cpu.P.formUnion(.V)
    }

    cpu.A = result
}

func executeSBC(operand: Operand, cpu: inout CPU) {
    let a = cpu.A
    let val = ~cpu.read(at: operand)
    var result = a &+ val

    if cpu.P.contains(.C) {
        result &+= 1
    }

    cpu.P.remove([.C, .Z, .V, .N])

    // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    let a7 = a[7]
    let v7 = val[7]
    let c6 = a7 ^ v7 ^ result[7]
    let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

    if c7 == 1 {
        cpu.P.formUnion(.C)
    }
    if c6 ^ c7 == 1 {
        cpu.P.formUnion(.V)
    }

    cpu.A = result
}

/// compareAccumulator
func CMP(cpu: inout CPU, operand: Operand) {

    executeCMP(operand: operand, cpu: &cpu)
}

func executeCMP(operand: Operand, cpu: inout CPU) {
    let cmp = Int16(cpu.A) &- Int16(cpu.read(at: operand))

    cpu.P.remove([.C, .Z, .N])
    cpu.P.setZN(cmp)
    if 0 <= cmp {
        cpu.P.formUnion(.C)
    } else {
        cpu.P.remove(.C)
    }
}

/// compareXRegister
func CPX(cpu: inout CPU, operand: Operand) {

    let value = cpu.read(at: operand)
    let cmp = cpu.X &- value

    cpu.P.remove([.C, .Z, .N])
    cpu.P.setZN(cmp)
    if cpu.X >= value {
        cpu.P.formUnion(.C)
    } else {
        cpu.P.remove(.C)
    }
}

/// compareYRegister
func CPY(cpu: inout CPU, operand: Operand) {

    let value = cpu.read(at: operand)
    let cmp = cpu.Y &- value

    cpu.P.remove([.C, .Z, .N])
    cpu.P.setZN(cmp)
    if cpu.Y >= value {
        cpu.P.formUnion(.C)
    } else {
        cpu.P.remove(.C)
    }
}

// MARK: - Increment/Decrement instructions
/// incrementMemory
func INC(cpu: inout CPU, operand: Operand) {

    let result = cpu.read(at: operand) &+ 1

    cpu.P.setZN(result)
    cpu.write(result, at: operand)

    cpu.tick()
}

/// incrementX
func INX(cpu: inout CPU) {
    cpu.X = cpu.X &+ 1
    cpu.tick()
}

/// incrementY
func INY(cpu: inout CPU) {
    cpu.Y = cpu.Y &+ 1
    cpu.tick()
}

/// decrementMemory
func DEC(cpu: inout CPU, operand: Operand) {

    let result = cpu.read(at: operand) &- 1
    cpu.P.setZN(result)

    cpu.write(result, at: operand)
    cpu.tick()
}

/// decrementX
func DEX(cpu: inout CPU) {
    cpu.X = cpu.X &- 1
    cpu.tick()
}

/// decrementY
func DEY(cpu: inout CPU) {
    cpu.Y = cpu.Y &- 1
    cpu.tick()
}

// MARK: - Shift instructions
/// arithmeticShiftLeft
func ASL(cpu: inout CPU, operand: Operand) {

    var data = cpu.read(at: operand)

    cpu.P.remove([.C, .Z, .N])
    if data[7] == 1 {
        cpu.P.formUnion(.C)
    }

    data <<= 1

    cpu.P.setZN(data)

    cpu.write(data, at: operand)

    cpu.tick()
}

func ASLForAccumulator(cpu: inout CPU) {
    cpu.P.remove([.C, .Z, .N])
    if cpu.A[7] == 1 {
        cpu.P.formUnion(.C)
    }

    cpu.A <<= 1

    cpu.tick()
}

/// logicalShiftRight
func LSR(cpu: inout CPU, operand: Operand) {

    var data = cpu.read(at: operand)

    cpu.P.remove([.C, .Z, .N])
    if data[0] == 1 {
        cpu.P.formUnion(.C)
    }

    data >>= 1

    cpu.P.setZN(data)

    cpu.write(data, at: operand)

    cpu.tick()
}

func LSRForAccumulator(cpu: inout CPU) {
    cpu.P.remove([.C, .Z, .N])
    if cpu.A[0] == 1 {
        cpu.P.formUnion(.C)
    }

    cpu.A >>= 1

    cpu.tick()
}

/// rotateLeft
func ROL(cpu: inout CPU, operand: Operand) {

    var data = cpu.read(at: operand)
    let c = data & 0x80

    data <<= 1
    if cpu.P.contains(.C) {
        data |= 0x01
    }

    cpu.P.remove([.C, .Z, .N])
    if c == 0x80 {
        cpu.P.formUnion(.C)
    }

    cpu.P.setZN(data)

    cpu.write(data, at: operand)

    cpu.tick()
}

func ROLForAccumulator(cpu: inout CPU) {
    let c = cpu.A & 0x80

    var a = cpu.A << 1
    if cpu.P.contains(.C) {
        a |= 0x01
    }

    cpu.P.remove([.C, .Z, .N])
    if c == 0x80 {
        cpu.P.formUnion(.C)
    }

    cpu.A = a

    cpu.tick()
}

/// rotateRight
func ROR(cpu: inout CPU, operand: Operand) {

    var data = cpu.read(at: operand)
    let c = data & 0x01

    data >>= 1
    if cpu.P.contains(.C) {
        data |= 0x80
    }

    cpu.P.remove([.C, .Z, .N])
    if c == 1 {
        cpu.P.formUnion(.C)
    }

    cpu.P.setZN(data)

    cpu.write(data, at: operand)

    cpu.tick()
}

func RORForAccumulator(cpu: inout CPU) {
    let c = cpu.A & 0x01

    var a = cpu.A >> 1
    if cpu.P.contains(.C) {
        a |= 0x80
    }

    cpu.P.remove([.C, .Z, .N])
    if c == 1 {
        cpu.P.formUnion(.C)
    }

    cpu.A = a

    cpu.tick()
}

// MARK: - Jump instructions
/// jump
func JMP(cpu: inout CPU, operand: Operand) {

    cpu.PC = operand
}

/// jumpToSubroutine
func JSR(cpu: inout CPU, operand: Operand) {

    cpu.pushStack(word: cpu.PC &- 1)
    cpu.tick()
    cpu.PC = operand
}

/// returnFromSubroutine
func RTS(cpu: inout CPU) {
    cpu.tick(count: 3)
    cpu.PC = cpu.pullStack() &+ 1
}

/// returnFromInterrupt
func RTI(cpu: inout CPU) {
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    cpu.tick(count: 2)
    cpu.P = CPU.Status(rawValue: cpu.pullStack() & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
    cpu.PC = cpu.pullStack()
}

// MARK: - Branch instructions
/// branchIfCarryClear
func BCC(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: !cpu.P.contains(.C), cpu: &cpu)
}

/// branchIfCarrySet
func BCS(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: cpu.P.contains(.C), cpu: &cpu)
}

/// branchIfEqual
func BEQ(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: cpu.P.contains(.Z), cpu: &cpu)
}

/// branchIfMinus
func BMI(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: cpu.P.contains(.N), cpu: &cpu)
}

/// branchIfNotEqual
func BNE(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: !cpu.P.contains(.Z), cpu: &cpu)
}

/// branchIfPlus
func BPL(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: !cpu.P.contains(.N), cpu: &cpu)
}

/// branchIfOverflowClear
func BVC(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: !cpu.P.contains(.V), cpu: &cpu)
}

/// branchIfOverflowSet
func BVS(cpu: inout CPU, operand: Operand) {

    branch(operand: operand, test: cpu.P.contains(.V), cpu: &cpu)
}

// MARK: - Flag control instructions
/// clearCarry
func CLC(cpu: inout CPU) {
    cpu.P.remove(.C)
    cpu.tick()
}

/// clearDecimal
func CLD(cpu: inout CPU) {
    cpu.P.remove(.D)
    cpu.tick()
}

/// clearInterrupt
func CLI(cpu: inout CPU) {
    cpu.P.remove(.I)
    cpu.tick()
}

/// clearOverflow
func CLV(cpu: inout CPU) {
    cpu.P.remove(.V)
    cpu.tick()
}

/// setCarryFlag
func SEC(cpu: inout CPU) {
    cpu.P.formUnion(.C)
    cpu.tick()
}

/// setDecimalFlag
func SED(cpu: inout CPU) {
    cpu.P.formUnion(.D)
    cpu.tick()
}

/// setInterruptDisable
func SEI(cpu: inout CPU) {
    cpu.P.formUnion(.I)
    cpu.tick()
}

// MARK: - Misc
/// forceInterrupt
func BRK(cpu: inout CPU) {
    cpu.pushStack(word: cpu.PC)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    cpu.pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
    cpu.tick()
    cpu.PC = cpu.readWord(at: 0xFFFE)
}

/// doNothing
func NOP(cpu: inout CPU) {
    cpu.tick()
}

// MARK: - Unofficial
/// loadAccumulatorAndX
func LAX(cpu: inout CPU, operand: Operand) {

    let data = cpu.read(at: operand)
    cpu.A = data
    cpu.X = data
}

/// storeAccumulatorAndX
func SAX(cpu: inout CPU, operand: Operand) {

    cpu.write(cpu.A & cpu.X, at: operand)
}

/// decrementMemoryAndCompareAccumulator
func DCP(cpu: inout CPU, operand: Operand) {

    // decrementMemory excluding tick
    let result = cpu.read(at: operand) &- 1
    cpu.P.setZN(result)
    cpu.write(result, at: operand)

    executeCMP(operand: operand, cpu: &cpu)
}

/// incrementMemoryAndSubtractWithCarry
func ISB(cpu: inout CPU, operand: Operand) {

    // incrementMemory excluding tick
    let result = cpu.read(at: operand) &+ 1
    cpu.P.setZN(result)
    cpu.write(result, at: operand)

    executeSBC(operand: operand, cpu: &cpu)
}

/// arithmeticShiftLeftAndBitwiseORwithAccumulator
func SLO(cpu: inout CPU, operand: Operand) {

    // arithmeticShiftLeft excluding tick
    var data = cpu.read(at: operand)
    cpu.P.remove([.C, .Z, .N])
    if data[7] == 1 {
        cpu.P.formUnion(.C)
    }

    data <<= 1
    cpu.P.setZN(data)
    cpu.write(data, at: operand)

    executeORA(operand: operand, cpu: &cpu)
}

/// rotateLeftAndBitwiseANDwithAccumulator
func RLA(cpu: inout CPU, operand: Operand) {

    // rotateLeft excluding tick
    var data = cpu.read(at: operand)
    let c = data & 0x80

    data <<= 1
    if cpu.P.contains(.C) {
        data |= 0x01
    }

    cpu.P.remove([.C, .Z, .N])
    if c == 0x80 {
        cpu.P.formUnion(.C)
    }

    cpu.P.setZN(data)
    cpu.write(data, at: operand)

    executeAND(operand: operand, cpu: &cpu)
}

/// logicalShiftRightAndBitwiseExclusiveOR
func SRE(cpu: inout CPU, operand: Operand) {

    // logicalShiftRight excluding tick
    var data = cpu.read(at: operand)
    cpu.P.remove([.C, .Z, .N])
    if data[0] == 1 {
        cpu.P.formUnion(.C)
    }

    data >>= 1

    cpu.P.setZN(data)
    cpu.write(data, at: operand)

    executeEOR(operand: operand, cpu: &cpu)
}

/// rotateRightAndAddWithCarry
func RRA(cpu: inout CPU, operand: Operand) {

    // rotateRight excluding tick
    var data = cpu.read(at: operand)
    let c = data & 0x01

    data >>= 1
    if cpu.P.contains(.C) {
        data |= 0x80
    }

    cpu.P.remove([.C, .Z, .N])
    if c == 1 {
        cpu.P.formUnion(.C)
    }

    cpu.P.setZN(data)
    cpu.write(data, at: operand)

    executeAOR(operand: operand, cpu: &cpu)
}

func branch(operand: Operand, test: Bool, cpu: inout CPU) {
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
