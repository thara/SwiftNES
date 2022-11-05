// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
enum AddressingMode {
    case implicit
    case accumulator
    case immediate
    case zeroPage, zeroPageX, zeroPageY
    case absolute
    case absoluteX(penalty: Bool)
    case absoluteY(penalty: Bool)
    case relative
    case indirect, indexedIndirect, indirectIndexed
}

extension CPUEmulator {
    // swiftlint:disable cyclomatic_complexity
    func getOperand(by addressingMode: AddressingMode) -> Operand {
        switch addressingMode {
        case .implicit:
            return 0x00
        case .accumulator:
            return cpu.A.u16
        case .immediate:
            let operand = cpu.PC
            cpu.PC &+= 1
            return operand
        case .zeroPage:
            let operand = read(at: cpu.PC).u16 & 0xFF
            cpu.PC &+= 1
            return operand
        case .zeroPageX:
            tick()

            let operand = (read(at: cpu.PC).u16 &+ cpu.X.u16) & 0xFF
            cpu.PC &+= 1
            return operand
        case .zeroPageY:
            tick()

            let operand = (read(at: cpu.PC).u16 &+ cpu.Y.u16) & 0xFF
            cpu.PC &+= 1
            return operand
        case .absolute:
            let operand = readWord(at: cpu.PC)
            cpu.PC &+= 2
            return operand
        case .absoluteX(let penalty):
            let data = readWord(at: cpu.PC)
            let operand = data &+ cpu.X.u16 & 0xFFFF
            cpu.PC &+= 2

            if penalty {
                if pageCrossed(value: data, operand: cpu.X) {
                    tick()
                }
            } else {
                tick()
            }

            return operand
        case .absoluteY(let penalty):
            let data = readWord(at: cpu.PC)
            let operand = data &+ cpu.Y.u16 & 0xFFFF
            cpu.PC &+= 2

            if penalty {
                if pageCrossed(value: data, operand: cpu.Y) {
                    tick()
                }
            } else {
                tick()
            }
            return operand
        case .relative:
            let operand = read(at: cpu.PC).u16
            cpu.PC &+= 1
            return operand
        case .indirect:
            let data = readWord(at: cpu.PC)
            let operand = readOnIndirect(operand: data)
            cpu.PC &+= 2
            return operand
        case .indexedIndirect:
            let data = read(at: cpu.PC)
            let operand = readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF)
            cpu.PC &+= 1

            tick()

            return operand
        case .indirectIndexed:
            let data = read(at: cpu.PC).u16
            let operand = readOnIndirect(operand: data) &+ cpu.Y.u16
            cpu.PC &+= 1

            if pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
                tick()
            }
            return operand
        }
    }
}
