extension CPU {
    func logNestest(_ operand: UInt16?, _ instruction: Instruction) {
        let pc = currentStep.pc

        currentStep.operand1 = memory.read(at: pc &+ 1)
        currentStep.operand2 = memory.read(at: pc &+ 2)

        let machineCode = makeMachineCode(for: instruction)
        let assemblyCode = makeAssemblyCode(for: instruction)

        print("\(pc.hex4)  \(machineCode.padding(9))\(assemblyCode.padding(33))\(registers)")
    }

    func makeMachineCode(for instruction: Instruction) -> String {
        switch instruction.addressingMode {
        case .immediate, .zeroPage, .zeroPageX, .zeroPageY, .relative, .indirectIndexed, .indexedIndirect:
            return "\(instruction.opcode.hex2) \(currentStep.operand1.hex2)"
        case .indirect, .absolute, .absoluteX, .absoluteY:
            return "\(instruction.opcode.hex2) \(currentStep.operand1.hex2) \(currentStep.operand2.hex2)"
        default:
            return "\(instruction.opcode.hex2)"
        }
    }

    func makeAssemblyCode(for instruction: Instruction) -> String {
        let operandString = makeAssemblyOperand(for: instruction)
        let prefix = undocumentedOpcodes.contains(Int(instruction.opcode)) ? "*" : " "
        return "\(prefix)\(instruction.mnemonic) \(operandString)"
    }

    func makeAssemblyOperand(for instruction: Instruction) -> String {
        switch instruction.mnemonic {
        case .JMP, .JSR:
            if instruction.addressingMode == .absolute {
                return String(format: "$%04X", decodeAddress(from: instruction.addressingMode))
            }
        case .LSR, .ASL, .ROR, .ROL:
            if instruction.addressingMode == .accumulator {
                return "A"
            }
        default:
            break
        }

        return makeAssemblyOperand(addressingMode: instruction.addressingMode)
    }

    func makeAssemblyOperand(addressingMode: AddressingMode) -> String {
        let operand1 = currentStep.operand1
        let operand16 = currentStep.operand16

        switch addressingMode {
        case .implicit, .accumulator:
            return " "
        case .immediate:
            return String(format: "#$%02X", operand1)
        case .zeroPage:
            return String(format: "$%02X = %02X", operand1, memory.read(at: operand1.u16))
        case .zeroPageX:
            return String(format: "$%02X,X @ %02X = %02X", operand1, operand1 &+ registers.X, memory.read(at: (operand1 &+ registers.X).u16))
        case .zeroPageY:
            return String(format: "$%02X,Y @ %02X = %02X", operand1, operand1 &+ registers.Y, memory.read(at: (operand1 &+ registers.Y).u16))
        case .absolute:
            return String(format: "$%04X = %02X", operand16, memory.read(at: operand16))
        case .absoluteX:
            return String(format: "$%04X,X @ %04X = %02X", operand16, operand16 &+ registers.X.u16, memory.read(at: operand16 &+ registers.X.u16))
        case .absoluteY:
            return String(format: "$%04X,Y @ %04X = %02X", operand16, operand16 &+ registers.Y.u16, memory.read(at: operand16 &+ registers.Y.u16))
        case .relative:
            return String(format: "$%04X", Int(currentStep.pc) &+ 2 &+ Int(operand1.i8))
        case .indirect:
            return String(format: "($%04X) = %04X", operand16, readOnIndirect(operand: operand16))
        case .indexedIndirect:
            let operandX = registers.X &+ operand1
            return String(format: "($%02X,X) @ %02X = %04X = %02X", operand1, operandX, readOnIndirect(operand: operandX.u16), memory.read(at: readOnIndirect(operand: operandX.u16)))
        case .indirectIndexed:
            let data = readOnIndirect(operand: operand1.u16)
            return String(format: "($%02X),Y = %04X @ %04X = %02X", operand1, data, data &+ registers.Y.u16, memory.read(at: data &+ registers.Y.u16))
        }
    }

    func decodeAddress(from addressingMode: AddressingMode) -> UInt16 {
        switch addressingMode {
        case .implicit:
            return 0x00
        case .immediate:
            return currentStep.pc
        case .zeroPage:
            return currentStep.operand1.u16
        case .zeroPageX:
            return (currentStep.operand1 &+ registers.X).u16 & 0xFF
        case .zeroPageY:
            return (currentStep.operand1 &+ registers.Y).u16 & 0xFF
        case .absolute:
            return currentStep.operand16
        case .absoluteX:
            return currentStep.operand16 &+ registers.X.u16
        case .absoluteY:
            return currentStep.operand16 &+ registers.Y.u16
        case .relative:
            return currentStep.pc
        case .indirect:
            return memory.readOnIndirect(operand: currentStep.operand16)
        case .indirectIndexed:
            return memory.readOnIndirect(operand: (currentStep.operand16 &+ registers.X.u16) & 0xFF)
        case .indexedIndirect:
            return memory.readOnIndirect(operand: currentStep.operand16) &+ registers.Y.u16
        default:
            return 0x00
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
    0x63, 0x67, 0x6F, 0x73, 0x77, 0x7B, 0x7F
]

extension CPURegisters: CustomStringConvertible {
    var description: String {
        return "A:\(A.hex2) X:\(X.hex2) Y:\(Y.hex2) P:\(P.rawValue.hex2) SP:\(S.hex2)"
    }
}

fileprivate extension String {
    func padding(_ length: Int) -> String {
        return padding(toLength: length, withPad: " ", startingAt: 0)
    }
}

fileprivate extension UInt8 {
    var hex2: String {
        return String(format: "%02X", self)
    }
}

fileprivate extension UInt16 {
    var hex2: String {
        return String(format: "%02X", self)
    }
    var hex4: String {
        return String(format: "%04X", self)
    }
}
