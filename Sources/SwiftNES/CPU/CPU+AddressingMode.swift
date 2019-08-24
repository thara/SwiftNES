enum AddressingMode {
    case implicit
    case accumulator
    case immediate
    case zeroPage
    case zeroPageX
    case zeroPageY
    case absolute
    case absoluteX
    case absoluteY
    case relative
    case indirect
    case indexedIndirect
    case indirectIndexed

    typealias FetchOperand = () -> UInt16
}

extension CPU {

    func implicit() -> UInt16 {
        currentStep.addressingMode = .implicit

        return 0x00
    }

    func accumulator() -> UInt16 {
        currentStep.addressingMode = .accumulator

        return registers.A.u16
    }

    func immediate() -> UInt16 {
        currentStep.addressingMode = .immediate

        let operand = registers.PC
        registers.PC &+= 1
        return operand
    }

    func zeroPage() -> UInt16 {
        currentStep.addressingMode = .zeroPage

        let operand = read(at: registers.PC).u16 & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageX() -> UInt16 {
        currentStep.addressingMode = .zeroPageX
        tick()

        let operand = (read(at: registers.PC).u16 &+ registers.X.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageY() -> UInt16 {
        currentStep.addressingMode = .zeroPageY
        tick()

        let operand = (read(at: registers.PC).u16 &+ registers.Y.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func absolute() -> UInt16 {
        currentStep.addressingMode = .absolute

        let operand = readWord(at: registers.PC)
        registers.PC &+= 2
        return operand
    }

    func absoluteX() -> UInt16 {
        currentStep.addressingMode = .absoluteX

        let data = readWord(at: registers.PC)
        let operand = data &+ registers.X.u16 & 0xFFFF
        registers.PC &+= 2

        if pageCrossed(data, registers.X) {
            tick()
        }

        return operand
    }

    func absoluteY() -> UInt16 {
        currentStep.addressingMode = .absoluteY

        let data = readWord(at: registers.PC)
        let operand = data &+ registers.Y.u16 & 0xFFFF
        registers.PC &+= 2

        if pageCrossed(data, registers.Y) {
            tick()
        }

        return operand
    }

    func relative() -> UInt16 {
        currentStep.addressingMode = .relative

        let operand = read(at: registers.PC).u16
        registers.PC &+= 1
        return operand
    }

    func indirect() -> UInt16 {
        currentStep.addressingMode = .indirect

        let data = readWord(at: registers.PC)
        let operand = readOnIndirect(operand: data)
        registers.PC &+= 2
        return operand
    }

    func indexedIndirect() -> UInt16 {
        currentStep.addressingMode = .indexedIndirect

        let data = read(at: registers.PC)
        let operand = readOnIndirect(operand: (data &+ registers.X).u16 & 0xFF)
        registers.PC &+= 1

        tick()

        return operand
    }

    func indirectIndexed() -> UInt16 {
        currentStep.addressingMode = .indirectIndexed

        let data = read(at: registers.PC).u16
        let operand = readOnIndirect(operand: data) &+ registers.Y.u16
        registers.PC &+= 1

        if pageCrossed(data &- registers.Y.u16, registers.Y) {
            tick()
        }

        return operand
    }

    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }

    func pageCrossed(_ a: UInt16, _ b: UInt8) -> Bool {
        return ((a &+ b.u16) & 0xFF00) != (a & 0xFF00)
    }
}
