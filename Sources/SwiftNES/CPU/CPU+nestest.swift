extension CPU {
    func logNestest(_ operand: UInt16?, _ instruction: Instruction) {
        let pc = currentStep.pc!

        let operand8_1 = memory.read(at: pc &+ 1)
        let operand8_2 = memory.read(at: pc &+ 2)
        let operand16 = operand8_1.u16 | (operand8_2.u16 << 8)

        let addressingMode = currentStep.addressingMode!

        let machineCode: String
        switch addressingMode {
        case .immediate, .zeroPage, .zeroPageX, .zeroPageY, .relative, .indirectIndexed, .indexedIndirect:
            machineCode = "\(instruction.opcode.hex2) \(operand8_1.hex2)"
        case .indirect, .absolute, .absoluteX, .absoluteY:
            machineCode = "\(instruction.opcode.hex2) \(operand8_1.hex2) \(operand8_2.hex2)"
        default:
            machineCode = "\(instruction.opcode.hex2)"
        }

        var operandString = toOperandString(addressingMode: addressingMode, pc: pc, operand8_1: operand8_1, operand8_2: operand8_2, operand16: operand16)

        switch instruction.mnemonic {
        case .JMP, .JSR:
            if addressingMode == .absolute {
                let addr = decodeAddress(addressingMode, pc, operand8_1, operand16)
                operandString = String(format: "$%04X", addr)
            }
        case .LSR, .ASL, .ROR, .ROL:
            if addressingMode == .accumulator {
                operandString = "A"
            }
        default:
            break
        }
        let prefix = undocumentedOpcodes.contains(Int(instruction.opcode)) ? "*" : " "
        let assemblyCode = "\(prefix)\(instruction.mnemonic) \(operandString)"

        print("\(pc.hex4)  \(machineCode.padding(9))\(assemblyCode.padding(33))\(registers)")
    }

    func decodeAddress(_ addressingMode: AddressingMode, _ pc: UInt16, _ operand8_1: UInt8, _ operand16: UInt16) -> UInt16 {
        switch addressingMode {
        case .implicit:
            return 0x00
        case .immediate:
            return pc
        case .zeroPage:
            return operand8_1.u16
        case .zeroPageX:
            return (operand8_1 &+ registers.X).u16 & 0xFF
        case .zeroPageY:
            return (operand8_1 &+ registers.Y).u16 & 0xFF
        case .absolute:
            return operand16
        case .absoluteX:
            return operand16 &+ registers.X.u16
        case .absoluteY:
            return operand16 &+ registers.Y.u16
        case .relative:
            return pc
        case .indirect:
            return readOnIndirect(operand: operand16)
        case .indirectIndexed:
            return readOnIndirect(operand: (operand16 &+ registers.X.u16) & 0xFF)
        case .indexedIndirect:
            return readOnIndirect(operand: operand16) + registers.Y.u16
        default:
            return 0x00
        }
    }

    func toOperandString(addressingMode: AddressingMode, pc: UInt16, operand8_1: UInt8, operand8_2: UInt8, operand16: UInt16) -> String {
        let operand16 = operand8_1.u16 | (operand8_2.u16 << 8)

        switch addressingMode {
        case .implicit, .accumulator:
            return " "
        case .immediate:
            return String(format: "#$%02X", operand8_1)
        case .zeroPage:
            return String(format: "$%02X = %02X", operand8_1, memory.read(at: operand8_1.u16))
        case .zeroPageX:
            return String(format: "$%02X,X @ %02X = %02X", operand8_1, operand8_1 &+ registers.X, memory.read(at: (operand8_1 &+ registers.X).u16))
        case .zeroPageY:
            return String(format: "$%02X,Y @ %02X = %02X", operand8_1, operand8_1 &+ registers.Y, memory.read(at: (operand8_1 &+ registers.Y).u16))
        case .absolute:
            return String(format: "$%04X = %02X", operand16, memory.read(at: operand16))
        case .absoluteX:
            return String(format: "$%04X,X @ %04X = %02X", operand16, operand16 &+ registers.X.u16, memory.read(at: operand16 &+ registers.X.u16))
        case .absoluteY:
            return String(format: "$%04X,Y @ %04X = %02X", operand16, operand16 &+ registers.Y.u16, memory.read(at: operand16 &+ registers.Y.u16))
        case .relative:
            return String(format: "$%04X", Int(pc) &+ 2 &+ Int(operand8_1.i8))
        case .indirect:
            return String(format: "($%04X) = %04X", operand16, readOnIndirect(operand: operand16))
        case .indexedIndirect:
            let operandX = registers.X &+ operand8_1
            return String(format: "($%02X,X) @ %02X = %04X = %02X", operand8_1, operandX, readOnIndirect(operand: operandX.u16), memory.read(at: readOnIndirect(operand: operandX.u16)))
        case .indirectIndexed:
            let data = readOnIndirect(operand: operand8_1.u16)
            return String(format: "($%02X),Y = %04X @ %04X = %02X", operand8_1, data, data &+ registers.Y.u16, memory.read(at: data &+ registers.Y.u16))
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

extension Registers: CustomStringConvertible {
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
