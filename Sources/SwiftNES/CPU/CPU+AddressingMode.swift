enum AddressingMode {
    case implicit
    case accumulator
    case immediate
    case zeroPage
    case zeroPageX
    case zeroPageY
    case absolute
    case absoluteX(cycles: CycleConsumption)
    case absoluteY(cycles: CycleConsumption)
    case relative
    case indirect
    case indexedIndirect
    case indirectIndexed

    typealias FetchOperand = () -> UInt16

    enum CycleConsumption {
        case fixed, onlyIfPageCrossed
    }
}

extension CPU {

    func implicit() -> UInt16 {
        return 0x00
    }

    func accumulator() -> UInt16 {
        return registers.A.u16
    }

    func immediate() -> UInt16 {
        let operand = registers.PC
        registers.PC &+= 1
        return operand
    }

    func zeroPage() -> UInt16 {
        let operand = read(at: registers.PC).u16 & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageX() -> UInt16 {
        tick()

        let operand = (read(at: registers.PC).u16 &+ registers.X.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageY() -> UInt16 {
        tick()

        let operand = (read(at: registers.PC).u16 &+ registers.Y.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func absolute() -> UInt16 {
        let operand = readWord(at: registers.PC)
        registers.PC &+= 2
        return operand
    }

    func absoluteX() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.X.u16 & 0xFFFF
        registers.PC &+= 2
        tick()
        return operand
    }

    func absoluteXWithPenalty() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.X.u16 & 0xFFFF
        registers.PC &+= 2

        tickOnPageCrossed(value: data, operand: registers.X)
        return operand
    }

    func absoluteY() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.Y.u16 & 0xFFFF
        registers.PC &+= 2
        tick()
        return operand
    }

    func absoluteYWithPenalty() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = data &+ registers.Y.u16 & 0xFFFF
        registers.PC &+= 2

        tickOnPageCrossed(value: data, operand: registers.Y)
        return operand
    }

    func relative() -> UInt16 {
        let operand = read(at: registers.PC).u16
        registers.PC &+= 1
        return operand
    }

    func indirect() -> UInt16 {
        let data = readWord(at: registers.PC)
        let operand = readOnIndirect(operand: data)
        registers.PC &+= 2
        return operand
    }

    func indexedIndirect() -> UInt16 {
        let data = read(at: registers.PC)
        let operand = readOnIndirect(operand: (data &+ registers.X).u16 & 0xFF)
        registers.PC &+= 1

        tick()

        return operand
    }

    func indirectIndexed() -> UInt16 {
        let data = read(at: registers.PC).u16
        let operand = readOnIndirect(operand: data) &+ registers.Y.u16
        registers.PC &+= 1

        tickOnPageCrossed(value: operand &- registers.Y.u16, operand: registers.Y)
        return operand
    }

    func tickOnPageCrossed(value: UInt16, operand: UInt8) {
        tickOnPageCrossed(value: value, operand: operand.u16)
    }

    func tickOnPageCrossed(value: UInt16, operand: UInt16) {
        if ((value &+ operand) & 0xFF00) != (value & 0xFF00) {
            tick()
        }
    }
}

extension Memory {
    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}
