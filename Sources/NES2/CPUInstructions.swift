// MARK: Addressing mode

// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
protocol AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand
}

struct Implicit: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        return 0x00
    }
}

struct Accumulator: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        return register.A.u16
    }
}

struct Immediate: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let operand = register.PC
        register.PC &+= 1
        return operand
    }
}

struct ZeroPage: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let operand = cpu.cpuRead(at: register.PC, from: &bus).u16 & 0xFF
        register.PC &+= 1
        return operand
    }
}

enum ZeroPageX: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        cpu.cpuTick()

        let operand = (cpu.cpuRead(at: register.PC, from: &bus).u16 &+ register.X.u16) & 0xFF
        register.PC &+= 1
        return operand
    }
}

enum ZeroPageY: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        cpu.cpuTick()

        let operand = (cpu.cpuRead(at: register.PC, from: &bus).u16 &+ register.Y.u16) & 0xFF
        register.PC &+= 1
        return operand
    }
}

enum Absolute: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let operand = cpu.cpuReadWord(at: register.PC, from: &bus)
        register.PC &+= 2
        return operand
    }
}

enum AbsoluteX: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let data = cpu.cpuReadWord(at: register.PC, from: &bus)
        let operand = data &+ register.X.u16 & 0xFFFF
        register.PC &+= 2
        cpu.cpuTick()
        return operand
    }
}

enum AbsoluteXWithPenalty: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let data = cpu.cpuReadWord(at: register.PC, from: &bus)
        let operand = data &+ register.X.u16 & 0xFFFF
        register.PC &+= 2

        if pageCrossed(value: data, operand: register.X) {
            cpu.cpuTick()
        }
        return operand
    }
}

enum AbsoluteY: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let data = cpu.cpuReadWord(at: register.PC, from: &bus)
        let operand = data &+ register.Y.u16 & 0xFFFF
        register.PC &+= 2
        cpu.cpuTick()
        return operand
    }
}

enum AbsoluteYWithPenalty: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let data = cpu.cpuReadWord(at: register.PC, from: &bus)
        let operand = data &+ register.Y.u16 & 0xFFFF
        register.PC &+= 2

        if pageCrossed(value: data, operand: register.Y) {
            cpu.cpuTick()
        }
        return operand
    }
}

enum Relative: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let operand = cpu.cpuRead(at: register.PC, from: &bus).u16
        register.PC &+= 1
        return operand
    }
}

enum Indirect: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let data = cpu.cpuReadWord(at: register.PC, from: &bus)
        let operand = cpu.readOnIndirect(operand: data, from: &bus)
        register.PC &+= 2
        return operand
    }
}

enum IndexedIndirect: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let data = cpu.cpuRead(at: register.PC, from: &bus)
        let operand = cpu.readOnIndirect(operand: (data &+ register.X).u16 & 0xFF, from: &bus)
        register.PC &+= 1

        cpu.cpuTick()

        return operand
    }
}

enum IndirectIndexed: AddressingMode {
    static func getOperand<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, with bus: inout CPU.Bus) -> CPU.Operand {
        let data = cpu.cpuRead(at: register.PC, from: &bus).u16
        let operand = cpu.readOnIndirect(operand: data, from: &bus) &+ register.Y.u16
        register.PC &+= 1

        if pageCrossed(value: operand &- register.Y.u16, operand: register.Y) {
            cpu.cpuTick()
        }
        return operand
    }
}

extension CPU {
    @inline(__always)
    mutating func readOnIndirect(operand: UInt16, from bus: inout Bus) -> UInt16 {
        let low = cpuRead(at: operand, from: &bus).u16
        let high = cpuRead(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF), from: &bus).u16 &<< 8  // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
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
extension CPU {

    mutating func executeInstruction(opcode: OpCode, register: inout Register, with bus: inout Bus) {
        let instruction = Self.decode(opcode: opcode)
        instruction.execute(cpu: &self, register: &register, bus: &bus)
    }

    static func decode(opcode: OpCode) -> AnyCPUInstruction<Self> {
        switch opcode {
        case 0xA9:
            return AnyCPUInstruction(LDA<Immediate>.self)
        case 0xA5:
            return AnyCPUInstruction(LDA<ZeroPage>.self)
        case 0xB5:
            return AnyCPUInstruction(LDA<ZeroPageX>.self)
        case 0xAD:
            return AnyCPUInstruction(LDA<Absolute>.self)
        case 0xBD:
            return AnyCPUInstruction(LDA<AbsoluteXWithPenalty>.self)
        case 0xB9:
            return AnyCPUInstruction(LDA<AbsoluteYWithPenalty>.self)
        case 0xA1:
            return AnyCPUInstruction(LDA<IndexedIndirect>.self)
        case 0xB1:
            return AnyCPUInstruction(LDA<IndirectIndexed>.self)
        case 0xA2:
            return AnyCPUInstruction(LDX<Immediate>.self)
        case 0xA6:
            return AnyCPUInstruction(LDX<ZeroPage>.self)
        case 0xB6:
            return AnyCPUInstruction(LDX<ZeroPageY>.self)
        case 0xAE:
            return AnyCPUInstruction(LDX<Absolute>.self)
        case 0xBE:
            return AnyCPUInstruction(LDX<AbsoluteYWithPenalty>.self)
        case 0xA0:
            return AnyCPUInstruction(LDY<Immediate>.self)
        case 0xA4:
            return AnyCPUInstruction(LDY<ZeroPage>.self)
        case 0xB4:
            return AnyCPUInstruction(LDY<ZeroPageX>.self)
        case 0xAC:
            return AnyCPUInstruction(LDY<Absolute>.self)
        case 0xBC:
            return AnyCPUInstruction(LDY<AbsoluteXWithPenalty>.self)
        case 0x85:
            return AnyCPUInstruction(STA<ZeroPage>.self)
        case 0x95:
            return AnyCPUInstruction(STA<ZeroPageX>.self)
        case 0x8D:
            return AnyCPUInstruction(STA<Absolute>.self)
        case 0x9D:
            return AnyCPUInstruction(STA<AbsoluteX>.self)
        case 0x99:
            return AnyCPUInstruction(STA<AbsoluteY>.self)
        case 0x81:
            return AnyCPUInstruction(STA<IndexedIndirect>.self)
        case 0x91:
            return AnyCPUInstruction(STAWithTick<IndirectIndexed>.self)
        case 0x86:
            return AnyCPUInstruction(STX<ZeroPage>.self)
        case 0x96:
            return AnyCPUInstruction(STX<ZeroPageY>.self)
        case 0x8E:
            return AnyCPUInstruction(STX<Absolute>.self)
        case 0x84:
            return AnyCPUInstruction(STY<ZeroPage>.self)
        case 0x94:
            return AnyCPUInstruction(STY<ZeroPageX>.self)
        case 0x8C:
            return AnyCPUInstruction(STY<Absolute>.self)
        case 0xAA:
            return AnyCPUInstruction(TAX.self)
        case 0xBA:
            return AnyCPUInstruction(TSX.self)
        case 0xA8:
            return AnyCPUInstruction(TAY.self)
        case 0x8A:
            return AnyCPUInstruction(TXA.self)
        case 0x9A:
            return AnyCPUInstruction(TXS.self)
        case 0x98:
            return AnyCPUInstruction(TYA.self)

        case 0x48:
            return AnyCPUInstruction(PHA.self)
        case 0x08:
            return AnyCPUInstruction(PHP.self)
        case 0x68:
            return AnyCPUInstruction(PLA.self)
        case 0x28:
            return AnyCPUInstruction(PLP.self)

        case 0x29:
            return AnyCPUInstruction(AND<Immediate>.self)
        case 0x25:
            return AnyCPUInstruction(AND<ZeroPage>.self)
        case 0x35:
            return AnyCPUInstruction(AND<ZeroPageX>.self)
        case 0x2D:
            return AnyCPUInstruction(AND<Absolute>.self)
        case 0x3D:
            return AnyCPUInstruction(AND<AbsoluteXWithPenalty>.self)
        case 0x39:
            return AnyCPUInstruction(AND<AbsoluteYWithPenalty>.self)
        case 0x21:
            return AnyCPUInstruction(AND<IndexedIndirect>.self)
        case 0x31:
            return AnyCPUInstruction(AND<IndirectIndexed>.self)
        case 0x49:
            return AnyCPUInstruction(EOR<Immediate>.self)
        case 0x45:
            return AnyCPUInstruction(EOR<ZeroPage>.self)
        case 0x55:
            return AnyCPUInstruction(EOR<ZeroPageX>.self)
        case 0x4D:
            return AnyCPUInstruction(EOR<Absolute>.self)
        case 0x5D:
            return AnyCPUInstruction(EOR<AbsoluteXWithPenalty>.self)
        case 0x59:
            return AnyCPUInstruction(EOR<AbsoluteYWithPenalty>.self)
        case 0x41:
            return AnyCPUInstruction(EOR<IndexedIndirect>.self)
        case 0x51:
            return AnyCPUInstruction(EOR<IndirectIndexed>.self)
        case 0x09:
            return AnyCPUInstruction(ORA<Immediate>.self)
        case 0x05:
            return AnyCPUInstruction(ORA<ZeroPage>.self)
        case 0x15:
            return AnyCPUInstruction(ORA<ZeroPageX>.self)
        case 0x0D:
            return AnyCPUInstruction(ORA<Absolute>.self)
        case 0x1D:
            return AnyCPUInstruction(ORA<AbsoluteXWithPenalty>.self)
        case 0x19:
            return AnyCPUInstruction(ORA<AbsoluteYWithPenalty>.self)
        case 0x01:
            return AnyCPUInstruction(ORA<IndexedIndirect>.self)
        case 0x11:
            return AnyCPUInstruction(ORA<IndirectIndexed>.self)
        case 0x24:
            return AnyCPUInstruction(BIT<ZeroPage>.self)
        case 0x2C:
            return AnyCPUInstruction(BIT<Absolute>.self)

        case 0x69:
            return AnyCPUInstruction(ADC<Immediate>.self)
        case 0x65:
            return AnyCPUInstruction(ADC<ZeroPage>.self)
        case 0x75:
            return AnyCPUInstruction(ADC<ZeroPageX>.self)
        case 0x6D:
            return AnyCPUInstruction(ADC<Absolute>.self)
        case 0x7D:
            return AnyCPUInstruction(ADC<AbsoluteXWithPenalty>.self)
        case 0x79:
            return AnyCPUInstruction(ADC<AbsoluteYWithPenalty>.self)
        case 0x61:
            return AnyCPUInstruction(ADC<IndexedIndirect>.self)
        case 0x71:
            return AnyCPUInstruction(ADC<IndirectIndexed>.self)
        case 0xE9:
            return AnyCPUInstruction(SBC<Immediate>.self)
        case 0xE5:
            return AnyCPUInstruction(SBC<ZeroPage>.self)
        case 0xF5:
            return AnyCPUInstruction(SBC<ZeroPageX>.self)
        case 0xED:
            return AnyCPUInstruction(SBC<Absolute>.self)
        case 0xFD:
            return AnyCPUInstruction(SBC<AbsoluteXWithPenalty>.self)
        case 0xF9:
            return AnyCPUInstruction(SBC<AbsoluteYWithPenalty>.self)
        case 0xE1:
            return AnyCPUInstruction(SBC<IndexedIndirect>.self)
        case 0xF1:
            return AnyCPUInstruction(SBC<IndirectIndexed>.self)
        case 0xC9:
            return AnyCPUInstruction(CMP<Immediate>.self)
        case 0xC5:
            return AnyCPUInstruction(CMP<ZeroPage>.self)
        case 0xD5:
            return AnyCPUInstruction(CMP<ZeroPageX>.self)
        case 0xCD:
            return AnyCPUInstruction(CMP<Absolute>.self)
        case 0xDD:
            return AnyCPUInstruction(CMP<AbsoluteXWithPenalty>.self)
        case 0xD9:
            return AnyCPUInstruction(CMP<AbsoluteYWithPenalty>.self)
        case 0xC1:
            return AnyCPUInstruction(CMP<IndexedIndirect>.self)
        case 0xD1:
            return AnyCPUInstruction(CMP<IndirectIndexed>.self)
        case 0xE0:
            return AnyCPUInstruction(CPX<Immediate>.self)
        case 0xE4:
            return AnyCPUInstruction(CPX<ZeroPage>.self)
        case 0xEC:
            return AnyCPUInstruction(CPX<Absolute>.self)
        case 0xC0:
            return AnyCPUInstruction(CPY<Immediate>.self)
        case 0xC4:
            return AnyCPUInstruction(CPY<ZeroPage>.self)
        case 0xCC:
            return AnyCPUInstruction(CPY<Absolute>.self)

        case 0xE6:
            return AnyCPUInstruction(INC<ZeroPage>.self)
        case 0xF6:
            return AnyCPUInstruction(INC<ZeroPageX>.self)
        case 0xEE:
            return AnyCPUInstruction(INC<Absolute>.self)
        case 0xFE:
            return AnyCPUInstruction(INC<AbsoluteX>.self)
        case 0xE8:
            return AnyCPUInstruction(INX.self)
        case 0xC8:
            return AnyCPUInstruction(INY.self)
        case 0xC6:
            return AnyCPUInstruction(DEC<ZeroPage>.self)
        case 0xD6:
            return AnyCPUInstruction(DEC<ZeroPageX>.self)
        case 0xCE:
            return AnyCPUInstruction(DEC<Absolute>.self)
        case 0xDE:
            return AnyCPUInstruction(DEC<AbsoluteX>.self)
        case 0xCA:
            return AnyCPUInstruction(DEX.self)
        case 0x88:
            return AnyCPUInstruction(DEY.self)

        case 0x0A:
            return AnyCPUInstruction(ASLForAccumulator.self)
        case 0x06:
            return AnyCPUInstruction(ASL<ZeroPage>.self)
        case 0x16:
            return AnyCPUInstruction(ASL<ZeroPageX>.self)
        case 0x0E:
            return AnyCPUInstruction(ASL<Absolute>.self)
        case 0x1E:
            return AnyCPUInstruction(ASL<AbsoluteX>.self)
        case 0x4A:
            return AnyCPUInstruction(LSRForAccumulator.self)
        case 0x46:
            return AnyCPUInstruction(LSR<ZeroPage>.self)
        case 0x56:
            return AnyCPUInstruction(LSR<ZeroPageX>.self)
        case 0x4E:
            return AnyCPUInstruction(LSR<Absolute>.self)
        case 0x5E:
            return AnyCPUInstruction(LSR<AbsoluteX>.self)
        case 0x2A:
            return AnyCPUInstruction(ROLForAccumulator.self)
        case 0x26:
            return AnyCPUInstruction(ROL<ZeroPage>.self)
        case 0x36:
            return AnyCPUInstruction(ROL<ZeroPageX>.self)
        case 0x2E:
            return AnyCPUInstruction(ROL<Absolute>.self)
        case 0x3E:
            return AnyCPUInstruction(ROL<AbsoluteX>.self)
        case 0x6A:
            return AnyCPUInstruction(RORForAccumulator.self)
        case 0x66:
            return AnyCPUInstruction(ROR<ZeroPage>.self)
        case 0x76:
            return AnyCPUInstruction(ROR<ZeroPageX>.self)
        case 0x6E:
            return AnyCPUInstruction(ROR<Absolute>.self)
        case 0x7E:
            return AnyCPUInstruction(ROR<AbsoluteX>.self)

        case 0x4C:
            return AnyCPUInstruction(JMP<Absolute>.self)
        case 0x6C:
            return AnyCPUInstruction(JMP<Indirect>.self)
        case 0x20:
            return AnyCPUInstruction(JSR<Absolute>.self)
        case 0x60:
            return AnyCPUInstruction(RTS.self)
        case 0x40:
            return AnyCPUInstruction(RTI.self)

        case 0x90:
            return AnyCPUInstruction(BCC<Relative>.self)
        case 0xB0:
            return AnyCPUInstruction(BCS<Relative>.self)
        case 0xF0:
            return AnyCPUInstruction(BEQ<Relative>.self)
        case 0x30:
            return AnyCPUInstruction(BMI<Relative>.self)
        case 0xD0:
            return AnyCPUInstruction(BNE<Relative>.self)
        case 0x10:
            return AnyCPUInstruction(BPL<Relative>.self)
        case 0x50:
            return AnyCPUInstruction(BVC<Relative>.self)
        case 0x70:
            return AnyCPUInstruction(BVS<Relative>.self)

        case 0x18:
            return AnyCPUInstruction(CLC.self)
        case 0xD8:
            return AnyCPUInstruction(CLD.self)
        case 0x58:
            return AnyCPUInstruction(CLI.self)
        case 0xB8:
            return AnyCPUInstruction(CLV.self)

        case 0x38:
            return AnyCPUInstruction(SEC.self)
        case 0xF8:
            return AnyCPUInstruction(SED.self)
        case 0x78:
            return AnyCPUInstruction(SEI.self)

        case 0x00:
            return AnyCPUInstruction(BRK.self)

        // Undocumented

        case 0xEB:
            return AnyCPUInstruction(SBC<Immediate>.self)

        case 0x04, 0x44, 0x64:
            return AnyCPUInstruction(NOP<ZeroPage>.self)
        case 0x0C:
            return AnyCPUInstruction(NOP<Absolute>.self)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            return AnyCPUInstruction(NOP<ZeroPageX>.self)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            return AnyCPUInstruction(NOP<Implicit>.self)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            return AnyCPUInstruction(NOP<AbsoluteXWithPenalty>.self)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            return AnyCPUInstruction(NOP<Immediate>.self)

        case 0xA3:
            return AnyCPUInstruction(LAX<IndexedIndirect>.self)
        case 0xA7:
            return AnyCPUInstruction(LAX<ZeroPage>.self)
        case 0xAF:
            return AnyCPUInstruction(LAX<Absolute>.self)
        case 0xB3:
            return AnyCPUInstruction(LAX<IndirectIndexed>.self)
        case 0xB7:
            return AnyCPUInstruction(LAX<ZeroPageY>.self)
        case 0xBF:
            return AnyCPUInstruction(LAX<AbsoluteYWithPenalty>.self)

        case 0x83:
            return AnyCPUInstruction(SAX<IndexedIndirect>.self)
        case 0x87:
            return AnyCPUInstruction(SAX<ZeroPage>.self)
        case 0x8F:
            return AnyCPUInstruction(SAX<Absolute>.self)
        case 0x97:
            return AnyCPUInstruction(SAX<ZeroPageY>.self)

        case 0xC3:
            return AnyCPUInstruction(DCP<IndexedIndirect>.self)
        case 0xC7:
            return AnyCPUInstruction(DCP<ZeroPage>.self)
        case 0xCF:
            return AnyCPUInstruction(DCP<Absolute>.self)
        case 0xD3:
            return AnyCPUInstruction(DCP<IndirectIndexed>.self)
        case 0xD7:
            return AnyCPUInstruction(DCP<ZeroPageX>.self)
        case 0xDB:
            return AnyCPUInstruction(DCP<AbsoluteY>.self)
        case 0xDF:
            return AnyCPUInstruction(DCP<AbsoluteX>.self)

        case 0xE3:
            return AnyCPUInstruction(ISB<IndexedIndirect>.self)
        case 0xE7:
            return AnyCPUInstruction(ISB<ZeroPage>.self)
        case 0xEF:
            return AnyCPUInstruction(ISB<Absolute>.self)
        case 0xF3:
            return AnyCPUInstruction(ISB<IndirectIndexed>.self)
        case 0xF7:
            return AnyCPUInstruction(ISB<ZeroPageX>.self)
        case 0xFB:
            return AnyCPUInstruction(ISB<AbsoluteY>.self)
        case 0xFF:
            return AnyCPUInstruction(ISB<AbsoluteX>.self)

        case 0x03:
            return AnyCPUInstruction(SLO<IndexedIndirect>.self)
        case 0x07:
            return AnyCPUInstruction(SLO<ZeroPage>.self)
        case 0x0F:
            return AnyCPUInstruction(SLO<Absolute>.self)
        case 0x13:
            return AnyCPUInstruction(SLO<IndirectIndexed>.self)
        case 0x17:
            return AnyCPUInstruction(SLO<ZeroPageX>.self)
        case 0x1B:
            return AnyCPUInstruction(SLO<AbsoluteY>.self)
        case 0x1F:
            return AnyCPUInstruction(SLO<AbsoluteX>.self)

        case 0x23:
            return AnyCPUInstruction(RLA<IndexedIndirect>.self)
        case 0x27:
            return AnyCPUInstruction(RLA<ZeroPage>.self)
        case 0x2F:
            return AnyCPUInstruction(RLA<Absolute>.self)
        case 0x33:
            return AnyCPUInstruction(RLA<IndirectIndexed>.self)
        case 0x37:
            return AnyCPUInstruction(RLA<ZeroPageX>.self)
        case 0x3B:
            return AnyCPUInstruction(RLA<AbsoluteY>.self)
        case 0x3F:
            return AnyCPUInstruction(RLA<AbsoluteX>.self)

        case 0x43:
            return AnyCPUInstruction(SRE<IndexedIndirect>.self)
        case 0x47:
            return AnyCPUInstruction(SRE<ZeroPage>.self)
        case 0x4F:
            return AnyCPUInstruction(SRE<Absolute>.self)
        case 0x53:
            return AnyCPUInstruction(SRE<IndirectIndexed>.self)
        case 0x57:
            return AnyCPUInstruction(SRE<ZeroPageX>.self)
        case 0x5B:
            return AnyCPUInstruction(SRE<AbsoluteY>.self)
        case 0x5F:
            return AnyCPUInstruction(SRE<AbsoluteX>.self)

        case 0x63:
            return AnyCPUInstruction(RRA<IndexedIndirect>.self)
        case 0x67:
            return AnyCPUInstruction(RRA<ZeroPage>.self)
        case 0x6F:
            return AnyCPUInstruction(RRA<Absolute>.self)
        case 0x73:
            return AnyCPUInstruction(RRA<IndirectIndexed>.self)
        case 0x77:
            return AnyCPUInstruction(RRA<ZeroPageX>.self)
        case 0x7B:
            return AnyCPUInstruction(RRA<AbsoluteY>.self)
        case 0x7F:
            return AnyCPUInstruction(RRA<AbsoluteX>.self)

        default:
            return AnyCPUInstruction(NOP<Implicit>.self)
        }
    }
}

class AnyCPUInstruction<CPU: NES2.CPU> {
    private let _execute: ((inout CPU, inout CPURegister, inout CPU.Bus) -> ())

    init<CI: CPUInstruction>(_ instruction: CI.Type) {
        _execute = CI.execute
    }

    func execute(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        _execute(&cpu, &register, &bus)
    }
}

protocol CPUInstruction {
    associatedtype AddressingMode: NES2.AddressingMode

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus)
}

// MARK: - Operations

// Implements for Load/Store Operations

/// loadAccumulator
enum LDA<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        register.A = cpu.cpuRead(at: operand, from: &bus)
    }
}

/// loadXRegister
enum LDX<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        register.X = cpu.cpuRead(at: operand, from: &bus)
    }
}

/// loadYRegister
enum LDY<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        register.Y = cpu.cpuRead(at: operand, from: &bus)
    }
}

/// storeAccumulator
enum STA<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        cpu.cpuWrite(register.A, at: operand, to: &bus)
    }
}

enum STAWithTick<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        cpu.cpuWrite(register.A, at: operand, to: &bus)
        cpu.cpuTick()
    }
}

/// storeXRegister
enum STX<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        cpu.cpuWrite(register.X, at: operand, to: &bus)
    }
}

/// storeYRegister
enum STY<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        cpu.cpuWrite(register.Y, at: operand, to: &bus)
    }
}

// MARK: - Register Operations

/// transferAccumulatorToX
enum TAX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.X = register.A
        cpu.cpuTick()
    }
}

/// transferStackPointerToX
enum TSX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.X = register.S
        cpu.cpuTick()
    }
}

/// transferAccumulatorToY
enum TAY: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.Y = register.A
        cpu.cpuTick()
    }
}

/// transferXtoAccumulator
enum TXA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.A = register.X
        cpu.cpuTick()
    }
}

/// transferXtoStackPointer
enum TXS: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.S = register.X
        cpu.cpuTick()
    }
}

/// transferYtoAccumulator
enum TYA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.A = register.Y
        cpu.cpuTick()
    }
}

// MARK: - Stack instructions

/// pushAccumulator
enum PHA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        cpu.pushStack(register.A, register: &register, to: &bus)
        cpu.cpuTick()
    }
}

/// pushProcessorStatus
enum PHP: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.pushStack(register.P.rawValue | CPU.Status.operatedB.rawValue, register: &register, to: &bus)
        cpu.cpuTick()
    }
}

/// pullAccumulator
enum PLA: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.A = cpu.pullStack(register: &register, from: &bus)
        cpu.cpuTick(count: 2)
    }
}

/// pullProcessorStatus
enum PLP: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        register.P = CPU.Status(rawValue: cpu.pullStack(register: &register, from: &bus) & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
        cpu.cpuTick(count: 2)
    }
}

    // MARK: - Logical instructions

/// bitwiseANDwithAccumulator
enum AND<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        register.A &= cpu.cpuRead(at: operand, from: &bus)
    }
}

func executeAND<CPU: NES2.CPU>(operand: CPU.Operand, cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
    register.A &= cpu.cpuRead(at: operand, from: &bus)
}

/// bitwiseExclusiveOR
enum EOR<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        executeEOR(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

func executeEOR<CPU: NES2.CPU>(operand: CPU.Operand, cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
    register.A ^= cpu.cpuRead(at: operand, from: &bus)
}


/// bitwiseORwithAccumulator
enum ORA<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        executeORA(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

func executeORA<CPU: NES2.CPU>(operand: CPU.Operand, cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
    register.A |= cpu.cpuRead(at: operand, from: &bus)
}

/// testBits
enum BIT<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        let value = cpu.cpuRead(at: operand, from: &bus)
        let data = register.A & value
        register.P.remove([.Z, .V, .N])
        if data == 0 {
            register.P.formUnion(.Z)
        } else {
            register.P.remove(.Z)
        }
        if value[6] == 1 {
            register.P.formUnion(.V)
        } else {
            register.P.remove(.V)
        }
        if value[7] == 1 {
            register.P.formUnion(.N)
        } else {
            register.P.remove(.N)
        }
    }
}


// MARK: - Arithmetic instructions

/// addWithCarry
enum ADC<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)
        executeAOR(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}


func executeAOR<CPU: NES2.CPU>(operand: CPU.Operand, cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
    let a = register.A
    let val = cpu.cpuRead(at: operand, from: &bus)
    var result = a &+ val

    if register.P.contains(.C) {
        result &+= 1
    }

    register.P.remove([.C, .Z, .V, .N])

    // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    let a7 = a[7]
    let v7 = val[7]
    let c6 = a7 ^ v7 ^ result[7]
    let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

    if c7 == 1 {
        register.P.formUnion(.C)
    }
    if c6 ^ c7 == 1 {
        register.P.formUnion(.V)
    }

    register.A = result
}

/// subtractWithCarry
enum SBC<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        let a = register.A
        let val = ~cpu.cpuRead(at: operand, from: &bus)
        var result = a &+ val

        if register.P.contains(.C) {
            result &+= 1
        }

        register.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 {
            register.P.formUnion(.C)
        }
        if c6 ^ c7 == 1 {
            register.P.formUnion(.V)
        }

        register.A = result
    }
}


func executeSBC<CPU: NES2.CPU>(operand: CPU.Operand, cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
    let a = register.A
    let val = ~cpu.cpuRead(at: operand, from: &bus)
    var result = a &+ val

    if register.P.contains(.C) {
        result &+= 1
    }

    register.P.remove([.C, .Z, .V, .N])

    // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    let a7 = a[7]
    let v7 = val[7]
    let c6 = a7 ^ v7 ^ result[7]
    let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

    if c7 == 1 {
        register.P.formUnion(.C)
    }
    if c6 ^ c7 == 1 {
        register.P.formUnion(.V)
    }

    register.A = result
}

/// compareAccumulator
enum CMP<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        executeCMP(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

func executeCMP<CPU: NES2.CPU>(operand: CPU.Operand, cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
    let cmp = Int16(register.A) &- Int16(cpu.cpuRead(at: operand, from: &bus))

    register.P.remove([.C, .Z, .N])
    register.P.setZN(cmp)
    if 0 <= cmp {
        register.P.formUnion(.C)
    } else {
        register.P.remove(.C)
    }
}

/// compareXRegister
enum CPX<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        let value = cpu.cpuRead(at: operand, from: &bus)
        let cmp = register.X &- value

        register.P.remove([.C, .Z, .N])
        register.P.setZN(cmp)
        if register.X >= value {
            register.P.formUnion(.C)
        } else {
            register.P.remove(.C)
        }
    }
}

/// compareYRegister
enum CPY<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        let value = cpu.cpuRead(at: operand, from: &bus)
        let cmp = register.Y &- value

        register.P.remove([.C, .Z, .N])
        register.P.setZN(cmp)
        if register.Y >= value {
            register.P.formUnion(.C)
        } else {
            register.P.remove(.C)
        }
    }
}

// MARK: - Increment/Decrement instructions

/// incrementMemory
enum INC<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        let result = cpu.cpuRead(at: operand, from: &bus) &+ 1

        register.P.setZN(result)
        cpu.cpuWrite(result, at: operand, to: &bus)

        cpu.cpuTick()
    }
}

/// incrementX
enum INX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.X = register.X &+ 1
        cpu.cpuTick()
    }
}

/// incrementY
enum INY: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.Y = register.Y &+ 1
        cpu.cpuTick()
    }
}

/// decrementMemory
enum DEC<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        let result = cpu.cpuRead(at: operand, from: &bus) &- 1
        register.P.setZN(result)

        cpu.cpuWrite(result, at: operand, to: &bus)
        cpu.cpuTick()
    }
}

/// decrementX
enum DEX: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.X = register.X &- 1
        cpu.cpuTick()
    }
}

/// decrementY
enum DEY: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.Y = register.Y &- 1
        cpu.cpuTick()
    }
}


// MARK: - Shift instructions

/// arithmeticShiftLeft
enum ASL<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        var data = cpu.cpuRead(at: operand, from: &bus)

        register.P.remove([.C, .Z, .N])
        if data[7] == 1 {
            register.P.formUnion(.C)
        }

        data <<= 1

        register.P.setZN(data)

        cpu.cpuWrite(data, at: operand, to: &bus)

        cpu.cpuTick()
    }
}

enum ASLForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.remove([.C, .Z, .N])
        if register.A[7] == 1 {
            register.P.formUnion(.C)
        }

        register.A <<= 1

        cpu.cpuTick()
    }
}

/// logicalShiftRight
enum LSR<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        var data = cpu.cpuRead(at: operand, from: &bus)

        register.P.remove([.C, .Z, .N])
        if data[0] == 1 {
            register.P.formUnion(.C)
        }

        data >>= 1

        register.P.setZN(data)

        cpu.cpuWrite(data, at: operand, to: &bus)

        cpu.cpuTick()
    }
}

enum LSRForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.remove([.C, .Z, .N])
        if register.A[0] == 1 {
            register.P.formUnion(.C)
        }

        register.A >>= 1

        cpu.cpuTick()
    }
}

/// rotateLeft
enum ROL<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        var data = cpu.cpuRead(at: operand, from: &bus)
        let c = data & 0x80

        data <<= 1
        if register.P.contains(.C) {
            data |= 0x01
        }

        register.P.remove([.C, .Z, .N])
        if c == 0x80 {
            register.P.formUnion(.C)
        }

        register.P.setZN(data)

        cpu.cpuWrite(data, at: operand, to: &bus)

        cpu.cpuTick()
    }
}

enum ROLForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let c = register.A & 0x80

        var a = register.A << 1
        if register.P.contains(.C) {
            a |= 0x01
        }

        register.P.remove([.C, .Z, .N])
        if c == 0x80 {
            register.P.formUnion(.C)
        }

        register.A = a

        cpu.cpuTick()
    }
}

/// rotateRight
enum ROR<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        var data = cpu.cpuRead(at: operand, from: &bus)
        let c = data & 0x01

        data >>= 1
        if register.P.contains(.C) {
            data |= 0x80
        }

        register.P.remove([.C, .Z, .N])
        if c == 1 {
            register.P.formUnion(.C)
        }

        register.P.setZN(data)

        cpu.cpuWrite(data, at: operand, to: &bus)

        cpu.cpuTick()
    }
}

enum RORForAccumulator: CPUInstruction {
    typealias AddressingMode = Accumulator

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let c = register.A & 0x01

        var a = register.A >> 1
        if register.P.contains(.C) {
            a |= 0x80
        }

        register.P.remove([.C, .Z, .N])
        if c == 1 {
            register.P.formUnion(.C)
        }

        register.A = a

        cpu.cpuTick()
    }
}

// MARK: - Jump instructions

/// jump
enum JMP<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        register.PC = operand
    }
}

/// jumpToSubroutine
enum JSR<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.pushStack(word: register.PC &- 1, register: &register, to: &bus)
        cpu.cpuTick()
        register.PC = operand
    }
}

/// returnFromSubroutine
enum RTS: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        cpu.cpuTick(count: 3)
        register.PC = cpu.pullStack(register: &register, from: &bus) &+ 1
    }
}

/// returnFromInterrupt
enum RTI: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.cpuTick(count: 2)
        register.P = CPU.Status(rawValue: cpu.pullStack(register: &register, from: &bus) & ~CPU.Status.B.rawValue | CPU.Status.R.rawValue)
        register.PC = cpu.pullStack(register: &register, from: &bus)
    }
}


// MARK: - Branch instructions

/// branchIfCarryClear
enum BCC<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: !register.P.contains(.C), register: &register, with: &bus)
    }
}

/// branchIfCarrySet
enum BCS<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: register.P.contains(.C), register: &register, with: &bus)
    }
}

/// branchIfEqual
enum BEQ<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: register.P.contains(.Z), register: &register, with: &bus)
    }
}

/// branchIfMinus
enum BMI<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: register.P.contains(.N), register: &register, with: &bus)
    }
}

/// branchIfNotEqual
enum BNE<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: !register.P.contains(.Z), register: &register, with: &bus)
    }
}

/// branchIfPlus
enum BPL<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: !register.P.contains(.N), register: &register, with: &bus)
    }
}

/// branchIfOverflowClear
enum BVC<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: !register.P.contains(.V), register: &register, with: &bus)
    }

}

/// branchIfOverflowSet
enum BVS<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.branch(operand: operand, test: register.P.contains(.V), register: &register, with: &bus)
    }
}


// MARK: - Flag control instructions

/// clearCarry
enum CLC: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.remove(.C)
        cpu.cpuTick()
    }
}

/// clearDecimal
enum CLD: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.remove(.D)
        cpu.cpuTick()
    }
}

/// clearInterrupt
enum CLI: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.remove(.I)
        cpu.cpuTick()
    }
}

/// clearOverflow
enum CLV: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.remove(.V)
        cpu.cpuTick()
    }
}

/// setCarryFlag
enum SEC: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.formUnion(.C)
        cpu.cpuTick()
    }
}

/// setDecimalFlag
enum SED: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.formUnion(.D)
        cpu.cpuTick()
    }
}

/// setInterruptDisable
enum SEI: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        register.P.formUnion(.I)
        cpu.cpuTick()
    }
}

// MARK: - Misc

/// forceInterrupt
enum BRK: CPUInstruction {
    typealias AddressingMode = Implicit

    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        cpu.pushStack(word: register.PC, register: &register, to: &bus)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.pushStack(register.P.rawValue | CPU.Status.interruptedB.rawValue, register: &register, to: &bus)
        cpu.cpuTick()
        register.PC = cpu.cpuReadWord(at: 0xFFFE, from: &bus)
    }
}

/// doNothing
enum NOP<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let _ = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.cpuTick()
    }
}


// MARK: - Unofficial

/// loadAccumulatorAndX
enum LAX<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        let data = cpu.cpuRead(at: operand, from: &bus)
        register.A = data
        register.X = data
    }
}

/// storeAccumulatorAndX
enum SAX<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        cpu.cpuWrite(register.A & register.X, at: operand, to: &bus)
    }
}

/// decrementMemoryAndCompareAccumulator
enum DCP<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        // decrementMemory excluding tick
        let result = cpu.cpuRead(at: operand, from: &bus) &- 1
        register.P.setZN(result)
        cpu.cpuWrite(result, at: operand, to: &bus)

        executeCMP(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

/// incrementMemoryAndSubtractWithCarry
enum ISB<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        // incrementMemory excluding tick
        let result = cpu.cpuRead(at: operand, from: &bus) &+ 1
        register.P.setZN(result)
        cpu.cpuWrite(result, at: operand, to: &bus)

        executeSBC(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

/// arithmeticShiftLeftAndBitwiseORwithAccumulator
enum SLO<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        // arithmeticShiftLeft excluding tick
        var data = cpu.cpuRead(at: operand, from: &bus)
        register.P.remove([.C, .Z, .N])
        if data[7] == 1 {
            register.P.formUnion(.C)
        }

        data <<= 1
        register.P.setZN(data)
        cpu.cpuWrite(data, at: operand, to: &bus)

        executeORA(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

/// rotateLeftAndBitwiseANDwithAccumulator
enum RLA<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        // rotateLeft excluding tick
        var data = cpu.cpuRead(at: operand, from: &bus)
        let c = data & 0x80

        data <<= 1
        if register.P.contains(.C) {
            data |= 0x01
        }

        register.P.remove([.C, .Z, .N])
        if c == 0x80 {
            register.P.formUnion(.C)
        }

        register.P.setZN(data)
        cpu.cpuWrite(data, at: operand, to: &bus)

        executeAND(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

/// logicalShiftRightAndBitwiseExclusiveOR
enum SRE<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        // logicalShiftRight excluding tick
        var data = cpu.cpuRead(at: operand, from: &bus)
        register.P.remove([.C, .Z, .N])
        if data[0] == 1 {
            register.P.formUnion(.C)
        }

        data >>= 1

        register.P.setZN(data)
        cpu.cpuWrite(data, at: operand, to: &bus)

        executeEOR(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

/// rotateRightAndAddWithCarry
enum RRA<AddressingMode: NES2.AddressingMode>: CPUInstruction {
    static func execute<CPU: NES2.CPU>(cpu: inout CPU, register: inout CPURegister, bus: inout CPU.Bus) {
        let operand = AddressingMode.getOperand(cpu: &cpu, register: &register, with: &bus)

        // rotateRight excluding tick
        var data = cpu.cpuRead(at: operand, from: &bus)
        let c = data & 0x01

        data >>= 1
        if register.P.contains(.C) {
            data |= 0x80
        }

        register.P.remove([.C, .Z, .N])
        if c == 1 {
            register.P.formUnion(.C)
        }

        register.P.setZN(data)
        cpu.cpuWrite(data, at: operand, to: &bus)

        executeAOR(operand: operand, cpu: &cpu, register: &register, bus: &bus)
    }
}

extension CPU {

    mutating func branch(operand: Operand, test: Bool, register: inout Register, with bus: inout Bus) {
        if test {
            cpuTick()
            let pc = Int(register.PC)
            let offset = Int(operand.i8)
            if pageCrossed(value: pc, operand: offset) {
                cpuTick()
            }
            register.PC = UInt16(pc &+ offset)
        }
    }
}

extension CPU {
    @inline(__always)
    mutating func pushStack(_ value: UInt8, register: inout Register, to bus: inout Bus) {
        cpuWrite(value, at: register.S.u16 &+ 0x100, to: &bus)
        register.S &-= 1
    }

    @inline(__always)
    mutating func pushStack(word: UInt16, register: inout Register, to bus: inout Bus) {
        pushStack(UInt8(word >> 8), register: &register, to: &bus)
        pushStack(UInt8(word & 0xFF), register: &register, to: &bus)
    }

    @inline(__always)
    mutating func pullStack(register: inout Register, from bus: inout Bus) -> UInt8 {
        register.S &+= 1
        return cpuRead(at: register.S.u16 &+ 0x100, from: &bus)
    }

    @inline(__always)
    mutating func pullStack(register: inout Register, from bus: inout Bus) -> UInt16 {
        let lo: UInt8 = pullStack(register: &register, from: &bus)
        let ho: UInt8 = pullStack(register: &register, from: &bus)
        return ho.u16 &<< 8 | lo.u16
    }
}
