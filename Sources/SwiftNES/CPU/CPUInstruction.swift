protocol CPUInstruction {
    associatedtype AddressingMode: SwiftNES.AddressingMode

    static func execute(cpu: inout CPU)
}

struct AnyCPUInstruction {
    private let _execute: ((inout CPU) -> ())

    init<CI: CPUInstruction>(_ instruction: CI.Type) {
        _execute = CI.execute
    }

    func execute(cpu: inout CPU) {
        _execute(&cpu)
    }
}

// swiftlint:disable file_length cyclomatic_complexity function_body_length
func decode(opcode: OpCode) -> AnyCPUInstruction {
    switch opcode {
    case 0xA9:
        return .init(LDA<Immediate>.self)
    case 0xA5:
        return .init(LDA<ZeroPage>.self)
    case 0xB5:
        return .init(LDA<ZeroPageX>.self)
    case 0xAD:
        return .init(LDA<Absolute>.self)
    case 0xBD:
        return .init(LDA<AbsoluteXWithPenalty>.self)
    case 0xB9:
        return .init(LDA<AbsoluteYWithPenalty>.self)
    case 0xA1:
        return .init(LDA<IndexedIndirect>.self)
    case 0xB1:
        return .init(LDA<IndirectIndexed>.self)
    case 0xA2:
        return .init(LDX<Immediate>.self)
    case 0xA6:
        return .init(LDX<ZeroPage>.self)
    case 0xB6:
        return .init(LDX<ZeroPageY>.self)
    case 0xAE:
        return .init(LDX<Absolute>.self)
    case 0xBE:
        return .init(LDX<AbsoluteYWithPenalty>.self)
    case 0xA0:
        return .init(LDY<Immediate>.self)
    case 0xA4:
        return .init(LDY<ZeroPage>.self)
    case 0xB4:
        return .init(LDY<ZeroPageX>.self)
    case 0xAC:
        return .init(LDY<Absolute>.self)
    case 0xBC:
        return .init(LDY<AbsoluteXWithPenalty>.self)
    case 0x85:
        return .init(STA<ZeroPage>.self)
    case 0x95:
        return .init(STA<ZeroPageX>.self)
    case 0x8D:
        return .init(STA<Absolute>.self)
    case 0x9D:
        return .init(STA<AbsoluteX>.self)
    case 0x99:
        return .init(STA<AbsoluteY>.self)
    case 0x81:
        return .init(STA<IndexedIndirect>.self)
    case 0x91:
        return .init(STAWithTick<IndirectIndexed>.self)
    case 0x86:
        return .init(STX<ZeroPage>.self)
    case 0x96:
        return .init(STX<ZeroPageY>.self)
    case 0x8E:
        return .init(STX<Absolute>.self)
    case 0x84:
        return .init(STY<ZeroPage>.self)
    case 0x94:
        return .init(STY<ZeroPageX>.self)
    case 0x8C:
        return .init(STY<Absolute>.self)
    case 0xAA:
        return .init(TAX.self)
    case 0xBA:
        return .init(TSX.self)
    case 0xA8:
        return .init(TAY.self)
    case 0x8A:
        return .init(TXA.self)
    case 0x9A:
        return .init(TXS.self)
    case 0x98:
        return .init(TYA.self)

    case 0x48:
        return .init(PHA.self)
    case 0x08:
        return .init(PHP.self)
    case 0x68:
        return .init(PLA.self)
    case 0x28:
        return .init(PLP.self)

    case 0x29:
        return .init(AND<Immediate>.self)
    case 0x25:
        return .init(AND<ZeroPage>.self)
    case 0x35:
        return .init(AND<ZeroPageX>.self)
    case 0x2D:
        return .init(AND<Absolute>.self)
    case 0x3D:
        return .init(AND<AbsoluteXWithPenalty>.self)
    case 0x39:
        return .init(AND<AbsoluteYWithPenalty>.self)
    case 0x21:
        return .init(AND<IndexedIndirect>.self)
    case 0x31:
        return .init(AND<IndirectIndexed>.self)
    case 0x49:
        return .init(EOR<Immediate>.self)
    case 0x45:
        return .init(EOR<ZeroPage>.self)
    case 0x55:
        return .init(EOR<ZeroPageX>.self)
    case 0x4D:
        return .init(EOR<Absolute>.self)
    case 0x5D:
        return .init(EOR<AbsoluteXWithPenalty>.self)
    case 0x59:
        return .init(EOR<AbsoluteYWithPenalty>.self)
    case 0x41:
        return .init(EOR<IndexedIndirect>.self)
    case 0x51:
        return .init(EOR<IndirectIndexed>.self)
    case 0x09:
        return .init(ORA<Immediate>.self)
    case 0x05:
        return .init(ORA<ZeroPage>.self)
    case 0x15:
        return .init(ORA<ZeroPageX>.self)
    case 0x0D:
        return .init(ORA<Absolute>.self)
    case 0x1D:
        return .init(ORA<AbsoluteXWithPenalty>.self)
    case 0x19:
        return .init(ORA<AbsoluteYWithPenalty>.self)
    case 0x01:
        return .init(ORA<IndexedIndirect>.self)
    case 0x11:
        return .init(ORA<IndirectIndexed>.self)
    case 0x24:
        return .init(BIT<ZeroPage>.self)
    case 0x2C:
        return .init(BIT<Absolute>.self)

    case 0x69:
        return .init(ADC<Immediate>.self)
    case 0x65:
        return .init(ADC<ZeroPage>.self)
    case 0x75:
        return .init(ADC<ZeroPageX>.self)
    case 0x6D:
        return .init(ADC<Absolute>.self)
    case 0x7D:
        return .init(ADC<AbsoluteXWithPenalty>.self)
    case 0x79:
        return .init(ADC<AbsoluteYWithPenalty>.self)
    case 0x61:
        return .init(ADC<IndexedIndirect>.self)
    case 0x71:
        return .init(ADC<IndirectIndexed>.self)
    case 0xE9:
        return .init(SBC<Immediate>.self)
    case 0xE5:
        return .init(SBC<ZeroPage>.self)
    case 0xF5:
        return .init(SBC<ZeroPageX>.self)
    case 0xED:
        return .init(SBC<Absolute>.self)
    case 0xFD:
        return .init(SBC<AbsoluteXWithPenalty>.self)
    case 0xF9:
        return .init(SBC<AbsoluteYWithPenalty>.self)
    case 0xE1:
        return .init(SBC<IndexedIndirect>.self)
    case 0xF1:
        return .init(SBC<IndirectIndexed>.self)
    case 0xC9:
        return .init(CMP<Immediate>.self)
    case 0xC5:
        return .init(CMP<ZeroPage>.self)
    case 0xD5:
        return .init(CMP<ZeroPageX>.self)
    case 0xCD:
        return .init(CMP<Absolute>.self)
    case 0xDD:
        return .init(CMP<AbsoluteXWithPenalty>.self)
    case 0xD9:
        return .init(CMP<AbsoluteYWithPenalty>.self)
    case 0xC1:
        return .init(CMP<IndexedIndirect>.self)
    case 0xD1:
        return .init(CMP<IndirectIndexed>.self)
    case 0xE0:
        return .init(CPX<Immediate>.self)
    case 0xE4:
        return .init(CPX<ZeroPage>.self)
    case 0xEC:
        return .init(CPX<Absolute>.self)
    case 0xC0:
        return .init(CPY<Immediate>.self)
    case 0xC4:
        return .init(CPY<ZeroPage>.self)
    case 0xCC:
        return .init(CPY<Absolute>.self)

    case 0xE6:
        return .init(INC<ZeroPage>.self)
    case 0xF6:
        return .init(INC<ZeroPageX>.self)
    case 0xEE:
        return .init(INC<Absolute>.self)
    case 0xFE:
        return .init(INC<AbsoluteX>.self)
    case 0xE8:
        return .init(INX.self)
    case 0xC8:
        return .init(INY.self)
    case 0xC6:
        return .init(DEC<ZeroPage>.self)
    case 0xD6:
        return .init(DEC<ZeroPageX>.self)
    case 0xCE:
        return .init(DEC<Absolute>.self)
    case 0xDE:
        return .init(DEC<AbsoluteX>.self)
    case 0xCA:
        return .init(DEX.self)
    case 0x88:
        return .init(DEY.self)

    case 0x0A:
        return .init(ASLForAccumulator.self)
    case 0x06:
        return .init(ASL<ZeroPage>.self)
    case 0x16:
        return .init(ASL<ZeroPageX>.self)
    case 0x0E:
        return .init(ASL<Absolute>.self)
    case 0x1E:
        return .init(ASL<AbsoluteX>.self)
    case 0x4A:
        return .init(LSRForAccumulator.self)
    case 0x46:
        return .init(LSR<ZeroPage>.self)
    case 0x56:
        return .init(LSR<ZeroPageX>.self)
    case 0x4E:
        return .init(LSR<Absolute>.self)
    case 0x5E:
        return .init(LSR<AbsoluteX>.self)
    case 0x2A:
        return .init(ROLForAccumulator.self)
    case 0x26:
        return .init(ROL<ZeroPage>.self)
    case 0x36:
        return .init(ROL<ZeroPageX>.self)
    case 0x2E:
        return .init(ROL<Absolute>.self)
    case 0x3E:
        return .init(ROL<AbsoluteX>.self)
    case 0x6A:
        return .init(RORForAccumulator.self)
    case 0x66:
        return .init(ROR<ZeroPage>.self)
    case 0x76:
        return .init(ROR<ZeroPageX>.self)
    case 0x6E:
        return .init(ROR<Absolute>.self)
    case 0x7E:
        return .init(ROR<AbsoluteX>.self)

    case 0x4C:
        return .init(JMP<Absolute>.self)
    case 0x6C:
        return .init(JMP<Indirect>.self)
    case 0x20:
        return .init(JSR<Absolute>.self)
    case 0x60:
        return .init(RTS.self)
    case 0x40:
        return .init(RTI.self)

    case 0x90:
        return .init(BCC<Relative>.self)
    case 0xB0:
        return .init(BCS<Relative>.self)
    case 0xF0:
        return .init(BEQ<Relative>.self)
    case 0x30:
        return .init(BMI<Relative>.self)
    case 0xD0:
        return .init(BNE<Relative>.self)
    case 0x10:
        return .init(BPL<Relative>.self)
    case 0x50:
        return .init(BVC<Relative>.self)
    case 0x70:
        return .init(BVS<Relative>.self)

    case 0x18:
        return .init(CLC.self)
    case 0xD8:
        return .init(CLD.self)
    case 0x58:
        return .init(CLI.self)
    case 0xB8:
        return .init(CLV.self)

    case 0x38:
        return .init(SEC.self)
    case 0xF8:
        return .init(SED.self)
    case 0x78:
        return .init(SEI.self)

    case 0x00:
        return .init(BRK.self)

    // Undocumented
    case 0xEB:
        return .init(SBC<Immediate>.self)

    case 0x04, 0x44, 0x64:
        return .init(NOP<ZeroPage>.self)
    case 0x0C:
        return .init(NOP<Absolute>.self)
    case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
        return .init(NOP<ZeroPageX>.self)
    case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
        return .init(NOP<Implicit>.self)
    case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
        return .init(NOP<AbsoluteXWithPenalty>.self)
    case 0x80, 0x82, 0x89, 0xC2, 0xE2:
        return .init(NOP<Immediate>.self)

    case 0xA3:
        return .init(LAX<IndexedIndirect>.self)
    case 0xA7:
        return .init(LAX<ZeroPage>.self)
    case 0xAF:
        return .init(LAX<Absolute>.self)
    case 0xB3:
        return .init(LAX<IndirectIndexed>.self)
    case 0xB7:
        return .init(LAX<ZeroPageY>.self)
    case 0xBF:
        return .init(LAX<AbsoluteYWithPenalty>.self)

    case 0x83:
        return .init(SAX<IndexedIndirect>.self)
    case 0x87:
        return .init(SAX<ZeroPage>.self)
    case 0x8F:
        return .init(SAX<Absolute>.self)
    case 0x97:
        return .init(SAX<ZeroPageY>.self)

    case 0xC3:
        return .init(DCP<IndexedIndirect>.self)
    case 0xC7:
        return .init(DCP<ZeroPage>.self)
    case 0xCF:
        return .init(DCP<Absolute>.self)
    case 0xD3:
        return .init(DCP<IndirectIndexed>.self)
    case 0xD7:
        return .init(DCP<ZeroPageX>.self)
    case 0xDB:
        return .init(DCP<AbsoluteY>.self)
    case 0xDF:
        return .init(DCP<AbsoluteX>.self)

    case 0xE3:
        return .init(ISB<IndexedIndirect>.self)
    case 0xE7:
        return .init(ISB<ZeroPage>.self)
    case 0xEF:
        return .init(ISB<Absolute>.self)
    case 0xF3:
        return .init(ISB<IndirectIndexed>.self)
    case 0xF7:
        return .init(ISB<ZeroPageX>.self)
    case 0xFB:
        return .init(ISB<AbsoluteY>.self)
    case 0xFF:
        return .init(ISB<AbsoluteX>.self)

    case 0x03:
        return .init(SLO<IndexedIndirect>.self)
    case 0x07:
        return .init(SLO<ZeroPage>.self)
    case 0x0F:
        return .init(SLO<Absolute>.self)
    case 0x13:
        return .init(SLO<IndirectIndexed>.self)
    case 0x17:
        return .init(SLO<ZeroPageX>.self)
    case 0x1B:
        return .init(SLO<AbsoluteY>.self)
    case 0x1F:
        return .init(SLO<AbsoluteX>.self)

    case 0x23:
        return .init(RLA<IndexedIndirect>.self)
    case 0x27:
        return .init(RLA<ZeroPage>.self)
    case 0x2F:
        return .init(RLA<Absolute>.self)
    case 0x33:
        return .init(RLA<IndirectIndexed>.self)
    case 0x37:
        return .init(RLA<ZeroPageX>.self)
    case 0x3B:
        return .init(RLA<AbsoluteY>.self)
    case 0x3F:
        return .init(RLA<AbsoluteX>.self)

    case 0x43:
        return .init(SRE<IndexedIndirect>.self)
    case 0x47:
        return .init(SRE<ZeroPage>.self)
    case 0x4F:
        return .init(SRE<Absolute>.self)
    case 0x53:
        return .init(SRE<IndirectIndexed>.self)
    case 0x57:
        return .init(SRE<ZeroPageX>.self)
    case 0x5B:
        return .init(SRE<AbsoluteY>.self)
    case 0x5F:
        return .init(SRE<AbsoluteX>.self)

    case 0x63:
        return .init(RRA<IndexedIndirect>.self)
    case 0x67:
        return .init(RRA<ZeroPage>.self)
    case 0x6F:
        return .init(RRA<Absolute>.self)
    case 0x73:
        return .init(RRA<IndirectIndexed>.self)
    case 0x77:
        return .init(RRA<ZeroPageX>.self)
    case 0x7B:
        return .init(RRA<AbsoluteY>.self)
    case 0x7F:
        return .init(RRA<AbsoluteX>.self)

    default:
        return .init(NOP<Implicit>.self)
    }
}

// MARK: - Operations
// Implements for Load/Store Operations
/// loadAccumulator
enum LDA<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.A = cpu.read(at: operand)
    }
}

/// loadXRegister
enum LDX<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.X = cpu.read(at: operand)
    }
}

/// loadYRegister
enum LDY<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.Y = cpu.read(at: operand)
    }
}

/// storeAccumulator
enum STA<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.write(cpu.A, at: operand)
    }
}

enum STAWithTick<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.write(cpu.A, at: operand)
        cpu.tick()
    }
}

/// storeXRegister
enum STX<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.write(cpu.X, at: operand)
    }
}

/// storeYRegister
enum STY<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.write(cpu.Y, at: operand)
    }
}

// MARK: - cpu Operations
/// transferAccumulatorToX
enum TAX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.X = cpu.A
        cpu.tick()
    }
}

/// transferStackPointerToX
enum TSX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.X = cpu.S
        cpu.tick()
    }
}

/// transferAccumulatorToY
enum TAY: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.Y = cpu.A
        cpu.tick()
    }
}

/// transferXtoAccumulator
enum TXA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.A = cpu.X
        cpu.tick()
    }
}

/// transferXtoStackPointer
enum TXS: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.S = cpu.X
        cpu.tick()
    }
}

/// transferYtoAccumulator
enum TYA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.A = cpu.Y
        cpu.tick()
    }
}

// MARK: - Stack instructions
/// pushAccumulator
enum PHA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.pushStack(cpu.A)
        cpu.tick()
    }
}

/// pushProcessorStatus
enum PHP: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.pushStack(cpu.P.rawValue | CPU.Status.operatedB.rawValue)
        cpu.tick()
    }
}

/// pullAccumulator
enum PLA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.A = cpu.pullStack()
        cpu.tick(count: 2)
    }
}

/// pullProcessorStatus
enum PLP: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.P = CPU.Status(rawValue: cpu.pullStack() & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
        cpu.tick(count: 2)
    }
}

    // MARK: - Logical instructions
/// bitwiseANDwithAccumulator
enum AND<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        cpu.A &= cpu.read(at: operand)
    }
}

func executeAND(operand: Operand, cpu: inout CPU) {
    cpu.A &= cpu.read(at: operand)
}

/// bitwiseExclusiveOR
enum EOR<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        executeEOR(operand: operand, cpu: &cpu)
    }
}

func executeEOR(operand: Operand, cpu: inout CPU) {
    cpu.A ^= cpu.read(at: operand)
}


/// bitwiseORwithAccumulator
enum ORA<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        executeORA(operand: operand, cpu: &cpu)
    }
}

func executeORA(operand: Operand, cpu: inout CPU) {
    cpu.A |= cpu.read(at: operand)
}

/// testBits
enum BIT<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}


// MARK: - Arithmetic instructions
/// addWithCarry
enum ADC<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)
        executeAOR(operand: operand, cpu: &cpu)
    }
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
enum SBC<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
enum CMP<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        executeCMP(operand: operand, cpu: &cpu)
    }
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
enum CPX<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

/// compareYRegister
enum CPY<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

// MARK: - Increment/Decrement instructions
/// incrementMemory
enum INC<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        let result = cpu.read(at: operand) &+ 1

        cpu.P.setZN(result)
        cpu.write(result, at: operand)

        cpu.tick()
    }
}

/// incrementX
enum INX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.X = cpu.X &+ 1
        cpu.tick()
    }
}

/// incrementY
enum INY: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.Y = cpu.Y &+ 1
        cpu.tick()
    }
}

/// decrementMemory
enum DEC<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        let result = cpu.read(at: operand) &- 1
        cpu.P.setZN(result)

        cpu.write(result, at: operand)
        cpu.tick()
    }
}

/// decrementX
enum DEX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.X = cpu.X &- 1
        cpu.tick()
    }
}

/// decrementY
enum DEY: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.Y = cpu.Y &- 1
        cpu.tick()
    }
}


// MARK: - Shift instructions
/// arithmeticShiftLeft
enum ASL<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

enum ASLForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute(cpu: inout CPU) {
        cpu.P.remove([.C, .Z, .N])
        if cpu.A[7] == 1 {
            cpu.P.formUnion(.C)
        }

        cpu.A <<= 1

        cpu.tick()
    }
}

/// logicalShiftRight
enum LSR<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

enum LSRForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute(cpu: inout CPU) {
        cpu.P.remove([.C, .Z, .N])
        if cpu.A[0] == 1 {
            cpu.P.formUnion(.C)
        }

        cpu.A >>= 1

        cpu.tick()
    }
}

/// rotateLeft
enum ROL<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

enum ROLForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute(cpu: inout CPU) {
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
}

/// rotateRight
enum ROR<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

enum RORForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute(cpu: inout CPU) {
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
}

// MARK: - Jump instructions
/// jump
enum JMP<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        cpu.PC = operand
    }
}

/// jumpToSubroutine
enum JSR<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        cpu.pushStack(word: cpu.PC &- 1)
        cpu.tick()
        cpu.PC = operand
    }
}

/// returnFromSubroutine
enum RTS: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.tick(count: 3)
        cpu.PC = cpu.pullStack() &+ 1
    }
}

/// returnFromInterrupt
enum RTI: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.tick(count: 2)
        cpu.P = CPU.Status(rawValue: cpu.pullStack() & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
        cpu.PC = cpu.pullStack()
    }
}


// MARK: - Branch instructions
/// branchIfCarryClear
enum BCC<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: !cpu.P.contains(.C), cpu: &cpu)
    }
}

/// branchIfCarrySet
enum BCS<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: cpu.P.contains(.C), cpu: &cpu)
    }
}

/// branchIfEqual
enum BEQ<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: cpu.P.contains(.Z), cpu: &cpu)
    }
}

/// branchIfMinus
enum BMI<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: cpu.P.contains(.N), cpu: &cpu)
    }
}

/// branchIfNotEqual
enum BNE<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: !cpu.P.contains(.Z), cpu: &cpu)
    }
}

/// branchIfPlus
enum BPL<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: !cpu.P.contains(.N), cpu: &cpu)
    }
}

/// branchIfOverflowClear
enum BVC<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: !cpu.P.contains(.V), cpu: &cpu)
    }

}

/// branchIfOverflowSet
enum BVS<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        branch(operand: operand, test: cpu.P.contains(.V), cpu: &cpu)
    }
}


// MARK: - Flag control instructions
/// clearCarry
enum CLC: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.P.remove(.C)
        cpu.tick()
    }
}

/// clearDecimal
enum CLD: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.P.remove(.D)
        cpu.tick()
    }
}

/// clearInterrupt
enum CLI: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.P.remove(.I)
        cpu.tick()
    }
}

/// clearOverflow
enum CLV: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.P.remove(.V)
        cpu.tick()
    }
}

/// setCarryFlag
enum SEC: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.P.formUnion(.C)
        cpu.tick()
    }
}

/// setDecimalFlag
enum SED: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.P.formUnion(.D)
        cpu.tick()
    }
}

/// setInterruptDisable
enum SEI: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.P.formUnion(.I)
        cpu.tick()
    }
}

// MARK: - Misc
/// forceInterrupt
enum BRK: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute(cpu: inout CPU) {
        cpu.pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
        cpu.tick()
        cpu.PC = cpu.readWord(at: 0xFFFE)
    }
}

/// doNothing
enum NOP<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let _ = AddressingMode.getOperand(cpu: &cpu)

        cpu.tick()
    }
}


// MARK: - Unofficial
/// loadAccumulatorAndX
enum LAX<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        let data = cpu.read(at: operand)
        cpu.A = data
        cpu.X = data
    }
}

/// storeAccumulatorAndX
enum SAX<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        cpu.write(cpu.A & cpu.X, at: operand)
    }
}

/// decrementMemoryAndCompareAccumulator
enum DCP<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        // decrementMemory excluding tick
        let result = cpu.read(at: operand) &- 1
        cpu.P.setZN(result)
        cpu.write(result, at: operand)

        executeCMP(operand: operand, cpu: &cpu)
    }
}

/// incrementMemoryAndSubtractWithCarry
enum ISB<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

        // incrementMemory excluding tick
        let result = cpu.read(at: operand) &+ 1
        cpu.P.setZN(result)
        cpu.write(result, at: operand)

        executeSBC(operand: operand, cpu: &cpu)
    }
}

/// arithmeticShiftLeftAndBitwiseORwithAccumulator
enum SLO<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

/// rotateLeftAndBitwiseANDwithAccumulator
enum RLA<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

/// logicalShiftRightAndBitwiseExclusiveOR
enum SRE<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
}

/// rotateRightAndAddWithCarry
enum RRA<AddressingMode: SwiftNES.AddressingMode>: CPUInstruction {
    static func execute(cpu: inout CPU) {
        let operand = AddressingMode.getOperand(cpu: &cpu)

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
