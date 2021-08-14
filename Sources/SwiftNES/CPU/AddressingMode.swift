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

    // swiftlint:disable cyclomatic_complexity
    func getOperand(from cpu: inout CPU) -> Operand {
        switch self {
        case .implicit:
            return 0x00
        case .accumulator:
            return cpu.A.u16
        case .immediate:
            let operand = cpu.PC
            cpu.PC &+= 1
            return operand
        case .zeroPage:
            let operand = cpu.read(at: cpu.PC).u16 & 0xFF
            cpu.PC &+= 1
            return operand
        case .zeroPageX:
            cpu.tick()

            let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.X.u16) & 0xFF
            cpu.PC &+= 1
            return operand
        case .zeroPageY:
            cpu.tick()

            let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.Y.u16) & 0xFF
            cpu.PC &+= 1
            return operand
        case .absolute:
            let operand = cpu.readWord(at: cpu.PC)
            cpu.PC &+= 2
            return operand
        case .absoluteX(let penalty):
            let data = cpu.readWord(at: cpu.PC)
            let operand = data &+ cpu.X.u16 & 0xFFFF
            cpu.PC &+= 2

            if penalty {
                if pageCrossed(value: data, operand: cpu.X) {
                    cpu.tick()
                }
            } else {
                cpu.tick()
            }

            return operand
        case .absoluteY(let penalty):
            let data = cpu.readWord(at: cpu.PC)
            let operand = data &+ cpu.Y.u16 & 0xFFFF
            cpu.PC &+= 2

            if penalty {
                if pageCrossed(value: data, operand: cpu.Y) {
                    cpu.tick()
                }
            } else {
                cpu.tick()
            }
            return operand
        case .relative:
            let operand = cpu.read(at: cpu.PC).u16
            cpu.PC &+= 1
            return operand
        case .indirect:
            let data = cpu.readWord(at: cpu.PC)
            let operand = cpu.readOnIndirect(operand: data)
            cpu.PC &+= 2
            return operand
        case .indexedIndirect:
            let data = cpu.read(at: cpu.PC)
            let operand = cpu.readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF)
            cpu.PC &+= 1

            cpu.tick()

            return operand
        case .indirectIndexed:
            let data = cpu.read(at: cpu.PC).u16
            let operand = cpu.readOnIndirect(operand: data) &+ cpu.Y.u16
            cpu.PC &+= 1

            if pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
                cpu.tick()
            }
            return operand
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
