typealias OpCode = UInt8

typealias Operand = UInt16

typealias CPUOperation = (Operand, inout CPU) -> Void

// swiftlint:disable file_length cyclomatic_complexity function_body_length
extension CPU {

    @inline(__always)
    static func fetchOperand(from cpu: inout CPU) -> OpCode {
        let opcode = cpu.read(at: cpu.PC)
        cpu.PC &+= 1
        return opcode
    }

    @inline(__always)
    static func decode(opcode: OpCode, on cpu: inout CPU) -> (CPUOperation, FetchOperand) {
        switch opcode {
        case 0xA9:
            return (CPU.LDA, CPU.immediate)
        case 0xA5:
            return (CPU.LDA, CPU.zeroPage)
        case 0xB5:
            return (CPU.LDA, CPU.zeroPageX)
        case 0xAD:
            return (CPU.LDA, CPU.absolute)
        case 0xBD:
            return (CPU.LDA, CPU.absoluteXWithPenalty)
        case 0xB9:
            return (CPU.LDA, CPU.absoluteYWithPenalty)
        case 0xA1:
            return (CPU.LDA, CPU.indexedIndirect)
        case 0xB1:
            return (CPU.LDA, CPU.indirectIndexed)
        case 0xA2:
            return (CPU.LDX, CPU.immediate)
        case 0xA6:
            return (CPU.LDX, CPU.zeroPage)
        case 0xB6:
            return (CPU.LDX, CPU.zeroPageY)
        case 0xAE:
            return (CPU.LDX, CPU.absolute)
        case 0xBE:
            return (CPU.LDX, CPU.absoluteYWithPenalty)
        case 0xA0:
            return (CPU.LDY, CPU.immediate)
        case 0xA4:
            return (CPU.LDY, CPU.zeroPage)
        case 0xB4:
            return (CPU.LDY, CPU.zeroPageX)
        case 0xAC:
            return (CPU.LDY, CPU.absolute)
        case 0xBC:
            return (CPU.LDY, CPU.absoluteXWithPenalty)
        case 0x85:
            return (CPU.STA, CPU.zeroPage)
        case 0x95:
            return (CPU.STA, CPU.zeroPageX)
        case 0x8D:
            return (CPU.STA, CPU.absolute)
        case 0x9D:
            return (CPU.STA, CPU.absoluteX)
        case 0x99:
            return (CPU.STA, CPU.absoluteY)
        case 0x81:
            return (CPU.STA, CPU.indexedIndirect)
        case 0x91:
            return (CPU.STAWithTick, CPU.indirectIndexed)
        case 0x86:
            return (CPU.STX, CPU.zeroPage)
        case 0x96:
            return (CPU.STX, CPU.zeroPageY)
        case 0x8E:
            return (CPU.STX, CPU.absolute)
        case 0x84:
            return (CPU.STY, CPU.zeroPage)
        case 0x94:
            return (CPU.STY, CPU.zeroPageX)
        case 0x8C:
            return (CPU.STY, CPU.absolute)
        case 0xAA:
            return (CPU.TAX, CPU.implicit)
        case 0xBA:
            return (CPU.TSX, CPU.implicit)
        case 0xA8:
            return (CPU.TAY, CPU.implicit)
        case 0x8A:
            return (CPU.TXA, CPU.implicit)
        case 0x9A:
            return (CPU.TXS, CPU.implicit)
        case 0x98:
            return (CPU.TYA, CPU.implicit)

        case 0x48:
            return (CPU.PHA, CPU.implicit)
        case 0x08:
            return (CPU.PHP, CPU.implicit)
        case 0x68:
            return (CPU.PLA, CPU.implicit)
        case 0x28:
            return (CPU.PLP, CPU.implicit)

        case 0x29:
            return (CPU.AND, CPU.immediate)
        case 0x25:
            return (CPU.AND, CPU.zeroPage)
        case 0x35:
            return (CPU.AND, CPU.zeroPageX)
        case 0x2D:
            return (CPU.AND, CPU.absolute)
        case 0x3D:
            return (CPU.AND, CPU.absoluteXWithPenalty)
        case 0x39:
            return (CPU.AND, CPU.absoluteYWithPenalty)
        case 0x21:
            return (CPU.AND, CPU.indexedIndirect)
        case 0x31:
            return (CPU.AND, CPU.indirectIndexed)
        case 0x49:
            return (CPU.EOR, CPU.immediate)
        case 0x45:
            return (CPU.EOR, CPU.zeroPage)
        case 0x55:
            return (CPU.EOR, CPU.zeroPageX)
        case 0x4D:
            return (CPU.EOR, CPU.absolute)
        case 0x5D:
            return (CPU.EOR, CPU.absoluteXWithPenalty)
        case 0x59:
            return (CPU.EOR, CPU.absoluteYWithPenalty)
        case 0x41:
            return (CPU.EOR, CPU.indexedIndirect)
        case 0x51:
            return (CPU.EOR, CPU.indirectIndexed)
        case 0x09:
            return (CPU.ORA, CPU.immediate)
        case 0x05:
            return (CPU.ORA, CPU.zeroPage)
        case 0x15:
            return (CPU.ORA, CPU.zeroPageX)
        case 0x0D:
            return (CPU.ORA, CPU.absolute)
        case 0x1D:
            return (CPU.ORA, CPU.absoluteXWithPenalty)
        case 0x19:
            return (CPU.ORA, CPU.absoluteYWithPenalty)
        case 0x01:
            return (CPU.ORA, CPU.indexedIndirect)
        case 0x11:
            return (CPU.ORA, CPU.indirectIndexed)
        case 0x24:
            return (CPU.BIT, CPU.zeroPage)
        case 0x2C:
            return (CPU.BIT, CPU.absolute)

        case 0x69:
            return (CPU.ADC, CPU.immediate)
        case 0x65:
            return (CPU.ADC, CPU.zeroPage)
        case 0x75:
            return (CPU.ADC, CPU.zeroPageX)
        case 0x6D:
            return (CPU.ADC, CPU.absolute)
        case 0x7D:
            return (CPU.ADC, CPU.absoluteXWithPenalty)
        case 0x79:
            return (CPU.ADC, CPU.absoluteYWithPenalty)
        case 0x61:
            return (CPU.ADC, CPU.indexedIndirect)
        case 0x71:
            return (CPU.ADC, CPU.indirectIndexed)
        case 0xE9:
            return (CPU.SBC, CPU.immediate)
        case 0xE5:
            return (CPU.SBC, CPU.zeroPage)
        case 0xF5:
            return (CPU.SBC, CPU.zeroPageX)
        case 0xED:
            return (CPU.SBC, CPU.absolute)
        case 0xFD:
            return (CPU.SBC, CPU.absoluteXWithPenalty)
        case 0xF9:
            return (CPU.SBC, CPU.absoluteYWithPenalty)
        case 0xE1:
            return (CPU.SBC, CPU.indexedIndirect)
        case 0xF1:
            return (CPU.SBC, CPU.indirectIndexed)
        case 0xC9:
            return (CPU.CMP, CPU.immediate)
        case 0xC5:
            return (CPU.CMP, CPU.zeroPage)
        case 0xD5:
            return (CPU.CMP, CPU.zeroPageX)
        case 0xCD:
            return (CPU.CMP, CPU.absolute)
        case 0xDD:
            return (CPU.CMP, CPU.absoluteXWithPenalty)
        case 0xD9:
            return (CPU.CMP, CPU.absoluteYWithPenalty)
        case 0xC1:
            return (CPU.CMP, CPU.indexedIndirect)
        case 0xD1:
            return (CPU.CMP, CPU.indirectIndexed)
        case 0xE0:
            return (CPU.CPX, CPU.immediate)
        case 0xE4:
            return (CPU.CPX, CPU.zeroPage)
        case 0xEC:
            return (CPU.CPX, CPU.absolute)
        case 0xC0:
            return (CPU.CPY, CPU.immediate)
        case 0xC4:
            return (CPU.CPY, CPU.zeroPage)
        case 0xCC:
            return (CPU.CPY, CPU.absolute)

        case 0xE6:
            return (CPU.INC, CPU.zeroPage)
        case 0xF6:
            return (CPU.INC, CPU.zeroPageX)
        case 0xEE:
            return (CPU.INC, CPU.absolute)
        case 0xFE:
            return (CPU.INC, CPU.absoluteX)
        case 0xE8:
            return (CPU.INX, CPU.implicit)
        case 0xC8:
            return (CPU.INY, CPU.implicit)
        case 0xC6:
            return (CPU.DEC, CPU.zeroPage)
        case 0xD6:
            return (CPU.DEC, CPU.zeroPageX)
        case 0xCE:
            return (CPU.DEC, CPU.absolute)
        case 0xDE:
            return (CPU.DEC, CPU.absoluteX)
        case 0xCA:
            return (CPU.DEX, CPU.implicit)
        case 0x88:
            return (CPU.DEY, CPU.implicit)

        case 0x0A:
            return (CPU.ASLForAccumulator, CPU.accumulator)
        case 0x06:
            return (CPU.ASL, CPU.zeroPage)
        case 0x16:
            return (CPU.ASL, CPU.zeroPageX)
        case 0x0E:
            return (CPU.ASL, CPU.absolute)
        case 0x1E:
            return (CPU.ASL, CPU.absoluteX)
        case 0x4A:
            return (CPU.LSRForAccumulator, CPU.accumulator)
        case 0x46:
            return (CPU.LSR, CPU.zeroPage)
        case 0x56:
            return (CPU.LSR, CPU.zeroPageX)
        case 0x4E:
            return (CPU.LSR, CPU.absolute)
        case 0x5E:
            return (CPU.LSR, CPU.absoluteX)
        case 0x2A:
            return (CPU.ROLForAccumulator, CPU.accumulator)
        case 0x26:
            return (CPU.ROL, CPU.zeroPage)
        case 0x36:
            return (CPU.ROL, CPU.zeroPageX)
        case 0x2E:
            return (CPU.ROL, CPU.absolute)
        case 0x3E:
            return (CPU.ROL, CPU.absoluteX)
        case 0x6A:
            return (CPU.RORForAccumulator, CPU.accumulator)
        case 0x66:
            return (CPU.ROR, CPU.zeroPage)
        case 0x76:
            return (CPU.ROR, CPU.zeroPageX)
        case 0x6E:
            return (CPU.ROR, CPU.absolute)
        case 0x7E:
            return (CPU.ROR, CPU.absoluteX)

        case 0x4C:
            return (CPU.JMP, CPU.absolute)
        case 0x6C:
            return (CPU.JMP, CPU.indirect)
        case 0x20:
            return (CPU.JSR, CPU.absolute)
        case 0x60:
            return (CPU.RTS, CPU.implicit)
        case 0x40:
            return (CPU.RTI, CPU.implicit)

        case 0x90:
            return (CPU.BCC, CPU.relative)
        case 0xB0:
            return (CPU.BCS, CPU.relative)
        case 0xF0:
            return (CPU.BEQ, CPU.relative)
        case 0x30:
            return (CPU.BMI, CPU.relative)
        case 0xD0:
            return (CPU.BNE, CPU.relative)
        case 0x10:
            return (CPU.BPL, CPU.relative)
        case 0x50:
            return (CPU.BVC, CPU.relative)
        case 0x70:
            return (CPU.BVS, CPU.relative)

        case 0x18:
            return (CPU.CLC, CPU.implicit)
        case 0xD8:
            return (CPU.CLD, CPU.implicit)
        case 0x58:
            return (CPU.CLI, CPU.implicit)
        case 0xB8:
            return (CPU.CLV, CPU.implicit)

        case 0x38:
            return (CPU.SEC, CPU.implicit)
        case 0xF8:
            return (CPU.SED, CPU.implicit)
        case 0x78:
            return (CPU.SEI, CPU.implicit)

        case 0x00:
            return (CPU.BRK, CPU.implicit)

        // Undocumented

        case 0xEB:
            return (CPU.SBC, CPU.immediate)

        case 0x04, 0x44, 0x64:
            return (CPU.NOP, CPU.zeroPage)
        case 0x0C:
            return (CPU.NOP, CPU.absolute)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            return (CPU.NOP, CPU.zeroPageX)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            return (CPU.NOP, CPU.implicit)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            return (CPU.NOP, CPU.absoluteXWithPenalty)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            return (CPU.NOP, CPU.immediate)

        case 0xA3:
            return (CPU.LAX, CPU.indexedIndirect)
        case 0xA7:
            return (CPU.LAX, CPU.zeroPage)
        case 0xAF:
            return (CPU.LAX, CPU.absolute)
        case 0xB3:
            return (CPU.LAX, CPU.indirectIndexed)
        case 0xB7:
            return (CPU.LAX, CPU.zeroPageY)
        case 0xBF:
            return (CPU.LAX, CPU.absoluteYWithPenalty)

        case 0x83:
            return (CPU.SAX, CPU.indexedIndirect)
        case 0x87:
            return (CPU.SAX, CPU.zeroPage)
        case 0x8F:
            return (CPU.SAX, CPU.absolute)
        case 0x97:
            return (CPU.SAX, CPU.zeroPageY)

        case 0xC3:
            return (CPU.DCP, CPU.indexedIndirect)
        case 0xC7:
            return (CPU.DCP, CPU.zeroPage)
        case 0xCF:
            return (CPU.DCP, CPU.absolute)
        case 0xD3:
            return (CPU.DCP, CPU.indirectIndexed)
        case 0xD7:
            return (CPU.DCP, CPU.zeroPageX)
        case 0xDB:
            return (CPU.DCP, CPU.absoluteY)
        case 0xDF:
            return (CPU.DCP, CPU.absoluteX)

        case 0xE3:
            return (CPU.ISB, CPU.indexedIndirect)
        case 0xE7:
            return (CPU.ISB, CPU.zeroPage)
        case 0xEF:
            return (CPU.ISB, CPU.absolute)
        case 0xF3:
            return (CPU.ISB, CPU.indirectIndexed)
        case 0xF7:
            return (CPU.ISB, CPU.zeroPageX)
        case 0xFB:
            return (CPU.ISB, CPU.absoluteY)
        case 0xFF:
            return (CPU.ISB, CPU.absoluteX)

        case 0x03:
            return (CPU.SLO, CPU.indexedIndirect)
        case 0x07:
            return (CPU.SLO, CPU.zeroPage)
        case 0x0F:
            return (CPU.SLO, CPU.absolute)
        case 0x13:
            return (CPU.SLO, CPU.indirectIndexed)
        case 0x17:
            return (CPU.SLO, CPU.zeroPageX)
        case 0x1B:
            return (CPU.SLO, CPU.absoluteY)
        case 0x1F:
            return (CPU.SLO, CPU.absoluteX)

        case 0x23:
            return (CPU.RLA, CPU.indexedIndirect)
        case 0x27:
            return (CPU.RLA, CPU.zeroPage)
        case 0x2F:
            return (CPU.RLA, CPU.absolute)
        case 0x33:
            return (CPU.RLA, CPU.indirectIndexed)
        case 0x37:
            return (CPU.RLA, CPU.zeroPageX)
        case 0x3B:
            return (CPU.RLA, CPU.absoluteY)
        case 0x3F:
            return (CPU.RLA, CPU.absoluteX)

        case 0x43:
            return (CPU.SRE, CPU.indexedIndirect)
        case 0x47:
            return (CPU.SRE, CPU.zeroPage)
        case 0x4F:
            return (CPU.SRE, CPU.absolute)
        case 0x53:
            return (CPU.SRE, CPU.indirectIndexed)
        case 0x57:
            return (CPU.SRE, CPU.zeroPageX)
        case 0x5B:
            return (CPU.SRE, CPU.absoluteY)
        case 0x5F:
            return (CPU.SRE, CPU.absoluteX)

        case 0x63:
            return (CPU.RRA, CPU.indexedIndirect)
        case 0x67:
            return (CPU.RRA, CPU.zeroPage)
        case 0x6F:
            return (CPU.RRA, CPU.absolute)
        case 0x73:
            return (CPU.RRA, CPU.indirectIndexed)
        case 0x77:
            return (CPU.RRA, CPU.zeroPageX)
        case 0x7B:
            return (CPU.RRA, CPU.absoluteY)
        case 0x7F:
            return (CPU.RRA, CPU.absoluteX)

        default:
            return (CPU.NOP, CPU.implicit)
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
