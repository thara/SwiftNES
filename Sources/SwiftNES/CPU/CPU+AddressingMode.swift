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

        let operand = memory.read(at: registers.PC).u16 & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageX() -> UInt16 {
        currentStep.addressingMode = .zeroPageX

        let operand = (memory.read(at: registers.PC).u16 &+ registers.X.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func zeroPageY() -> UInt16 {
        currentStep.addressingMode = .zeroPageY

        let operand = (memory.read(at: registers.PC).u16 &+ registers.Y.u16) & 0xFF
        registers.PC &+= 1
        return operand
    }

    func absolute() -> UInt16 {
        currentStep.addressingMode = .absolute

        let operand = memory.readWord(at: registers.PC)
        registers.PC &+= 2
        return operand
    }

    func absoluteX() -> UInt16 {
        currentStep.addressingMode = .absoluteX

        let data = memory.readWord(at: registers.PC)
        let operand = data &+ registers.X.u16 & 0xFFFF
        registers.PC &+= 2
        return operand
    }

    func absoluteY() -> UInt16 {
        currentStep.addressingMode = .absoluteY

        let data = memory.readWord(at: registers.PC)
        let operand = data &+ registers.Y.u16 & 0xFFFF
        registers.PC &+= 2
        return operand
    }

    func relative() -> UInt16 {
        currentStep.addressingMode = .relative

        let operand = memory.read(at: registers.PC).u16
        registers.PC &+= 1
        return operand
    }

    func indirect() -> UInt16 {
        currentStep.addressingMode = .indirect

        let data = memory.readWord(at: registers.PC)
        let operand = readOnIndirect(operand: data)
        registers.PC &+= 2
        return operand
    }

    func indexedIndirect() -> UInt16 {
        currentStep.addressingMode = .indexedIndirect

        let data = memory.read(at: registers.PC)
        let operand = readOnIndirect(operand: (data &+ registers.X).u16 & 0xFF)
        registers.PC &+= 1
        return operand
    }

    func indirectIndexed() -> UInt16 {
        currentStep.addressingMode = .indirectIndexed

        let data = memory.read(at: registers.PC).u16
        let operand = readOnIndirect(operand: data) &+ registers.Y.u16
        registers.PC &+= 1
        return operand
    }

    // swiftlint:disable cyclomatic_complexity
    // func fetchOperand(in addressingMode: AddressingMode) -> (operand: UInt16?, pc: UInt16) {
    //     switch addressingMode {
    //     case .implicit:
    //         return (nil, 0)
    //     case .accumulator:
    //         return (registers.A.u16, 0)
    //     case .immediate:
    //         return (registers.PC, 1)
    //     case .zeroPage:
    //         return (memory.read(at: registers.PC).u16 & 0xFF, 1)
    //     case .zeroPageX:
    //         CPU.tick()
    //         return ((memory.read(at: registers.PC).u16 &+ registers.X.u16) & 0xFF, 1)
    //     case .zeroPageY:
    //         CPU.tick()
    //         return ((memory.read(at: registers.PC).u16 &+ registers.Y.u16) & 0xFF, 1)
    //     case .absolute:
    //         return (memory.readWord(at: registers.PC), 2)
    //     case .absoluteX:
    //         let data = memory.readWord(at: registers.PC)
    //         if pageCrossed(data, registers.X) {
    //             CPU.tick()
    //         }
    //         return (data &+ registers.X.u16 & 0xFFFF, 2)
    //     case .absoluteY:
    //         let data = memory.readWord(at: registers.PC)
    //         if pageCrossed(data, registers.X) {
    //             CPU.tick()
    //         }
    //         return (data &+ registers.Y.u16 & 0xFFFF, 2)
    //     case .relative:
    //         return (memory.read(at: registers.PC).u16, 1)
    //     case .indirect:
    //         let data = memory.readWord(at: registers.PC)
    //         return (readOnIndirect(operand: data), 2)
    //     case .indexedIndirect:
    //         CPU.tick()
    //         let data = memory.read(at: registers.PC)
    //         return (readOnIndirect(operand: (data &+ registers.X).u16 & 0xFF), 1)
    //     case .indirectIndexed:
    //         let data = memory.read(at: registers.PC).u16
    //         if pageCrossed(data &- registers.Y.u16, registers.Y) {
    //             CPU.tick()
    //         }
    //         return (readOnIndirect(operand: data) &+ registers.Y.u16, 1)
    //     }
    // }
    // swiftlint:enable cyclomatic_complexity

    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = memory.read(at: operand).u16
        let high = memory.read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }

    func pageCrossed(_ a: UInt16, _ b: UInt8) -> Bool {
        return ((a + b.u16) & 0xFF00) != (a & 0xFF00)
    }
}
