// swiftlint:disable file_length cyclomatic_complexity function_body_length

@inline(__always)
func fetchOpCode(from nes: inout NES) -> OpCode {
    let opcode = readCPU(at: nes.cpu.PC, from: &nes)
    nes.cpu.PC &+= 1
    return opcode
}

@inline(__always)
func excuteInstruction(opcode: UInt8, on nes: inout NES) {
    switch opcode {
    case 0xA9:
        LDA(immediate(from: &nes), on: &nes)
    case 0xA5:
        LDA(zeroPage(from: &nes), on: &nes)
    case 0xB5:
        LDA(zeroPageX(from: &nes), on: &nes)
    case 0xAD:
        LDA(absolute(from: &nes), on: &nes)
    case 0xBD:
        LDA(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0xB9:
        LDA(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0xA1:
        LDA(indexedIndirect(from: &nes), on: &nes)
    case 0xB1:
        LDA(indirectIndexed(from: &nes), on: &nes)
    case 0xA2:
        LDX(immediate(from: &nes), on: &nes)
    case 0xA6:
        LDX(zeroPage(from: &nes), on: &nes)
    case 0xB6:
        LDX(zeroPageY(from: &nes), on: &nes)
    case 0xAE:
        LDX(absolute(from: &nes), on: &nes)
    case 0xBE:
        LDX(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0xA0:
        LDY(immediate(from: &nes), on: &nes)
    case 0xA4:
        LDY(zeroPage(from: &nes), on: &nes)
    case 0xB4:
        LDY(zeroPageX(from: &nes), on: &nes)
    case 0xAC:
        LDY(absolute(from: &nes), on: &nes)
    case 0xBC:
        LDY(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0x85:
        STA(zeroPage(from: &nes), on: &nes)
    case 0x95:
        STA(zeroPageX(from: &nes), on: &nes)
    case 0x8D:
        STA(absolute(from: &nes), on: &nes)
    case 0x9D:
        STA(absoluteX(from: &nes), on: &nes)
    case 0x99:
        STA(absoluteY(from: &nes), on: &nes)
    case 0x81:
        STA(indexedIndirect(from: &nes), on: &nes)
    case 0x91:
        STAWithTick(indirectIndexed(from: &nes), on: &nes)
    case 0x86:
        STX(zeroPage(from: &nes), on: &nes)
    case 0x96:
        STX(zeroPageY(from: &nes), on: &nes)
    case 0x8E:
        STX(absolute(from: &nes), on: &nes)
    case 0x84:
        STY(zeroPage(from: &nes), on: &nes)
    case 0x94:
        STY(zeroPageX(from: &nes), on: &nes)
    case 0x8C:
        STY(absolute(from: &nes), on: &nes)
    case 0xAA:
        TAX(implicit(from: &nes), on: &nes)
    case 0xBA:
        TSX(implicit(from: &nes), on: &nes)
    case 0xA8:
        TAY(implicit(from: &nes), on: &nes)
    case 0x8A:
        TXA(implicit(from: &nes), on: &nes)
    case 0x9A:
        TXS(implicit(from: &nes), on: &nes)
    case 0x98:
        TYA(implicit(from: &nes), on: &nes)

    case 0x48:
        PHA(implicit(from: &nes), on: &nes)
    case 0x08:
        PHP(implicit(from: &nes), on: &nes)
    case 0x68:
        PLA(implicit(from: &nes), on: &nes)
    case 0x28:
        PLP(implicit(from: &nes), on: &nes)

    case 0x29:
        AND(immediate(from: &nes), on: &nes)
    case 0x25:
        AND(zeroPage(from: &nes), on: &nes)
    case 0x35:
        AND(zeroPageX(from: &nes), on: &nes)
    case 0x2D:
        AND(absolute(from: &nes), on: &nes)
    case 0x3D:
        AND(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0x39:
        AND(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0x21:
        AND(indexedIndirect(from: &nes), on: &nes)
    case 0x31:
        AND(indirectIndexed(from: &nes), on: &nes)
    case 0x49:
        EOR(immediate(from: &nes), on: &nes)
    case 0x45:
        EOR(zeroPage(from: &nes), on: &nes)
    case 0x55:
        EOR(zeroPageX(from: &nes), on: &nes)
    case 0x4D:
        EOR(absolute(from: &nes), on: &nes)
    case 0x5D:
        EOR(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0x59:
        EOR(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0x41:
        EOR(indexedIndirect(from: &nes), on: &nes)
    case 0x51:
        EOR(indirectIndexed(from: &nes), on: &nes)
    case 0x09:
        ORA(immediate(from: &nes), on: &nes)
    case 0x05:
        ORA(zeroPage(from: &nes), on: &nes)
    case 0x15:
        ORA(zeroPageX(from: &nes), on: &nes)
    case 0x0D:
        ORA(absolute(from: &nes), on: &nes)
    case 0x1D:
        ORA(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0x19:
        ORA(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0x01:
        ORA(indexedIndirect(from: &nes), on: &nes)
    case 0x11:
        ORA(indirectIndexed(from: &nes), on: &nes)
    case 0x24:
        BIT(zeroPage(from: &nes), on: &nes)
    case 0x2C:
        BIT(absolute(from: &nes), on: &nes)

    case 0x69:
        ADC(immediate(from: &nes), on: &nes)
    case 0x65:
        ADC(zeroPage(from: &nes), on: &nes)
    case 0x75:
        ADC(zeroPageX(from: &nes), on: &nes)
    case 0x6D:
        ADC(absolute(from: &nes), on: &nes)
    case 0x7D:
        ADC(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0x79:
        ADC(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0x61:
        ADC(indexedIndirect(from: &nes), on: &nes)
    case 0x71:
        ADC(indirectIndexed(from: &nes), on: &nes)
    case 0xE9:
        SBC(immediate(from: &nes), on: &nes)
    case 0xE5:
        SBC(zeroPage(from: &nes), on: &nes)
    case 0xF5:
        SBC(zeroPageX(from: &nes), on: &nes)
    case 0xED:
        SBC(absolute(from: &nes), on: &nes)
    case 0xFD:
        SBC(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0xF9:
        SBC(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0xE1:
        SBC(indexedIndirect(from: &nes), on: &nes)
    case 0xF1:
        SBC(indirectIndexed(from: &nes), on: &nes)
    case 0xC9:
        CMP(immediate(from: &nes), on: &nes)
    case 0xC5:
        CMP(zeroPage(from: &nes), on: &nes)
    case 0xD5:
        CMP(zeroPageX(from: &nes), on: &nes)
    case 0xCD:
        CMP(absolute(from: &nes), on: &nes)
    case 0xDD:
        CMP(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0xD9:
        CMP(absoluteYWithPenalty(from: &nes), on: &nes)
    case 0xC1:
        CMP(indexedIndirect(from: &nes), on: &nes)
    case 0xD1:
        CMP(indirectIndexed(from: &nes), on: &nes)
    case 0xE0:
        CPX(immediate(from: &nes), on: &nes)
    case 0xE4:
        CPX(zeroPage(from: &nes), on: &nes)
    case 0xEC:
        CPX(absolute(from: &nes), on: &nes)
    case 0xC0:
        CPY(immediate(from: &nes), on: &nes)
    case 0xC4:
        CPY(zeroPage(from: &nes), on: &nes)
    case 0xCC:
        CPY(absolute(from: &nes), on: &nes)

    case 0xE6:
        INC(zeroPage(from: &nes), on: &nes)
    case 0xF6:
        INC(zeroPageX(from: &nes), on: &nes)
    case 0xEE:
        INC(absolute(from: &nes), on: &nes)
    case 0xFE:
        INC(absoluteX(from: &nes), on: &nes)
    case 0xE8:
        INX(implicit(from: &nes), on: &nes)
    case 0xC8:
        INY(implicit(from: &nes), on: &nes)
    case 0xC6:
        DEC(zeroPage(from: &nes), on: &nes)
    case 0xD6:
        DEC(zeroPageX(from: &nes), on: &nes)
    case 0xCE:
        DEC(absolute(from: &nes), on: &nes)
    case 0xDE:
        DEC(absoluteX(from: &nes), on: &nes)
    case 0xCA:
        DEX(implicit(from: &nes), on: &nes)
    case 0x88:
        DEY(implicit(from: &nes), on: &nes)

    case 0x0A:
        ASLForAccumulator(accumulator(from: &nes), on: &nes)
    case 0x06:
        ASL(zeroPage(from: &nes), on: &nes)
    case 0x16:
        ASL(zeroPageX(from: &nes), on: &nes)
    case 0x0E:
        ASL(absolute(from: &nes), on: &nes)
    case 0x1E:
        ASL(absoluteX(from: &nes), on: &nes)
    case 0x4A:
        LSRForAccumulator(accumulator(from: &nes), on: &nes)
    case 0x46:
        LSR(zeroPage(from: &nes), on: &nes)
    case 0x56:
        LSR(zeroPageX(from: &nes), on: &nes)
    case 0x4E:
        LSR(absolute(from: &nes), on: &nes)
    case 0x5E:
        LSR(absoluteX(from: &nes), on: &nes)
    case 0x2A:
        ROLForAccumulator(accumulator(from: &nes), on: &nes)
    case 0x26:
        ROL(zeroPage(from: &nes), on: &nes)
    case 0x36:
        ROL(zeroPageX(from: &nes), on: &nes)
    case 0x2E:
        ROL(absolute(from: &nes), on: &nes)
    case 0x3E:
        ROL(absoluteX(from: &nes), on: &nes)
    case 0x6A:
        RORForAccumulator(accumulator(from: &nes), on: &nes)
    case 0x66:
        ROR(zeroPage(from: &nes), on: &nes)
    case 0x76:
        ROR(zeroPageX(from: &nes), on: &nes)
    case 0x6E:
        ROR(absolute(from: &nes), on: &nes)
    case 0x7E:
        ROR(absoluteX(from: &nes), on: &nes)

    case 0x4C:
        JMP(absolute(from: &nes), on: &nes)
    case 0x6C:
        JMP(indirect(from: &nes), on: &nes)
    case 0x20:
        JSR(absolute(from: &nes), on: &nes)
    case 0x60:
        RTS(implicit(from: &nes), on: &nes)
    case 0x40:
        RTI(implicit(from: &nes), on: &nes)

    case 0x90:
        BCC(relative(from: &nes), on: &nes)
    case 0xB0:
        BCS(relative(from: &nes), on: &nes)
    case 0xF0:
        BEQ(relative(from: &nes), on: &nes)
    case 0x30:
        BMI(relative(from: &nes), on: &nes)
    case 0xD0:
        BNE(relative(from: &nes), on: &nes)
    case 0x10:
        BPL(relative(from: &nes), on: &nes)
    case 0x50:
        BVC(relative(from: &nes), on: &nes)
    case 0x70:
        BVS(relative(from: &nes), on: &nes)

    case 0x18:
        CLC(implicit(from: &nes), on: &nes)
    case 0xD8:
        CLD(implicit(from: &nes), on: &nes)
    case 0x58:
        CLI(implicit(from: &nes), on: &nes)
    case 0xB8:
        CLV(implicit(from: &nes), on: &nes)

    case 0x38:
        SEC(implicit(from: &nes), on: &nes)
    case 0xF8:
        SED(implicit(from: &nes), on: &nes)
    case 0x78:
        SEI(implicit(from: &nes), on: &nes)

    case 0x00:
        BRK(implicit(from: &nes), on: &nes)

    // Undocumented

    case 0xEB:
        SBC(immediate(from: &nes), on: &nes)

    case 0x04, 0x44, 0x64:
        NOP(zeroPage(from: &nes), on: &nes)
    case 0x0C:
        NOP(absolute(from: &nes), on: &nes)
    case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
        NOP(zeroPageX(from: &nes), on: &nes)
    case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
        NOP(implicit(from: &nes), on: &nes)
    case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
        NOP(absoluteXWithPenalty(from: &nes), on: &nes)
    case 0x80, 0x82, 0x89, 0xC2, 0xE2:
        NOP(immediate(from: &nes), on: &nes)

    case 0xA3:
        LAX(indexedIndirect(from: &nes), on: &nes)
    case 0xA7:
        LAX(zeroPage(from: &nes), on: &nes)
    case 0xAF:
        LAX(absolute(from: &nes), on: &nes)
    case 0xB3:
        LAX(indirectIndexed(from: &nes), on: &nes)
    case 0xB7:
        LAX(zeroPageY(from: &nes), on: &nes)
    case 0xBF:
        LAX(absoluteYWithPenalty(from: &nes), on: &nes)

    case 0x83:
        SAX(indexedIndirect(from: &nes), on: &nes)
    case 0x87:
        SAX(zeroPage(from: &nes), on: &nes)
    case 0x8F:
        SAX(absolute(from: &nes), on: &nes)
    case 0x97:
        SAX(zeroPageY(from: &nes), on: &nes)

    case 0xC3:
        DCP(indexedIndirect(from: &nes), on: &nes)
    case 0xC7:
        DCP(zeroPage(from: &nes), on: &nes)
    case 0xCF:
        DCP(absolute(from: &nes), on: &nes)
    case 0xD3:
        DCP(indirectIndexed(from: &nes), on: &nes)
    case 0xD7:
        DCP(zeroPageX(from: &nes), on: &nes)
    case 0xDB:
        DCP(absoluteY(from: &nes), on: &nes)
    case 0xDF:
        DCP(absoluteX(from: &nes), on: &nes)

    case 0xE3:
        ISB(indexedIndirect(from: &nes), on: &nes)
    case 0xE7:
        ISB(zeroPage(from: &nes), on: &nes)
    case 0xEF:
        ISB(absolute(from: &nes), on: &nes)
    case 0xF3:
        ISB(indirectIndexed(from: &nes), on: &nes)
    case 0xF7:
        ISB(zeroPageX(from: &nes), on: &nes)
    case 0xFB:
        ISB(absoluteY(from: &nes), on: &nes)
    case 0xFF:
        ISB(absoluteX(from: &nes), on: &nes)

    case 0x03:
        SLO(indexedIndirect(from: &nes), on: &nes)
    case 0x07:
        SLO(zeroPage(from: &nes), on: &nes)
    case 0x0F:
        SLO(absolute(from: &nes), on: &nes)
    case 0x13:
        SLO(indirectIndexed(from: &nes), on: &nes)
    case 0x17:
        SLO(zeroPageX(from: &nes), on: &nes)
    case 0x1B:
        SLO(absoluteY(from: &nes), on: &nes)
    case 0x1F:
        SLO(absoluteX(from: &nes), on: &nes)

    case 0x23:
        RLA(indexedIndirect(from: &nes), on: &nes)
    case 0x27:
        RLA(zeroPage(from: &nes), on: &nes)
    case 0x2F:
        RLA(absolute(from: &nes), on: &nes)
    case 0x33:
        RLA(indirectIndexed(from: &nes), on: &nes)
    case 0x37:
        RLA(zeroPageX(from: &nes), on: &nes)
    case 0x3B:
        RLA(absoluteY(from: &nes), on: &nes)
    case 0x3F:
        RLA(absoluteX(from: &nes), on: &nes)

    case 0x43:
        SRE(indexedIndirect(from: &nes), on: &nes)
    case 0x47:
        SRE(zeroPage(from: &nes), on: &nes)
    case 0x4F:
        SRE(absolute(from: &nes), on: &nes)
    case 0x53:
        SRE(indirectIndexed(from: &nes), on: &nes)
    case 0x57:
        SRE(zeroPageX(from: &nes), on: &nes)
    case 0x5B:
        SRE(absoluteY(from: &nes), on: &nes)
    case 0x5F:
        SRE(absoluteX(from: &nes), on: &nes)

    case 0x63:
        RRA(indexedIndirect(from: &nes), on: &nes)
    case 0x67:
        RRA(zeroPage(from: &nes), on: &nes)
    case 0x6F:
        RRA(absolute(from: &nes), on: &nes)
    case 0x73:
        RRA(indirectIndexed(from: &nes), on: &nes)
    case 0x77:
        RRA(zeroPageX(from: &nes), on: &nes)
    case 0x7B:
        RRA(absoluteY(from: &nes), on: &nes)
    case 0x7F:
        RRA(absoluteX(from: &nes), on: &nes)

    default:
        NOP(implicit(from: &nes), on: &nes)
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

// Implements for Load/Store Operations
/// loadAccumulator
func LDA(_ operand: Operand, on nes: inout NES) {
    nes.cpu.A = readCPU(at: operand, from: &nes)
}

/// loadXRegister
func LDX(_ operand: Operand, on nes: inout NES) {
    nes.cpu.X = readCPU(at: operand, from: &nes)
}

/// loadYRegister
func LDY(_ operand: Operand, on nes: inout NES) {
    nes.cpu.Y = readCPU(at: operand, from: &nes)
}

/// storeAccumulator
func STA(_ operand: Operand, on nes: inout NES) {
    writeCPU(nes.cpu.A, at: operand, to: &nes)
}

func STAWithTick(_ operand: Operand, on nes: inout NES) {
    writeCPU(nes.cpu.A, at: operand, to: &nes)
    nes.cpu.tick()
}

/// storeXRegister
func STX(_ operand: Operand, on nes: inout NES) {
    writeCPU(nes.cpu.X, at: operand, to: &nes)
}

/// storeYRegister
func STY(_ operand: Operand, on nes: inout NES) {
    writeCPU(nes.cpu.Y, at: operand, to: &nes)
}

// MARK: - Register Operations
/// transferAccumulatorToX
func TAX(_ operand: Operand, on nes: inout NES) {
    nes.cpu.X = nes.cpu.A
    nes.cpu.tick()
}

/// transferStackPointerToX
func TSX(_ operand: Operand, on nes: inout NES) {
    nes.cpu.X = nes.cpu.S
    nes.cpu.tick()
}

/// transferAccumulatorToY
func TAY(_ operand: Operand, on nes: inout NES) {
    nes.cpu.Y = nes.cpu.A
    nes.cpu.tick()
}

/// transferXtoAccumulator
func TXA(_ operand: Operand, on nes: inout NES) {
    nes.cpu.A = nes.cpu.X
    nes.cpu.tick()
}

/// transferXtoStackPointer
func TXS(_ operand: Operand, on nes: inout NES) {
    nes.cpu.S = nes.cpu.X
    nes.cpu.tick()
}

/// transferYtoAccumulator
func TYA(_ operand: Operand, on nes: inout NES) {
    nes.cpu.A = nes.cpu.Y
    nes.cpu.tick()
}

// MARK: - Stack instructions
/// pushAccumulator
func PHA(_ operand: Operand, on nes: inout NES) {
    pushStack(nes.cpu.A, to: &nes)
    nes.cpu.tick()
}

/// pushProcessorStatus
func PHP(_ operand: Operand, on nes: inout NES) {
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(nes.cpu.P.rawValue | Status.operatedB.rawValue, to: &nes)
    nes.cpu.tick()
}

/// pullAccumulator
func PLA(_ operand: Operand, on nes: inout NES) {
    nes.cpu.A = pullStack(from: &nes)
    nes.cpu.tick(count: 2)
}

/// pullProcessorStatus
func PLP(_ operand: Operand, on nes: inout NES) {
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    nes.cpu.P = Status(rawValue: pullStack(from: &nes) & ~Status.B.rawValue | Status.R.rawValue)
    nes.cpu.tick(count: 2)
}

// MARK: - Logical instructions
/// bitwiseANDwithAccumulator
func AND(_ operand: Operand, on nes: inout NES) {
    nes.cpu.A &= readCPU(at: operand, from: &nes)
}

/// bitwiseExclusiveOR
func EOR(_ operand: Operand, on nes: inout NES) {
    nes.cpu.A ^= readCPU(at: operand, from: &nes)
}

/// bitwiseORwithAccumulator
func ORA(_ operand: Operand, on nes: inout NES) {
    nes.cpu.A |= readCPU(at: operand, from: &nes)
}

/// testBits
func BIT(_ operand: Operand, on nes: inout NES) {
    let value = readCPU(at: operand, from: &nes)
    let data = nes.cpu.A & value
    nes.cpu.P.remove([.Z, .V, .N])
    if data == 0 { nes.cpu.P.formUnion(.Z) } else { nes.cpu.P.remove(.Z) }
    if value[6] == 1 { nes.cpu.P.formUnion(.V) } else { nes.cpu.P.remove(.V) }
    if value[7] == 1 { nes.cpu.P.formUnion(.N) } else { nes.cpu.P.remove(.N) }
}

// MARK: - Arithmetic instructions
/// addWithCarry
func ADC(_ operand: Operand, on nes: inout NES) {
    let a = nes.cpu.A
    let val = readCPU(at: operand, from: &nes)
    var result = a &+ val

    if nes.cpu.P.contains(.C) { result &+= 1 }

    nes.cpu.P.remove([.C, .Z, .V, .N])

    // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    let a7 = a[7]
    let v7 = val[7]
    let c6 = a7 ^ v7 ^ result[7]
    let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

    if c7 == 1 { nes.cpu.P.formUnion(.C) }
    if c6 ^ c7 == 1 { nes.cpu.P.formUnion(.V) }

    nes.cpu.A = result
}

/// subtractWithCarry
func SBC(_ operand: Operand, on nes: inout NES) {
    let a = nes.cpu.A
    let val = ~readCPU(at: operand, from: &nes)
    var result = a &+ val

    if nes.cpu.P.contains(.C) { result &+= 1 }

    nes.cpu.P.remove([.C, .Z, .V, .N])

    // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    let a7 = a[7]
    let v7 = val[7]
    let c6 = a7 ^ v7 ^ result[7]
    let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

    if c7 == 1 { nes.cpu.P.formUnion(.C) }
    if c6 ^ c7 == 1 { nes.cpu.P.formUnion(.V) }

    nes.cpu.A = result
}

/// compareAccumulator
func CMP(_ operand: Operand, on nes: inout NES) {
    let cmp = Int16(nes.cpu.A) &- Int16(readCPU(at: operand, from: &nes))

    nes.cpu.P.remove([.C, .Z, .N])
    nes.cpu.P.setZN(cmp)
    if 0 <= cmp { nes.cpu.P.formUnion(.C) } else { nes.cpu.P.remove(.C) }

}

/// compareXRegister
func CPX(_ operand: Operand, on nes: inout NES) {
    let value = readCPU(at: operand, from: &nes)
    let cmp = nes.cpu.X &- value

    nes.cpu.P.remove([.C, .Z, .N])
    nes.cpu.P.setZN(cmp)
    if nes.cpu.X >= value { nes.cpu.P.formUnion(.C) } else { nes.cpu.P.remove(.C) }

}

/// compareYRegister
func CPY(_ operand: Operand, on nes: inout NES) {
    let value = readCPU(at: operand, from: &nes)
    let cmp = nes.cpu.Y &- value

    nes.cpu.P.remove([.C, .Z, .N])
    nes.cpu.P.setZN(cmp)
    if nes.cpu.Y >= value { nes.cpu.P.formUnion(.C) } else { nes.cpu.P.remove(.C) }

}

// MARK: - Increment/Decrement instructions
/// incrementMemory
func INC(_ operand: Operand, on nes: inout NES) {
    let result = readCPU(at: operand, from: &nes) &+ 1

    nes.cpu.P.setZN(result)
    writeCPU(result, at: operand, to: &nes)

    nes.cpu.tick()

}

/// incrementX
func INX(_ operand: Operand, on nes: inout NES) {
    nes.cpu.X = nes.cpu.X &+ 1
    nes.cpu.tick()
}

/// incrementY
func INY(_ operand: Operand, on nes: inout NES) {
    nes.cpu.Y = nes.cpu.Y &+ 1
    nes.cpu.tick()
}

/// decrementMemory
func DEC(_ operand: Operand, on nes: inout NES) {
    let result = readCPU(at: operand, from: &nes) &- 1

    nes.cpu.P.setZN(result)

    writeCPU(result, at: operand, to: &nes)

    nes.cpu.tick()

}

/// decrementX
func DEX(_ operand: Operand, on nes: inout NES) {
    nes.cpu.X = nes.cpu.X &- 1
    nes.cpu.tick()
}

/// decrementY
func DEY(_ operand: Operand, on nes: inout NES) {
    nes.cpu.Y = nes.cpu.Y &- 1
    nes.cpu.tick()
}

// MARK: - Shift instructions
/// arithmeticShiftLeft
func ASL(_ operand: Operand, on nes: inout NES) {
    var data = readCPU(at: operand, from: &nes)

    nes.cpu.P.remove([.C, .Z, .N])
    if data[7] == 1 { nes.cpu.P.formUnion(.C) }

    data <<= 1

    nes.cpu.P.setZN(data)

    writeCPU(data, at: operand, to: &nes)

    nes.cpu.tick()
}

func ASLForAccumulator(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.remove([.C, .Z, .N])
    if nes.cpu.A[7] == 1 { nes.cpu.P.formUnion(.C) }

    nes.cpu.A <<= 1

    nes.cpu.tick()
}

/// logicalShiftRight
func LSR(_ operand: Operand, on nes: inout NES) {
    var data = readCPU(at: operand, from: &nes)

    nes.cpu.P.remove([.C, .Z, .N])
    if data[0] == 1 { nes.cpu.P.formUnion(.C) }

    data >>= 1

    nes.cpu.P.setZN(data)

    writeCPU(data, at: operand, to: &nes)

    nes.cpu.tick()
}

func LSRForAccumulator(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.remove([.C, .Z, .N])
    if nes.cpu.A[0] == 1 { nes.cpu.P.formUnion(.C) }

    nes.cpu.A >>= 1

    nes.cpu.tick()
}

/// rotateLeft
func ROL(_ operand: Operand, on nes: inout NES) {
    var data = readCPU(at: operand, from: &nes)
    let c = data & 0x80

    data <<= 1
    if nes.cpu.P.contains(.C) { data |= 0x01 }

    nes.cpu.P.remove([.C, .Z, .N])
    if c == 0x80 { nes.cpu.P.formUnion(.C) }

    nes.cpu.P.setZN(data)

    writeCPU(data, at: operand, to: &nes)

    nes.cpu.tick()
}

func ROLForAccumulator(_ operand: Operand, on nes: inout NES) {
    let c = nes.cpu.A & 0x80

    var a = nes.cpu.A << 1
    if nes.cpu.P.contains(.C) { a |= 0x01 }

    nes.cpu.P.remove([.C, .Z, .N])
    if c == 0x80 { nes.cpu.P.formUnion(.C) }

    nes.cpu.A = a

    nes.cpu.tick()
}

/// rotateRight
func ROR(_ operand: Operand, on nes: inout NES) {
    var data = readCPU(at: operand, from: &nes)
    let c = data & 0x01

    data >>= 1
    if nes.cpu.P.contains(.C) { data |= 0x80 }

    nes.cpu.P.remove([.C, .Z, .N])
    if c == 1 { nes.cpu.P.formUnion(.C) }

    nes.cpu.P.setZN(data)

    writeCPU(data, at: operand, to: &nes)

    nes.cpu.tick()
}

func RORForAccumulator(_ operand: Operand, on nes: inout NES) {
    let c = nes.cpu.A & 0x01

    var a = nes.cpu.A >> 1
    if nes.cpu.P.contains(.C) { a |= 0x80 }

    nes.cpu.P.remove([.C, .Z, .N])
    if c == 1 { nes.cpu.P.formUnion(.C) }

    nes.cpu.A = a

    nes.cpu.tick()
}

// MARK: - Jump instructions
/// jump
func JMP(_ operand: Operand, on nes: inout NES) {
    nes.cpu.PC = operand
}

/// jumpToSubroutine
func JSR(_ operand: Operand, on nes: inout NES) {
    pushStack(word: nes.cpu.PC &- 1, to: &nes)
    nes.cpu.tick()
    nes.cpu.PC = operand
}

/// returnFromSubroutine
func RTS(_ operand: Operand, on nes: inout NES) {
    nes.cpu.tick(count: 3)
    nes.cpu.PC = pullStack(from: &nes) &+ 1
}

/// returnFromInterrupt
func RTI(_ operand: Operand, on nes: inout NES) {
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    nes.cpu.tick(count: 2)
    nes.cpu.P = Status(rawValue: pullStack(from: &nes) & ~Status.B.rawValue | Status.R.rawValue)
    nes.cpu.PC = pullStack(from: &nes)
}

// MARK: - Branch instructions
private func branch(_ operand: Operand, cpu: inout CPU, test: Bool) {
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
func BCC(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: !nes.cpu.P.contains(.C))
}

/// branchIfCarrySet
func BCS(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: nes.cpu.P.contains(.C))
}

/// branchIfEqual
func BEQ(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: nes.cpu.P.contains(.Z))
}

/// branchIfMinus
func BMI(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: nes.cpu.P.contains(.N))
}

/// branchIfNotEqual
func BNE(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: !nes.cpu.P.contains(.Z))
}

/// branchIfPlus
func BPL(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: !nes.cpu.P.contains(.N))
}

/// branchIfOverflowClear
func BVC(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: !nes.cpu.P.contains(.V))
}

/// branchIfOverflowSet
func BVS(_ operand: Operand, on nes: inout NES) {
    branch(operand, cpu: &nes.cpu, test: nes.cpu.P.contains(.V))
}

// MARK: - Flag control instructions
/// clearCarry
func CLC(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.remove(.C)
    nes.cpu.tick()
}

/// clearDecimal
func CLD(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.remove(.D)
    nes.cpu.tick()
}

/// clearInterrupt
func CLI(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.remove(.I)
    nes.cpu.tick()
}

/// clearOverflow
func CLV(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.remove(.V)
    nes.cpu.tick()
}

/// setCarryFlag
func SEC(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.formUnion(.C)
    nes.cpu.tick()
}

/// setDecimalFlag
func SED(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.formUnion(.D)
    nes.cpu.tick()
}

/// setInterruptDisable
func SEI(_ operand: Operand, on nes: inout NES) {
    nes.cpu.P.formUnion(.I)
    nes.cpu.tick()
}

// MARK: - Misc
/// forceInterrupt
func BRK(_ operand: Operand, on nes: inout NES) {
    pushStack(word: nes.cpu.PC, to: &nes)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
    pushStack(nes.cpu.P.rawValue | Status.interruptedB.rawValue, to: &nes)
    nes.cpu.tick()
    nes.cpu.PC = readWord(at: 0xFFFE, from: &nes)
}

/// doNothing
func NOP(_ operand: Operand, on nes: inout NES) {
    nes.cpu.tick()
}

// MARK: - Unofficial
/// loadAccumulatorAndX
func LAX(_ operand: Operand, on nes: inout NES) {
    let data = readCPU(at: operand, from: &nes)
    nes.cpu.A = data
    nes.cpu.X = data
}

/// storeAccumulatorAndX
func SAX(_ operand: Operand, on nes: inout NES) {
    writeCPU(nes.cpu.A & nes.cpu.X, at: operand, to: &nes)
}

/// decrementMemoryAndCompareAccumulator
func DCP(_ operand: Operand, on nes: inout NES) {
    // decrementMemory excluding tick
    let operand = operand
    let result = readCPU(at: operand, from: &nes) &- 1
    nes.cpu.P.setZN(result)
    writeCPU(result, at: operand, to: &nes)

    CMP(operand, on: &nes)
}

/// incrementMemoryAndSubtractWithCarry
func ISB(_ operand: Operand, on nes: inout NES) {
    // incrementMemory excluding tick
    let operand = operand
    let result = readCPU(at: operand, from: &nes) &+ 1
    nes.cpu.P.setZN(result)
    writeCPU(result, at: operand, to: &nes)

    SBC(operand, on: &nes)
}

/// arithmeticShiftLeftAndBitwiseORwithAccumulator
func SLO(_ operand: Operand, on nes: inout NES) {
    // arithmeticShiftLeft excluding tick
    let operand = operand
    var data = readCPU(at: operand, from: &nes)
    nes.cpu.P.remove([.C, .Z, .N])
    if data[7] == 1 { nes.cpu.P.formUnion(.C) }

    data <<= 1
    nes.cpu.P.setZN(data)
    writeCPU(data, at: operand, to: &nes)

    ORA(operand, on: &nes)
}

/// rotateLeftAndBitwiseANDwithAccumulator
func RLA(_ operand: Operand, on nes: inout NES) {
    // rotateLeft excluding tick
    let operand = operand
    var data = readCPU(at: operand, from: &nes)
    let c = data & 0x80

    data <<= 1
    if nes.cpu.P.contains(.C) { data |= 0x01 }

    nes.cpu.P.remove([.C, .Z, .N])
    if c == 0x80 { nes.cpu.P.formUnion(.C) }

    nes.cpu.P.setZN(data)
    writeCPU(data, at: operand, to: &nes)

    AND(operand, on: &nes)
}

/// logicalShiftRightAndBitwiseExclusiveOR
func SRE(_ operand: Operand, on nes: inout NES) {
    // logicalShiftRight excluding tick
    let operand = operand
    var data = readCPU(at: operand, from: &nes)
    nes.cpu.P.remove([.C, .Z, .N])
    if data[0] == 1 { nes.cpu.P.formUnion(.C) }

    data >>= 1

    nes.cpu.P.setZN(data)
    writeCPU(data, at: operand, to: &nes)

    EOR(operand, on: &nes)
}

/// rotateRightAndAddWithCarry
func RRA(_ operand: Operand, on nes: inout NES) {
    // rotateRight excluding tick
    var data = readCPU(at: operand, from: &nes)
    let c = data & 0x01

    data >>= 1
    if nes.cpu.P.contains(.C) { data |= 0x80 }

    nes.cpu.P.remove([.C, .Z, .N])
    if c == 1 { nes.cpu.P.formUnion(.C) }

    nes.cpu.P.setZN(data)
    writeCPU(data, at: operand, to: &nes)

    ADC(operand, on: &nes)
}

@inline(__always)
func pushStack(_ value: UInt8, to nes: inout NES) {
    writeCPU(value, at: nes.cpu.S.u16 &+ 0x100, to: &nes)
    nes.cpu.S &-= 1
}

@inline(__always)
func pushStack(word: UInt16, to nes: inout NES) {
    pushStack(UInt8(word >> 8), to: &nes)
    pushStack(UInt8(word & 0xFF), to: &nes)
}

@inline(__always)
func pullStack(from nes: inout NES) -> UInt8 {
    nes.cpu.S &+= 1
    return readCPU(at: nes.cpu.S.u16 &+ 0x100, from: &nes)
}

@inline(__always)
func pullStack(from nes: inout NES) -> UInt16 {
    let lo: UInt8 = pullStack(from: &nes)
    let ho: UInt8 = pullStack(from: &nes)
    return ho.u16 &<< 8 | lo.u16
}
