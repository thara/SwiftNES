
struct Instruction {
    let opcode: OpCode
    let mnemonic: Mnemonic
    let addressingMode: AddressingMode
    let fetchOperand: AddressingMode.FetchOperand
    let exec: Operation
}

struct CPUStep {
    var pc: UInt16 = 0x00

    var operand1: UInt8 = 0x00
    var operand2: UInt8 = 0x00

    var registers: CPURegisters

    var operand16: UInt16 {
        return operand1.u16 | (operand2.u16 << 8)
    }
}

// swiftlint:disable cyclomatic_complexity
class Disassembler {
    let cpu: CPU

    init(cpu: CPU) {
        self.cpu = cpu
    }

    // func disassemble() -> (machineCode: String, assemblyCode: String) {
    //     let currentStep = makeCurrentStep()

    //     let opcode = cpu.memory.read(at: currentStep.pc)
    //     let instruction = cpu.decode(opcode)

    //     return (
    //         makeMachineCode(step: currentStep, instruction: instruction),
    //         makeAssemblyCode(step: currentStep, instruction: instruction))
    // }

    // private func makeCurrentStep() -> CPUStep {
    //     let pc = cpu.registers.PC

    //     return CPUStep(
    //         pc: cpu.registers.PC,
    //         operand1: cpu.memory.read(at: pc &+ 1),
    //         operand2: cpu.memory.read(at: pc &+ 2),
    //         registers: cpu.registers
    //     )
    // }

    // private func makeMachineCode(step: CPUStep, instruction: Instruction) -> String {
    //     switch instruction.addressingMode {
    //     case .immediate, .zeroPage, .zeroPageX, .zeroPageY, .relative, .indirectIndexed, .indexedIndirect:
    //         return "\(instruction.opcode.hex2) \(step.operand1.hex2)"
    //     case .indirect, .absolute, .absoluteX, .absoluteY:
    //         return "\(instruction.opcode.hex2) \(step.operand1.hex2) \(step.operand2.hex2)"
    //     default:
    //         return "\(instruction.opcode.hex2)"
    //     }
    // }

    // private func makeAssemblyCode(step: CPUStep, instruction: Instruction) -> String {
    //     let operandString = makeAssemblyOperand(step: step, instruction: instruction)
    //     let prefix = undocumentedOpcodes.contains(Int(instruction.opcode)) ? "*" : " "
    //     return "\(prefix)\(instruction.mnemonic) \(operandString)"
    // }

    // private func makeAssemblyOperand(step: CPUStep, instruction: Instruction) -> String {
    //     switch instruction.mnemonic {
    //     case .JMP, .JSR:
    //         if case .absolute = instruction.addressingMode {
    //             return String(format: "$%04X", decodeAddress(step: step, addressingMode: instruction.addressingMode))
    //         }
    //     case .LSR, .ASL, .ROR, .ROL:
    //         if case .accumulator = instruction.addressingMode {
    //             return "A"
    //         }
    //     default:
    //         break
    //     }

    //     return makeAssemblyOperand(step: step, addressingMode: instruction.addressingMode)
    // }

    // private func makeAssemblyOperand(step: CPUStep, addressingMode: AddressingMode) -> String {
    //     let operand1 = step.operand1
    //     let operand16 = step.operand16
    //     let x = step.registers.X
    //     let y = step.registers.Y

    //     switch addressingMode {
    //     case .implicit, .accumulator:
    //         return " "
    //     case .immediate:
    //         return String(format: "#$%02X", operand1)
    //     case .zeroPage:
    //         return String(format: "$%02X = %02X", operand1, cpu.memory.read(at: operand1.u16))
    //     case .zeroPageX:
    //         return String(format: "$%02X,X @ %02X = %02X", operand1, operand1 &+ x, cpu.memory.read(at: (operand1 &+ x).u16))
    //     case .zeroPageY:
    //         return String(format: "$%02X,Y @ %02X = %02X", operand1, operand1 &+ y, cpu.memory.read(at: (operand1 &+ y).u16))
    //     case .absolute:
    //         return String(format: "$%04X = %02X", operand16, cpu.memory.read(at: operand16))
    //     case .absoluteX:
    //         return String(format: "$%04X,X @ %04X = %02X", operand16, operand16 &+ x.u16, cpu.memory.read(at: operand16 &+ x.u16))
    //     case .absoluteY:
    //         return String(format: "$%04X,Y @ %04X = %02X", operand16, operand16 &+ y.u16, cpu.memory.read(at: operand16 &+ y.u16))
    //     case .relative:
    //         return String(format: "$%04X", Int(step.pc) &+ 2 &+ Int(operand1.i8))
    //     case .indirect:
    //         return String(format: "($%04X) = %04X", operand16, cpu.memory.readOnIndirect(operand: operand16))
    //     case .indexedIndirect:
    //         let operandX = x &+ operand1
    //         let address = cpu.memory.readOnIndirect(operand: operandX.u16)
    //         return String(format: "($%02X,X) @ %02X = %04X = %02X", operand1, operandX, address, cpu.memory.read(at: address))
    //     case .indirectIndexed:
    //         let data = cpu.memory.readOnIndirect(operand: operand1.u16)
    //         return String(format: "($%02X),Y = %04X @ %04X = %02X", operand1, data, data &+ y.u16, cpu.memory.read(at: data &+ y.u16))
    //     }
    // }

    // private func decodeAddress(step: CPUStep, addressingMode: AddressingMode) -> UInt16 {
    //     switch addressingMode {
    //     case .implicit:
    //         return 0x00
    //     case .immediate:
    //         return step.pc
    //     case .zeroPage:
    //         return step.operand1.u16
    //     case .zeroPageX:
    //         return (step.operand1 &+ step.registers.X).u16 & 0xFF
    //     case .zeroPageY:
    //         return (step.operand1 &+ step.registers.Y).u16 & 0xFF
    //     case .absolute:
    //         return step.operand16
    //     case .absoluteX:
    //         return step.operand16 &+ step.registers.X.u16
    //     case .absoluteY:
    //         return step.operand16 &+ step.registers.Y.u16
    //     case .relative:
    //         return step.pc
    //     case .indirect:
    //         return cpu.memory.readOnIndirect(operand: step.operand16)
    //     case .indirectIndexed:
    //         return cpu.memory.readOnIndirect(operand: (step.operand16 &+ step.registers.X.u16) & 0xFF)
    //     case .indexedIndirect:
    //         return cpu.memory.readOnIndirect(operand: step.operand16) &+ step.registers.Y.u16
    //     default:
    //         return 0x00
    //     }
    // }
}
// swiftlint:enable cyclomatic_complexity

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
    0x63, 0x67, 0x6F, 0x73, 0x77, 0x7B, 0x7F
]
