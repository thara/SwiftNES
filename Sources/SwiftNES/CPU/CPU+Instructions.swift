typealias OpCode = UInt8

typealias Operand = UInt16

typealias CPUOperation<T: CPUInstructions> = (Operand, inout T) -> Void

protocol CPUInstructions: CPUStack, AddressingMode {
    static func fetchOperand(from: inout Self) -> OpCode
    static func decode(_ opcode: OpCode) -> (CPUOperation<Self>, FetchOperand<Self>)
}

extension NES: CPUInstructions {
    // swiftlint:disable file_length cyclomatic_complexity function_body_length
    @inline(__always)
    static func fetchOperand(from nes: inout NES) -> OpCode {
        let opcode = read(at: nes.cpu.PC, from: &nes)
        nes.cpu.PC &+= 1
        return opcode
    }

    @inline(__always)
    static func decode(_ opcode: OpCode) -> (CPUOperation<NES>, FetchOperand<NES>) {
        switch opcode {
        case 0xA9:
            return (LDA, immediate)
        case 0xA5:
            return (LDA, zeroPage)
        case 0xB5:
            return (LDA, zeroPageX)
        case 0xAD:
            return (LDA, absolute)
        case 0xBD:
            return (LDA, absoluteXWithPenalty)
        case 0xB9:
            return (LDA, absoluteYWithPenalty)
        case 0xA1:
            return (LDA, indexedIndirect)
        case 0xB1:
            return (LDA, indirectIndexed)
        case 0xA2:
            return (LDX, immediate)
        case 0xA6:
            return (LDX, zeroPage)
        case 0xB6:
            return (LDX, zeroPageY)
        case 0xAE:
            return (LDX, absolute)
        case 0xBE:
            return (LDX, absoluteYWithPenalty)
        case 0xA0:
            return (LDY, immediate)
        case 0xA4:
            return (LDY, zeroPage)
        case 0xB4:
            return (LDY, zeroPageX)
        case 0xAC:
            return (LDY, absolute)
        case 0xBC:
            return (LDY, absoluteXWithPenalty)
        case 0x85:
            return (STA, zeroPage)
        case 0x95:
            return (STA, zeroPageX)
        case 0x8D:
            return (STA, absolute)
        case 0x9D:
            return (STA, absoluteX)
        case 0x99:
            return (STA, absoluteY)
        case 0x81:
            return (STA, indexedIndirect)
        case 0x91:
            return (STAWithTick, indirectIndexed)
        case 0x86:
            return (STX, zeroPage)
        case 0x96:
            return (STX, zeroPageY)
        case 0x8E:
            return (STX, absolute)
        case 0x84:
            return (STY, zeroPage)
        case 0x94:
            return (STY, zeroPageX)
        case 0x8C:
            return (STY, absolute)
        case 0xAA:
            return (TAX, implicit)
        case 0xBA:
            return (TSX, implicit)
        case 0xA8:
            return (TAY, implicit)
        case 0x8A:
            return (TXA, implicit)
        case 0x9A:
            return (TXS, implicit)
        case 0x98:
            return (TYA, implicit)

        case 0x48:
            return (PHA, implicit)
        case 0x08:
            return (PHP, implicit)
        case 0x68:
            return (PLA, implicit)
        case 0x28:
            return (PLP, implicit)

        case 0x29:
            return (AND, immediate)
        case 0x25:
            return (AND, zeroPage)
        case 0x35:
            return (AND, zeroPageX)
        case 0x2D:
            return (AND, absolute)
        case 0x3D:
            return (AND, absoluteXWithPenalty)
        case 0x39:
            return (AND, absoluteYWithPenalty)
        case 0x21:
            return (AND, indexedIndirect)
        case 0x31:
            return (AND, indirectIndexed)
        case 0x49:
            return (EOR, immediate)
        case 0x45:
            return (EOR, zeroPage)
        case 0x55:
            return (EOR, zeroPageX)
        case 0x4D:
            return (EOR, absolute)
        case 0x5D:
            return (EOR, absoluteXWithPenalty)
        case 0x59:
            return (EOR, absoluteYWithPenalty)
        case 0x41:
            return (EOR, indexedIndirect)
        case 0x51:
            return (EOR, indirectIndexed)
        case 0x09:
            return (ORA, immediate)
        case 0x05:
            return (ORA, zeroPage)
        case 0x15:
            return (ORA, zeroPageX)
        case 0x0D:
            return (ORA, absolute)
        case 0x1D:
            return (ORA, absoluteXWithPenalty)
        case 0x19:
            return (ORA, absoluteYWithPenalty)
        case 0x01:
            return (ORA, indexedIndirect)
        case 0x11:
            return (ORA, indirectIndexed)
        case 0x24:
            return (BIT, zeroPage)
        case 0x2C:
            return (BIT, absolute)

        case 0x69:
            return (ADC, immediate)
        case 0x65:
            return (ADC, zeroPage)
        case 0x75:
            return (ADC, zeroPageX)
        case 0x6D:
            return (ADC, absolute)
        case 0x7D:
            return (ADC, absoluteXWithPenalty)
        case 0x79:
            return (ADC, absoluteYWithPenalty)
        case 0x61:
            return (ADC, indexedIndirect)
        case 0x71:
            return (ADC, indirectIndexed)
        case 0xE9:
            return (SBC, immediate)
        case 0xE5:
            return (SBC, zeroPage)
        case 0xF5:
            return (SBC, zeroPageX)
        case 0xED:
            return (SBC, absolute)
        case 0xFD:
            return (SBC, absoluteXWithPenalty)
        case 0xF9:
            return (SBC, absoluteYWithPenalty)
        case 0xE1:
            return (SBC, indexedIndirect)
        case 0xF1:
            return (SBC, indirectIndexed)
        case 0xC9:
            return (CMP, immediate)
        case 0xC5:
            return (CMP, zeroPage)
        case 0xD5:
            return (CMP, zeroPageX)
        case 0xCD:
            return (CMP, absolute)
        case 0xDD:
            return (CMP, absoluteXWithPenalty)
        case 0xD9:
            return (CMP, absoluteYWithPenalty)
        case 0xC1:
            return (CMP, indexedIndirect)
        case 0xD1:
            return (CMP, indirectIndexed)
        case 0xE0:
            return (CPX, immediate)
        case 0xE4:
            return (CPX, zeroPage)
        case 0xEC:
            return (CPX, absolute)
        case 0xC0:
            return (CPY, immediate)
        case 0xC4:
            return (CPY, zeroPage)
        case 0xCC:
            return (CPY, absolute)

        case 0xE6:
            return (INC, zeroPage)
        case 0xF6:
            return (INC, zeroPageX)
        case 0xEE:
            return (INC, absolute)
        case 0xFE:
            return (INC, absoluteX)
        case 0xE8:
            return (INX, implicit)
        case 0xC8:
            return (INY, implicit)
        case 0xC6:
            return (DEC, zeroPage)
        case 0xD6:
            return (DEC, zeroPageX)
        case 0xCE:
            return (DEC, absolute)
        case 0xDE:
            return (DEC, absoluteX)
        case 0xCA:
            return (DEX, implicit)
        case 0x88:
            return (DEY, implicit)

        case 0x0A:
            return (ASLForAccumulator, accumulator)
        case 0x06:
            return (ASL, zeroPage)
        case 0x16:
            return (ASL, zeroPageX)
        case 0x0E:
            return (ASL, absolute)
        case 0x1E:
            return (ASL, absoluteX)
        case 0x4A:
            return (LSRForAccumulator, accumulator)
        case 0x46:
            return (LSR, zeroPage)
        case 0x56:
            return (LSR, zeroPageX)
        case 0x4E:
            return (LSR, absolute)
        case 0x5E:
            return (LSR, absoluteX)
        case 0x2A:
            return (ROLForAccumulator, accumulator)
        case 0x26:
            return (ROL, zeroPage)
        case 0x36:
            return (ROL, zeroPageX)
        case 0x2E:
            return (ROL, absolute)
        case 0x3E:
            return (ROL, absoluteX)
        case 0x6A:
            return (RORForAccumulator, accumulator)
        case 0x66:
            return (ROR, zeroPage)
        case 0x76:
            return (ROR, zeroPageX)
        case 0x6E:
            return (ROR, absolute)
        case 0x7E:
            return (ROR, absoluteX)

        case 0x4C:
            return (JMP, absolute)
        case 0x6C:
            return (JMP, indirect)
        case 0x20:
            return (JSR, absolute)
        case 0x60:
            return (RTS, implicit)
        case 0x40:
            return (RTI, implicit)

        case 0x90:
            return (BCC, relative)
        case 0xB0:
            return (BCS, relative)
        case 0xF0:
            return (BEQ, relative)
        case 0x30:
            return (BMI, relative)
        case 0xD0:
            return (BNE, relative)
        case 0x10:
            return (BPL, relative)
        case 0x50:
            return (BVC, relative)
        case 0x70:
            return (BVS, relative)

        case 0x18:
            return (CLC, implicit)
        case 0xD8:
            return (CLD, implicit)
        case 0x58:
            return (CLI, implicit)
        case 0xB8:
            return (CLV, implicit)

        case 0x38:
            return (SEC, implicit)
        case 0xF8:
            return (SED, implicit)
        case 0x78:
            return (SEI, implicit)

        case 0x00:
            return (BRK, implicit)

        // Undocumented

        case 0xEB:
            return (SBC, immediate)

        case 0x04, 0x44, 0x64:
            return (NOP, zeroPage)
        case 0x0C:
            return (NOP, absolute)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            return (NOP, zeroPageX)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            return (NOP, implicit)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            return (NOP, absoluteXWithPenalty)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            return (NOP, immediate)

        case 0xA3:
            return (LAX, indexedIndirect)
        case 0xA7:
            return (LAX, zeroPage)
        case 0xAF:
            return (LAX, absolute)
        case 0xB3:
            return (LAX, indirectIndexed)
        case 0xB7:
            return (LAX, zeroPageY)
        case 0xBF:
            return (LAX, absoluteYWithPenalty)

        case 0x83:
            return (SAX, indexedIndirect)
        case 0x87:
            return (SAX, zeroPage)
        case 0x8F:
            return (SAX, absolute)
        case 0x97:
            return (SAX, zeroPageY)

        case 0xC3:
            return (DCP, indexedIndirect)
        case 0xC7:
            return (DCP, zeroPage)
        case 0xCF:
            return (DCP, absolute)
        case 0xD3:
            return (DCP, indirectIndexed)
        case 0xD7:
            return (DCP, zeroPageX)
        case 0xDB:
            return (DCP, absoluteY)
        case 0xDF:
            return (DCP, absoluteX)

        case 0xE3:
            return (ISB, indexedIndirect)
        case 0xE7:
            return (ISB, zeroPage)
        case 0xEF:
            return (ISB, absolute)
        case 0xF3:
            return (ISB, indirectIndexed)
        case 0xF7:
            return (ISB, zeroPageX)
        case 0xFB:
            return (ISB, absoluteY)
        case 0xFF:
            return (ISB, absoluteX)

        case 0x03:
            return (SLO, indexedIndirect)
        case 0x07:
            return (SLO, zeroPage)
        case 0x0F:
            return (SLO, absolute)
        case 0x13:
            return (SLO, indirectIndexed)
        case 0x17:
            return (SLO, zeroPageX)
        case 0x1B:
            return (SLO, absoluteY)
        case 0x1F:
            return (SLO, absoluteX)

        case 0x23:
            return (RLA, indexedIndirect)
        case 0x27:
            return (RLA, zeroPage)
        case 0x2F:
            return (RLA, absolute)
        case 0x33:
            return (RLA, indirectIndexed)
        case 0x37:
            return (RLA, zeroPageX)
        case 0x3B:
            return (RLA, absoluteY)
        case 0x3F:
            return (RLA, absoluteX)

        case 0x43:
            return (SRE, indexedIndirect)
        case 0x47:
            return (SRE, zeroPage)
        case 0x4F:
            return (SRE, absolute)
        case 0x53:
            return (SRE, indirectIndexed)
        case 0x57:
            return (SRE, zeroPageX)
        case 0x5B:
            return (SRE, absoluteY)
        case 0x5F:
            return (SRE, absoluteX)

        case 0x63:
            return (RRA, indexedIndirect)
        case 0x67:
            return (RRA, zeroPage)
        case 0x6F:
            return (RRA, absolute)
        case 0x73:
            return (RRA, indirectIndexed)
        case 0x77:
            return (RRA, zeroPageX)
        case 0x7B:
            return (RRA, absoluteY)
        case 0x7F:
            return (RRA, absoluteX)

        default:
            return (NOP, implicit)
        }
    }
}

// MARK: - Operations
extension NES {
    // Implements for Load/Store Operations

    /// loadAccumulator
    static func LDA(operand: Operand, on nes: inout NES) {
        nes.cpu.A = read(at: operand, from: &nes)
    }

    /// loadXRegister
    static func LDX(operand: Operand, on nes: inout NES) {
        nes.cpu.X = read(at: operand, from: &nes)
    }

    /// loadYRegister
    static func LDY(operand: Operand, on nes: inout NES) {
        nes.cpu.Y = read(at: operand, from: &nes)
    }

    /// storeAccumulator
    static func STA(operand: Operand, on nes: inout NES) {
        write(nes.cpu.A, at: operand, to: &nes)
    }

    static func STAWithTick(operand: Operand, on nes: inout NES) {
        write(nes.cpu.A, at: operand, to: &nes)
        nes.cpu.tick()
    }

    /// storeXRegister
    static func STX(operand: Operand, on nes: inout NES) {
        write(nes.cpu.X, at: operand, to: &nes)
    }

    /// storeYRegister
    static func STY(operand: Operand, on nes: inout NES) {
        write(nes.cpu.Y, at: operand, to: &nes)
    }

    // MARK: - Register Operations

    /// transferAccumulatorToX
    static func TAX(operand: Operand, on nes: inout NES) {
        nes.cpu.X = nes.cpu.A
        nes.cpu.tick()
    }

    /// transferStackPointerToX
    static func TSX(operand: Operand, on nes: inout NES) {
        nes.cpu.X = nes.cpu.S
        nes.cpu.tick()
    }

    /// transferAccumulatorToY
    static func TAY(operand: Operand, on nes: inout NES) {
        nes.cpu.Y = nes.cpu.A
        nes.cpu.tick()
    }

    /// transferXtoAccumulator
    static func TXA(operand: Operand, on nes: inout NES) {
        nes.cpu.A = nes.cpu.X
        nes.cpu.tick()
    }

    /// transferXtoStackPointer
    static func TXS(operand: Operand, on nes: inout NES) {
        nes.cpu.S = nes.cpu.X
        nes.cpu.tick()
    }

    /// transferYtoAccumulator
    static func TYA(operand: Operand, on nes: inout NES) {
        nes.cpu.A = nes.cpu.Y
        nes.cpu.tick()
    }

    // MARK: - Stack instructions

    /// pushAccumulator
    static func PHA(operand: Operand, on nes: inout NES) {
        pushStack(nes.cpu.A, to: &nes)
        nes.cpu.tick()
    }

    /// pushProcessorStatus
    static func PHP(operand: Operand, on nes: inout NES) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPU.Status.operatedB.rawValue, to: &nes)
        nes.cpu.tick()
    }

    /// pullAccumulator
    static func PLA(operand: Operand, on nes: inout NES) {
        nes.cpu.A = pullStack(from: &nes)
        nes.cpu.tick(count: 2)
    }

    /// pullProcessorStatus
    static func PLP(operand: Operand, on nes: inout NES) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        nes.cpu.P = CPU.Status(rawValue: pullStack(from: &nes) & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
        nes.cpu.tick(count: 2)
    }

    // MARK: - Logical instructions

    /// bitwiseANDwithAccumulator
    static func AND(operand: Operand, on nes: inout NES) {
        nes.cpu.A &= read(at: operand, from: &nes)
    }

    /// bitwiseExclusiveOR
    static func EOR(operand: Operand, on nes: inout NES) {
        nes.cpu.A ^= read(at: operand, from: &nes)
    }

    /// bitwiseORwithAccumulator
    static func ORA(operand: Operand, on nes: inout NES) {
        nes.cpu.A |= read(at: operand, from: &nes)
    }

    /// testBits
    static func BIT(operand: Operand, on nes: inout NES) {
        let value = read(at: operand, from: &nes)
        let data = nes.cpu.A & value
        nes.cpu.P.remove([.Z, .V, .N])
        if data == 0 { nes.cpu.P.formUnion(.Z) } else { nes.cpu.P.remove(.Z) }
        if value[6] == 1 { nes.cpu.P.formUnion(.V) } else { nes.cpu.P.remove(.V) }
        if value[7] == 1 { nes.cpu.P.formUnion(.N) } else { nes.cpu.P.remove(.N) }
    }

    // MARK: - Arithmetic instructions

    /// addWithCarry
    static func ADC(operand: Operand, on nes: inout NES) {
        let a = nes.cpu.A
        let val = read(at: operand, from: &nes)
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
    static func SBC(operand: Operand, on nes: inout NES) {
        let a = nes.cpu.A
        let val = ~read(at: operand, from: &nes)
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
    static func CMP(operand: Operand, on nes: inout NES) {
        let cmp = Int16(nes.cpu.A) &- Int16(read(at: operand, from: &nes))

        nes.cpu.P.remove([.C, .Z, .N])
        nes.cpu.P.setZN(cmp)
        if 0 <= cmp { nes.cpu.P.formUnion(.C) } else { nes.cpu.P.remove(.C) }

    }

    /// compareXRegister
    static func CPX(operand: Operand, on nes: inout NES) {
        let value = read(at: operand, from: &nes)
        let cmp = nes.cpu.X &- value

        nes.cpu.P.remove([.C, .Z, .N])
        nes.cpu.P.setZN(cmp)
        if nes.cpu.X >= value { nes.cpu.P.formUnion(.C) } else { nes.cpu.P.remove(.C) }

    }

    /// compareYRegister
    static func CPY(operand: Operand, on nes: inout NES) {
        let value = read(at: operand, from: &nes)
        let cmp = nes.cpu.Y &- value

        nes.cpu.P.remove([.C, .Z, .N])
        nes.cpu.P.setZN(cmp)
        if nes.cpu.Y >= value { nes.cpu.P.formUnion(.C) } else { nes.cpu.P.remove(.C) }

    }

    // MARK: - Increment/Decrement instructions

    /// incrementnes
    static func INC(operand: Operand, on nes: inout NES) {
        let result = read(at: operand, from: &nes) &+ 1

        nes.cpu.P.setZN(result)
        write(result, at: operand, to: &nes)

        nes.cpu.tick()

    }

    /// incrementX
    static func INX(operand: Operand, on nes: inout NES) {
        nes.cpu.X = nes.cpu.X &+ 1
        nes.cpu.tick()
    }

    /// incrementY
    static func INY(operand: Operand, on nes: inout NES) {
        nes.cpu.Y = nes.cpu.Y &+ 1
        nes.cpu.tick()
    }

    /// decrementnes
    static func DEC(operand: Operand, on nes: inout NES) {
        let result = read(at: operand, from: &nes) &- 1
        nes.cpu.P.setZN(result)

        write(result, at: operand, to: &nes)
        nes.cpu.tick()
    }

    /// decrementX
    static func DEX(operand: Operand, on nes: inout NES) {
        nes.cpu.X = nes.cpu.X &- 1
        nes.cpu.tick()
    }

    /// decrementY
    static func DEY(operand: Operand, on nes: inout NES) {
        nes.cpu.Y = nes.cpu.Y &- 1
        nes.cpu.tick()
    }

    // MARK: - Shift instructions

    /// arithmeticShiftLeft
    static func ASL(operand: Operand, on nes: inout NES) {
        var data = read(at: operand, from: &nes)

        nes.cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 { nes.cpu.P.formUnion(.C) }

        data <<= 1

        nes.cpu.P.setZN(data)

        write(data, at: operand, to: &nes)

        nes.cpu.tick()
    }

    static func ASLForAccumulator(operand: Operand, on nes: inout NES) {
        nes.cpu.P.remove([.C, .Z, .N])
        if nes.cpu.A[7] == 1 { nes.cpu.P.formUnion(.C) }

        nes.cpu.A <<= 1

        nes.cpu.tick()
    }

    /// logicalShiftRight
    static func LSR(operand: Operand, on nes: inout NES) {
        var data = read(at: operand, from: &nes)

        nes.cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 { nes.cpu.P.formUnion(.C) }

        data >>= 1

        nes.cpu.P.setZN(data)

        write(data, at: operand, to: &nes)

        nes.cpu.tick()
    }

    static func LSRForAccumulator(operand: Operand, on nes: inout NES) {
        nes.cpu.P.remove([.C, .Z, .N])
        if nes.cpu.A[0] == 1 { nes.cpu.P.formUnion(.C) }

        nes.cpu.A >>= 1

        nes.cpu.tick()
    }

    /// rotateLeft
    static func ROL(operand: Operand, on nes: inout NES) {
        var data = read(at: operand, from: &nes)
        let c = data & 0x80

        data <<= 1
        if nes.cpu.P.contains(.C) { data |= 0x01 }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { nes.cpu.P.formUnion(.C) }

        nes.cpu.P.setZN(data)

        write(data, at: operand, to: &nes)

        nes.cpu.tick()
    }

    static func ROLForAccumulator(operand: Operand, on nes: inout NES) {
        let c = nes.cpu.A & 0x80

        var a = nes.cpu.A << 1
        if nes.cpu.P.contains(.C) { a |= 0x01 }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { nes.cpu.P.formUnion(.C) }

        nes.cpu.A = a

        nes.cpu.tick()
    }

    /// rotateRight
    static func ROR(operand: Operand, on nes: inout NES) {
        var data = read(at: operand, from: &nes)
        let c = data & 0x01

        data >>= 1
        if nes.cpu.P.contains(.C) { data |= 0x80 }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 1 { nes.cpu.P.formUnion(.C) }

        nes.cpu.P.setZN(data)

        write(data, at: operand, to: &nes)

        nes.cpu.tick()
    }

    static func RORForAccumulator(operand: Operand, on nes: inout NES) {
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
    static func JMP(operand: Operand, on nes: inout NES) {
        nes.cpu.PC = operand
    }

    /// jumpToSubroutine
    static func JSR(operand: Operand, on nes: inout NES) {
        pushStack(word: nes.cpu.PC &- 1, to: &nes)
        nes.cpu.tick()
        nes.cpu.PC = operand
    }

    /// returnFromSubroutine
    static func RTS(operand: Operand, on nes: inout NES) {
        nes.cpu.tick(count: 3)
        nes.cpu.PC = pullStack(from: &nes) &+ 1
    }

    /// returnFromInterrupt
    static func RTI(operand: Operand, on nes: inout NES) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        nes.cpu.tick(count: 2)
        nes.cpu.P = CPU.Status(rawValue: pullStack(from: &nes) & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
        nes.cpu.PC = pullStack(from: &nes)
    }

    // MARK: - Branch instructions

    private static func branch(operand: Operand, test: Bool, on nes: inout NES) {
        if test {
            nes.cpu.tick()
            let pc = Int(nes.cpu.PC)
            let offset = Int(operand.i8)
            if pageCrossed(value: pc, operand: offset) {
                nes.cpu.tick()
            }
            nes.cpu.PC = UInt16(pc &+ offset)
        }
    }

    /// branchIfCarryClear
    static func BCC(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: !nes.cpu.P.contains(.C), on: &nes)
    }

    /// branchIfCarrySet
    static func BCS(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: nes.cpu.P.contains(.C), on: &nes)
    }

    /// branchIfEqual
    static func BEQ(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: nes.cpu.P.contains(.Z), on: &nes)
    }

    /// branchIfMinus
    static func BMI(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: nes.cpu.P.contains(.N), on: &nes)
    }

    /// branchIfNotEqual
    static func BNE(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: !nes.cpu.P.contains(.Z), on: &nes)
    }

    /// branchIfPlus
    static func BPL(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: !nes.cpu.P.contains(.N), on: &nes)
    }

    /// branchIfOverflowClear
    static func BVC(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: !nes.cpu.P.contains(.V), on: &nes)
    }

    /// branchIfOverflowSet
    static func BVS(operand: Operand, on nes: inout NES) {
        branch(operand: operand, test: nes.cpu.P.contains(.V), on: &nes)
    }

    // MARK: - Flag control instructions

    /// clearCarry
    static func CLC(operand: Operand, on nes: inout NES) {
        nes.cpu.P.remove(.C)
        nes.cpu.tick()
    }

    /// clearDecimal
    static func CLD(operand: Operand, on nes: inout NES) {
        nes.cpu.P.remove(.D)
        nes.cpu.tick()
    }

    /// clearInterrupt
    static func CLI(operand: Operand, on nes: inout NES) {
        nes.cpu.P.remove(.I)
        nes.cpu.tick()
    }

    /// clearOverflow
    static func CLV(operand: Operand, on nes: inout NES) {
        nes.cpu.P.remove(.V)
        nes.cpu.tick()
    }

    /// setCarryFlag
    static func SEC(operand: Operand, on nes: inout NES) {
        nes.cpu.P.formUnion(.C)
        nes.cpu.tick()
    }

    /// setDecimalFlag
    static func SED(operand: Operand, on nes: inout NES) {
        nes.cpu.P.formUnion(.D)
        nes.cpu.tick()
    }

    /// setInterruptDisable
    static func SEI(operand: Operand, on nes: inout NES) {
        nes.cpu.P.formUnion(.I)
        nes.cpu.tick()
    }

    // MARK: - Misc

    /// forceInterrupt
    static func BRK(operand: Operand, on nes: inout NES) {
        pushStack(word: nes.cpu.PC, to: &nes)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPU.Status.interruptedB.rawValue, to: &nes)
        nes.cpu.tick()
        nes.cpu.PC = readWord(at: 0xFFFE, from: &nes)
    }

    /// doNothing
    static func NOP(operand: Operand, on nes: inout NES) {
        nes.cpu.tick()
    }

    // MARK: - Unofficial

    /// loadAccumulatorAndX
    static func LAX(operand: Operand, on nes: inout NES) {
        let data = read(at: operand, from: &nes)
        nes.cpu.A = data
        nes.cpu.X = data
    }

    /// storeAccumulatorAndX
    static func SAX(operand: Operand, on nes: inout NES) {
        write(nes.cpu.A & nes.cpu.X, at: operand, to: &nes)
    }

    /// decrementnesAndCompareAccumulator
    static func DCP(operand: Operand, on nes: inout NES) {
        // decrementnes excluding nes.cpu.tick
        let result = read(at: operand, from: &nes) &- 1
        nes.cpu.P.setZN(result)
        write(result, at: operand, to: &nes)

        CMP(operand: operand, on: &nes)
    }

    /// incrementnesAndSubtractWithCarry
    static func ISB(operand: Operand, on nes: inout NES) {
        // incrementnes excluding nes.cpu.tick
        let result = read(at: operand, from: &nes) &+ 1
        nes.cpu.P.setZN(result)
        write(result, at: operand, to: &nes)

        SBC(operand: operand, on: &nes)
    }

    /// arithmeticShiftLeftAndBitwiseORwithAccumulator
    static func SLO(operand: Operand, on nes: inout NES) {
        // arithmeticShiftLeft excluding nes.cpu.tick
        var data = read(at: operand, from: &nes)
        nes.cpu.P.remove([.C, .Z, .N])
        if data[7] == 1 { nes.cpu.P.formUnion(.C) }

        data <<= 1
        nes.cpu.P.setZN(data)
        write(data, at: operand, to: &nes)

        ORA(operand: operand, on: &nes)
    }

    /// rotateLeftAndBitwiseANDwithAccumulator
    static func RLA(operand: Operand, on nes: inout NES) {
        // rotateLeft excluding nes.cpu.tick
        var data = read(at: operand, from: &nes)
        let c = data & 0x80

        data <<= 1
        if nes.cpu.P.contains(.C) { data |= 0x01 }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 0x80 { nes.cpu.P.formUnion(.C) }

        nes.cpu.P.setZN(data)
        write(data, at: operand, to: &nes)

        AND(operand: operand, on: &nes)
    }

    /// logicalShiftRightAndBitwiseExclusiveOR
    static func SRE(operand: Operand, on nes: inout NES) {
        // logicalShiftRight excluding nes.cpu.tick
        var data = read(at: operand, from: &nes)
        nes.cpu.P.remove([.C, .Z, .N])
        if data[0] == 1 { nes.cpu.P.formUnion(.C) }

        data >>= 1

        nes.cpu.P.setZN(data)
        write(data, at: operand, to: &nes)

        EOR(operand: operand, on: &nes)
    }

    /// rotateRightAndAddWithCarry
    static func RRA(operand: Operand, on nes: inout NES) {
        // rotateRight excluding nes.cpu.tick
        var data = read(at: operand, from: &nes)
        let c = data & 0x01

        data >>= 1
        if nes.cpu.P.contains(.C) { data |= 0x80 }

        nes.cpu.P.remove([.C, .Z, .N])
        if c == 1 { nes.cpu.P.formUnion(.C) }

        nes.cpu.P.setZN(data)
        write(data, at: operand, to: &nes)

        ADC(operand: operand, on: &nes)
    }
}

// MARK: - Stack
protocol CPUStack: ReadWrite {
    static func pushStack(_ value: UInt8, to: inout Self)
    static func pushStack(word: UInt16, to: inout Self)
    static func pullStack(from: inout Self) -> UInt8
    static func pullStack(from: inout Self) -> UInt16
}

extension NES: CPUStack {
    @inline(__always)
    static func pushStack(_ value: UInt8, to nes: inout NES) {
        write(value, at: nes.cpu.S.u16 &+ 0x100, to: &nes)
        nes.cpu.S &-= 1
    }

    @inline(__always)
    static func pushStack(word: UInt16, to nes: inout NES) {
        pushStack(UInt8(word >> 8), to: &nes)
        pushStack(UInt8(word & 0xFF), to: &nes)
    }

    @inline(__always)
    static func pullStack(from nes: inout NES) -> UInt8 {
        nes.cpu.S &+= 1
        return read(at: nes.cpu.S.u16 &+ 0x100, from: &nes)
    }

    @inline(__always)
    static func pullStack(from nes: inout NES) -> UInt16 {
        let lo: UInt8 = pullStack(from: &nes)
        let ho: UInt8 = pullStack(from: &nes)
        return ho.u16 &<< 8 | lo.u16
    }
}

