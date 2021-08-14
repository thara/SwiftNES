// swiftlint:disable file_length

class Disassembler {
    // http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
    enum AddressingMode {
        case implicit, accumulator, immediate
        case zeroPage, zeroPageX, zeroPageY
        case absolute, absoluteX, absoluteY
        case relative, indirect, indexedIndirect, indirectIndexed
    }

    // http://obelisk.me.uk/6502/reference.html
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

    struct CPUStep {
        var pc: UInt16 = 0x00
        var operand1: UInt8 = 0x00
        var operand2: UInt8 = 0x00
        var state: CPU
        var operand16: UInt16 {
            return operand1.u16 | (operand2.u16 << 8)
        }
    }

    struct Instruction {
        let opcode: UInt8
        let mnemonic: Mnemonic
        let addressingMode: AddressingMode
    }

    static func disassemble(cpu: inout CPU) -> (machineCode: String, assemblyCode: String) {
        let currentStep = makeCurrentStep(cpu: &cpu)
        let opcode = cpu.bus.read(at: currentStep.pc)
        let instruction = instructionTable[Int(opcode)]
        return (
            makeMachineCode(step: currentStep, instruction: instruction),
            makeAssemblyCode(step: currentStep, instruction: instruction, cpu: &cpu)
        )
    }

    private static func makeCurrentStep(cpu: inout CPU) -> CPUStep {
        let pc = cpu.PC
        return CPUStep(
            pc: cpu.PC,
            operand1: cpu.bus.read(at: pc &+ 1),
            operand2: cpu.bus.read(at: pc &+ 2),
            state: cpu
        )
    }

    private static func makeMachineCode(step: CPUStep, instruction: Instruction) -> String {
        switch instruction.addressingMode {
        case .immediate, .zeroPage, .zeroPageX, .zeroPageY, .relative, .indirectIndexed, .indexedIndirect:
            return "\(instruction.opcode.hex2) \(step.operand1.hex2)"
        case .indirect, .absolute, .absoluteX, .absoluteY:
            return "\(instruction.opcode.hex2) \(step.operand1.hex2) \(step.operand2.hex2)"
        default:
            return "\(instruction.opcode.hex2)"
        }
    }

    private static func makeAssemblyCode(step: CPUStep, instruction: Instruction, cpu: inout CPU) -> String {
        let operandString = makeAssemblyOperand(step: step, instruction: instruction, cpu: &cpu)
        let prefix = undocumentedOpcodes.contains(Int(instruction.opcode)) ? "*" : " "
        return "\(prefix)\(instruction.mnemonic) \(operandString)"
    }

    private static func makeAssemblyOperand(step: CPUStep, instruction: Instruction, cpu: inout CPU) -> String {
        switch instruction.mnemonic {
        case .JMP, .JSR:
            if case .absolute = instruction.addressingMode {
                let address = decodeAddress(step: step, addressingMode: instruction.addressingMode, cpu: &cpu)
                return String(format: "$%04X", address)
            }
        case .LSR, .ASL, .ROR, .ROL:
            if case .accumulator = instruction.addressingMode {
                return "A"
            }
        default:
            break
        }
        return makeAssemblyOperand(step: step, addressingMode: instruction.addressingMode, cpu: &cpu)
    }

    // swiftlint:disable cyclomatic_complexity
    private static func makeAssemblyOperand(step: CPUStep, addressingMode: AddressingMode, cpu: inout CPU) -> String {
        let operand1 = step.operand1
        let operand16 = step.operand16
        let x = step.state.X
        let y = step.state.Y

        switch addressingMode {
        case .implicit, .accumulator:
            return " "
        case .immediate:
            return String(format: "#$%02X", operand1)
        case .zeroPage:
            return String(format: "$%02X = %02X", operand1, cpu.bus.read(at: operand1.u16))
        case .zeroPageX:
            return String(
                format: "$%02X,X @ %02X = %02X", operand1, operand1 &+ x, cpu.bus.read(at: (operand1 &+ x).u16))
        case .zeroPageY:
            return String(
                format: "$%02X,Y @ %02X = %02X", operand1, operand1 &+ y, cpu.bus.read(at: (operand1 &+ y).u16))
        case .absolute:
            return String(format: "$%04X = %02X", operand16, cpu.bus.read(at: operand16))
        case .absoluteX:
            return String(
                format: "$%04X,X @ %04X = %02X", operand16, operand16 &+ x.u16, cpu.bus.read(at: operand16 &+ x.u16))
        case .absoluteY:
            return String(
                format: "$%04X,Y @ %04X = %02X", operand16, operand16 &+ y.u16, cpu.bus.read(at: operand16 &+ y.u16))
        case .relative:
            return String(format: "$%04X", Int(step.pc) &+ 2 &+ Int(operand1.i8))
        case .indirect:
            return String(format: "($%04X) = %04X", operand16, cpu.bus.readOnIndirect(operand: operand16))
        case .indexedIndirect:
            let operandX = x &+ operand1
            let address = cpu.bus.readOnIndirect(operand: operandX.u16)
            return String(
                format: "($%02X,X) @ %02X = %04X = %02X", operand1, operandX, address, cpu.bus.read(at: address))
        case .indirectIndexed:
            let data = cpu.bus.readOnIndirect(operand: operand1.u16)
            return String(
                format: "($%02X),Y = %04X @ %04X = %02X", operand1, data, data &+ y.u16, cpu.bus.read(at: data &+ y.u16)
            )
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private static func decodeAddress(step: CPUStep, addressingMode: AddressingMode, cpu: inout CPU) -> UInt16 {
        switch addressingMode {
        case .implicit:
            return 0x00
        case .immediate:
            return step.pc
        case .zeroPage:
            return step.operand1.u16
        case .zeroPageX:
            return (step.operand1 &+ step.state.X).u16 & 0xFF
        case .zeroPageY:
            return (step.operand1 &+ step.state.Y).u16 & 0xFF
        case .absolute:
            return step.operand16
        case .absoluteX:
            return step.operand16 &+ step.state.X.u16
        case .absoluteY:
            return step.operand16 &+ step.state.Y.u16
        case .relative:
            return step.pc
        case .indirect:
            return cpu.bus.readOnIndirect(operand: step.operand16)
        case .indirectIndexed:
            return cpu.bus.readOnIndirect(operand: (step.operand16 &+ step.state.X.u16) & 0xFF)
        case .indexedIndirect:
            return cpu.bus.readOnIndirect(operand: step.operand16) &+ step.state.Y.u16
        default:
            return 0x00
        }
    }

    private static let instructionTable: [Disassembler.Instruction] = {
        var table: [Disassembler.Instruction?] = Array(repeating: nil, count: 0x100)
        for i in 0x00...0xFF {
            let opcode = OpCode(i)
            let (mnemonic, addressingMode) = decodeInstruction(for: opcode)
            table[i] = Disassembler.Instruction(opcode: opcode, mnemonic: mnemonic, addressingMode: addressingMode)
        }
        return table.compactMap { $0 }
    }()

    // swiftlint:disable cyclomatic_complexity function_body_length
    private static func decodeInstruction(for opcode: UInt8) -> (Disassembler.Mnemonic, Disassembler.AddressingMode) {
        switch opcode {
        case 0xA9: return (.LDA, .immediate)
        case 0xA5: return (.LDA, .zeroPage)
        case 0xB5: return (.LDA, .zeroPageX)
        case 0xAD: return (.LDA, .absolute)
        case 0xBD: return (.LDA, .absoluteX)
        case 0xB9: return (.LDA, .absoluteY)
        case 0xA1: return (.LDA, .indexedIndirect)
        case 0xB1: return (.LDA, .indirectIndexed)
        case 0xA2: return (.LDX, .immediate)
        case 0xA6: return (.LDX, .zeroPage)
        case 0xB6: return (.LDX, .zeroPageY)
        case 0xAE: return (.LDX, .absolute)
        case 0xBE: return (.LDX, .absoluteY)
        case 0xA0: return (.LDY, .immediate)
        case 0xA4: return (.LDY, .zeroPage)
        case 0xB4: return (.LDY, .zeroPageX)
        case 0xAC: return (.LDY, .absolute)
        case 0xBC: return (.LDY, .absoluteX)
        case 0x85: return (.STA, .zeroPage)
        case 0x95: return (.STA, .zeroPageX)
        case 0x8D: return (.STA, .absolute)
        case 0x9D: return (.STA, .absoluteX)
        case 0x99: return (.STA, .absoluteY)
        case 0x81: return (.STA, .indexedIndirect)
        case 0x91: return (.STA, .indirectIndexed)
        case 0x86: return (.STX, .zeroPage)
        case 0x96: return (.STX, .zeroPageY)
        case 0x8E: return (.STX, .absolute)
        case 0x84: return (.STY, .zeroPage)
        case 0x94: return (.STY, .zeroPageX)
        case 0x8C: return (.STY, .absolute)
        case 0xAA: return (.TAX, .implicit)
        case 0xBA: return (.TSX, .implicit)
        case 0xA8: return (.TAY, .implicit)
        case 0x8A: return (.TXA, .implicit)
        case 0x9A: return (.TXS, .implicit)
        case 0x98: return (.TYA, .implicit)
        case 0x48: return (.PHA, .implicit)
        case 0x08: return (.PHP, .implicit)
        case 0x68: return (.PLA, .implicit)
        case 0x28: return (.PLP, .implicit)

        case 0x29: return (.AND, .immediate)
        case 0x25: return (.AND, .zeroPage)
        case 0x35: return (.AND, .zeroPageX)
        case 0x2D: return (.AND, .absolute)
        case 0x3D: return (.AND, .absoluteX)
        case 0x39: return (.AND, .absoluteY)
        case 0x21: return (.AND, .indexedIndirect)
        case 0x31: return (.AND, .indirectIndexed)
        case 0x49: return (.EOR, .immediate)
        case 0x45: return (.EOR, .zeroPage)
        case 0x55: return (.EOR, .zeroPageX)
        case 0x4D: return (.EOR, .absolute)
        case 0x5D: return (.EOR, .absoluteX)
        case 0x59: return (.EOR, .absoluteY)
        case 0x41: return (.EOR, .indexedIndirect)
        case 0x51: return (.EOR, .indirectIndexed)
        case 0x09: return (.ORA, .immediate)
        case 0x05: return (.ORA, .zeroPage)
        case 0x15: return (.ORA, .zeroPageX)
        case 0x0D: return (.ORA, .absolute)
        case 0x1D: return (.ORA, .absoluteX)
        case 0x19: return (.ORA, .absoluteY)
        case 0x01: return (.ORA, .indexedIndirect)
        case 0x11: return (.ORA, .indirectIndexed)
        case 0x24: return (.BIT, .zeroPage)
        case 0x2C: return (.BIT, .absolute)

        case 0x69: return (.ADC, .immediate)
        case 0x65: return (.ADC, .zeroPage)
        case 0x75: return (.ADC, .zeroPageX)
        case 0x6D: return (.ADC, .absolute)
        case 0x7D: return (.ADC, .absoluteX)
        case 0x79: return (.ADC, .absoluteY)
        case 0x61: return (.ADC, .indexedIndirect)
        case 0x71: return (.ADC, .indirectIndexed)
        case 0xE9: return (.SBC, .immediate)
        case 0xE5: return (.SBC, .zeroPage)
        case 0xF5: return (.SBC, .zeroPageX)
        case 0xED: return (.SBC, .absolute)
        case 0xFD: return (.SBC, .absoluteX)
        case 0xF9: return (.SBC, .absoluteY)
        case 0xE1: return (.SBC, .indexedIndirect)
        case 0xF1: return (.SBC, .indirectIndexed)
        case 0xC9: return (.CMP, .immediate)
        case 0xC5: return (.CMP, .zeroPage)
        case 0xD5: return (.CMP, .zeroPageX)
        case 0xCD: return (.CMP, .absolute)
        case 0xDD: return (.CMP, .absoluteX)
        case 0xD9: return (.CMP, .absoluteY)
        case 0xC1: return (.CMP, .indexedIndirect)
        case 0xD1: return (.CMP, .indirectIndexed)
        case 0xE0: return (.CPX, .immediate)
        case 0xE4: return (.CPX, .zeroPage)
        case 0xEC: return (.CPX, .absolute)
        case 0xC0: return (.CPY, .immediate)
        case 0xC4: return (.CPY, .zeroPage)
        case 0xCC: return (.CPY, .absolute)

        case 0xE6: return (.INC, .zeroPage)
        case 0xF6: return (.INC, .zeroPageX)
        case 0xEE: return (.INC, .absolute)
        case 0xFE: return (.INC, .absoluteX)
        case 0xE8: return (.INX, .implicit)
        case 0xC8: return (.INY, .implicit)
        case 0xC6: return (.DEC, .zeroPage)
        case 0xD6: return (.DEC, .zeroPageX)
        case 0xCE: return (.DEC, .absolute)
        case 0xDE: return (.DEC, .absoluteX)
        case 0xCA: return (.DEX, .implicit)
        case 0x88: return (.DEY, .implicit)

        case 0x0A: return (.ASL, .accumulator)
        case 0x06: return (.ASL, .zeroPage)
        case 0x16: return (.ASL, .zeroPageX)
        case 0x0E: return (.ASL, .absolute)
        case 0x1E: return (.ASL, .absoluteX)
        case 0x4A: return (.LSR, .accumulator)
        case 0x46: return (.LSR, .zeroPage)
        case 0x56: return (.LSR, .zeroPageX)
        case 0x4E: return (.LSR, .absolute)
        case 0x5E: return (.LSR, .absoluteX)
        case 0x2A: return (.ROL, .accumulator)
        case 0x26: return (.ROL, .zeroPage)
        case 0x36: return (.ROL, .zeroPageX)
        case 0x2E: return (.ROL, .absolute)
        case 0x3E: return (.ROL, .absoluteX)
        case 0x6A: return (.ROR, .accumulator)
        case 0x66: return (.ROR, .zeroPage)
        case 0x76: return (.ROR, .zeroPageX)
        case 0x6E: return (.ROR, .absolute)
        case 0x7E: return (.ROR, .absoluteX)

        case 0x4C: return (.JMP, .absolute)
        case 0x6C: return (.JMP, .indirect)
        case 0x20: return (.JSR, .absolute)
        case 0x60: return (.RTS, .implicit)
        case 0x40: return (.RTI, .implicit)

        case 0x90: return (.BCC, .relative)
        case 0xB0: return (.BCS, .relative)
        case 0xF0: return (.BEQ, .relative)
        case 0x30: return (.BMI, .relative)
        case 0xD0: return (.BNE, .relative)
        case 0x10: return (.BPL, .relative)
        case 0x50: return (.BVC, .relative)
        case 0x70: return (.BVS, .relative)

        case 0x18: return (.CLC, .implicit)
        case 0xD8: return (.CLD, .implicit)
        case 0x58: return (.CLI, .implicit)
        case 0xB8: return (.CLV, .implicit)

        case 0x38: return (.SEC, .implicit)
        case 0xF8: return (.SED, .implicit)
        case 0x78: return (.SEI, .implicit)

        case 0x00: return (.BRK, .implicit)

        // Undocumented

        case 0xEB: return (.SBC, .immediate)

        case 0x04, 0x44, 0x64: return (.NOP, .zeroPage)

        case 0xA3: return (.LAX, .indexedIndirect)
        case 0xA7: return (.LAX, .zeroPage)
        case 0xAF: return (.LAX, .absolute)
        case 0xB3: return (.LAX, .indirectIndexed)
        case 0xB7: return (.LAX, .zeroPageY)
        case 0xBF: return (.LAX, .absoluteY)

        case 0x83: return (.SAX, .indexedIndirect)
        case 0x87: return (.SAX, .zeroPage)
        case 0x8F: return (.SAX, .absolute)
        case 0x97: return (.SAX, .zeroPageY)

        case 0xC3: return (.DCP, .indexedIndirect)
        case 0xC7: return (.DCP, .zeroPage)
        case 0xCF: return (.DCP, .absolute)
        case 0xD3: return (.DCP, .indirectIndexed)
        case 0xD7: return (.DCP, .zeroPageX)
        case 0xDB: return (.DCP, .absoluteY)
        case 0xDF: return (.DCP, .absoluteX)

        case 0xE3: return (.ISB, .indexedIndirect)
        case 0xE7: return (.ISB, .zeroPage)
        case 0xEF: return (.ISB, .absolute)
        case 0xF3: return (.ISB, .indirectIndexed)
        case 0xF7: return (.ISB, .zeroPageX)
        case 0xFB: return (.ISB, .absoluteY)
        case 0xFF: return (.ISB, .absoluteX)

        case 0x03: return (.SLO, .indexedIndirect)
        case 0x07: return (.SLO, .zeroPage)
        case 0x0F: return (.SLO, .absolute)
        case 0x13: return (.SLO, .indirectIndexed)
        case 0x17: return (.SLO, .zeroPageX)
        case 0x1B: return (.SLO, .absoluteY)
        case 0x1F: return (.SLO, .absoluteX)

        case 0x23: return (.RLA, .indexedIndirect)
        case 0x27: return (.RLA, .zeroPage)
        case 0x2F: return (.RLA, .absolute)
        case 0x33: return (.RLA, .indirectIndexed)
        case 0x37: return (.RLA, .zeroPageX)
        case 0x3B: return (.RLA, .absoluteY)
        case 0x3F: return (.RLA, .absoluteX)

        case 0x43: return (.SRE, .indexedIndirect)
        case 0x47: return (.SRE, .zeroPage)
        case 0x4F: return (.SRE, .absolute)
        case 0x53: return (.SRE, .indirectIndexed)
        case 0x57: return (.SRE, .zeroPageX)
        case 0x5B: return (.SRE, .absoluteY)
        case 0x5F: return (.SRE, .absoluteX)

        case 0x63: return (.RRA, .indexedIndirect)
        case 0x67: return (.RRA, .zeroPage)
        case 0x6F: return (.RRA, .absolute)
        case 0x73: return (.RRA, .indirectIndexed)
        case 0x77: return (.RRA, .zeroPageX)
        case 0x7B: return (.RRA, .absoluteY)
        case 0x7F: return (.RRA, .absoluteX)

        case 0x0C: return (.NOP, .absolute)
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4: return (.NOP, .zeroPageX)
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA: return (.NOP, .implicit)
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC: return (.NOP, .absoluteX)
        case 0x80, 0x82, 0x89, 0xC2, 0xE2: return (.NOP, .immediate)

        default: return (.NOP, .implicit)
        }
    }
}

private let undocumentedOpcodes = [
    0xEB, 0x04, 0x44, 0x64, 0x0C, 0x14, 0x34, 0x54,
    0x74, 0xD4, 0xF4, 0x1A, 0x3A, 0x5A, 0x7A, 0xDA,
    0xFA, 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC, 0x80, 0x82, 0x89, 0xC2, 0xE2,
    0xA3, 0xA7, 0xAF, 0xB3, 0xB7, 0xBF, 0x83, 0x87, 0x8F, 0x97,
    0xC3, 0xC7, 0xCF, 0xD3, 0xD7, 0xDB, 0xDF,
    0xE3, 0xE7, 0xEF, 0xF3, 0xF7, 0xFB, 0xFF,
    0x03, 0x07, 0x0F, 0x13, 0x17, 0x1B, 0x1F,
    0x23, 0x27, 0x2F, 0x33, 0x37, 0x3B, 0x3F,
    0x43, 0x47, 0x4F, 0x53, 0x57, 0x5B, 0x5F,
    0x63, 0x67, 0x6F, 0x73, 0x77, 0x7B, 0x7F,
]
