extension CPU {
    func logNestest(_ pc: UInt16, _ operand: UInt16?, _ instruction: Instruction) {
        let opcodePC = pc.hex4

        let machineCode: String
        let assemblyCode: String
        if let operand = operand {
            let operand1 = operand & 0xFF
            let operand2 = (operand & 0xFF00) >> 2
            machineCode = "\(instruction.opcode.hex2) \(operand1.hex2) \(operand2.hex2)"

            let operandString = String(format: instruction.addressingMode.nestestStringFormat, operand1, operand2)
            assemblyCode = "\(instruction.mnemonic) \(operandString)"
        } else {
            machineCode = "\(instruction.opcode.hex2)"
            assemblyCode = "\(instruction.mnemonic)"
        }

        print("\(opcodePC)  \(machineCode.padding(10)) \(assemblyCode.padding(32)) \(registers)")
    }
}

extension Registers : CustomStringConvertible {
    var description: String {
        return "A:\(A.hex2) X:\(X.hex2) Y:\(Y.hex2) P:\(P.rawValue.hex2) SP:\(S.hex2)"
    }
}

extension AddressingMode {
    var nestestStringFormat: String {
        switch self {
        case .implicit, .accumulator:
            return ""
        case .immediate:
            return "#$%02X"
        case .zeroPage:
            return "$%02X"
        case .zeroPageX:
            return "$%02X, X"
        case .zeroPageY:
            return "$%02X, Y"
        case .absolute:
            return "$%02X%02X"
        case .absoluteX:
            return "$%02X%02X, X"
        case .absoluteY:
            return "$%02X%02X"
        case .relative:
            return "$%02X"
        case .indirect:
            return "($%02X%02X)"
        case .indexedIndirect:
            return "($%02X, X)"
        case .indirectIndexed:
            return "($%02X, Y)"
        }
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
