// swiftlint:disable file_length cyclomatic_complexity function_body_length

extension CPU {

    @inline(__always)
    func excuteInstruction(opcode: UInt8) {
        switch opcode {
        case 0xA9:
            loadAccumulator(operand: .immediate(cpu: self))
        case 0xA5:
            loadAccumulator(operand: .zeroPage(cpu: self))
        case 0xB5:
            loadAccumulator(operand: .zeroPageX(cpu: self))
        case 0xAD:
            loadAccumulator(operand: .absolute(cpu: self))
        case 0xBD:
            loadAccumulator(operand: .absoluteXWithPenalty(cpu: self))
        case 0xB9:
            loadAccumulator(operand: .absoluteYWithPenalty(cpu: self))
        case 0xA1:
            loadAccumulator(operand: .indexedIndirect(cpu: self))
        case 0xB1:
            loadAccumulator(operand: .indirectIndexed(cpu: self))
        case 0xA2:
            loadXRegister(operand: .immediate(cpu: self))
        case 0xA6:
            loadXRegister(operand: .zeroPage(cpu: self))
        case 0xB6:
            loadXRegister(operand: .zeroPageY(cpu: self))
        case 0xAE:
            loadXRegister(operand: .absolute(cpu: self))
        case 0xBE:
            loadXRegister(operand: .absoluteYWithPenalty(cpu: self))
        case 0xA0:
            loadYRegister(operand: .immediate(cpu: self))
        case 0xA4:
            loadYRegister(operand: .zeroPage(cpu: self))
        case 0xB4:
            loadYRegister(operand: .zeroPageX(cpu: self))
        case 0xAC:
            loadYRegister(operand: .absolute(cpu: self))
        case 0xBC:
            loadYRegister(operand: .absoluteXWithPenalty(cpu: self))
        case 0x85:
            storeAccumulator(operand: .zeroPage(cpu: self))
        case 0x95:
            storeAccumulator(operand: .zeroPageX(cpu: self))
        case 0x8D:
            storeAccumulator(operand: .absolute(cpu: self))
        case 0x9D:
            storeAccumulator(operand: .absoluteX(cpu: self))
        case 0x99:
            storeAccumulator(operand: .absoluteY(cpu: self))
        case 0x81:
            storeAccumulator(operand: .indexedIndirect(cpu: self))
        case 0x91:
            storeAccumulatorWithTick(operand: .indirectIndexed(cpu: self))
        case 0x86:
            storeXRegister(operand: .zeroPage(cpu: self))
        case 0x96:
            storeXRegister(operand: .zeroPageY(cpu: self))
        case 0x8E:
            storeXRegister(operand: .absolute(cpu: self))
        case 0x84:
            storeYRegister(operand: .zeroPage(cpu: self))
        case 0x94:
            storeYRegister(operand: .zeroPageX(cpu: self))
        case 0x8C:
            storeYRegister(operand: .absolute(cpu: self))
        case 0xAA:
            transferAccumulatorToX(operand: .implicit(cpu: self))
        case 0xBA:
            transferStackPointerToX(operand: .implicit(cpu: self))
        case 0xA8:
            transferAccumulatorToY(operand: .implicit(cpu: self))
        case 0x8A:
            transferXtoAccumulator(operand: .implicit(cpu: self))
        case 0x9A:
            transferXtoStackPointer(operand: .implicit(cpu: self))
        case 0x98:
            transferYtoAccumulator(operand: .implicit(cpu: self))

        case 0x48:
            pushAccumulator(operand: .implicit(cpu: self))
        case 0x08:
            pushProcessorStatus(operand: .implicit(cpu: self))
        case 0x68:
            pullAccumulator(operand: .implicit(cpu: self))
        case 0x28:
            pullProcessorStatus(operand: .implicit(cpu: self))

        case 0x29:
            bitwiseANDwithAccumulator(operand: .immediate(cpu: self))
        case 0x25:
            bitwiseANDwithAccumulator(operand: .zeroPage(cpu: self))
        case 0x35:
            bitwiseANDwithAccumulator(operand: .zeroPageX(cpu: self))
        case 0x2D:
            bitwiseANDwithAccumulator(operand: .absolute(cpu: self))
        case 0x3D:
            bitwiseANDwithAccumulator(operand: .absoluteXWithPenalty(cpu: self))
        case 0x39:
            bitwiseANDwithAccumulator(operand: .absoluteYWithPenalty(cpu: self))
        case 0x21:
            bitwiseANDwithAccumulator(operand: .indexedIndirect(cpu: self))
        case 0x31:
            bitwiseANDwithAccumulator(operand: .indirectIndexed(cpu: self))
        case 0x49:
            bitwiseExclusiveOR(operand: .immediate(cpu: self))
        case 0x45:
            bitwiseExclusiveOR(operand: .zeroPage(cpu: self))
        case 0x55:
            bitwiseExclusiveOR(operand: .zeroPageX(cpu: self))
        case 0x4D:
            bitwiseExclusiveOR(operand: .absolute(cpu: self))
        case 0x5D:
            bitwiseExclusiveOR(operand: .absoluteXWithPenalty(cpu: self))
        case 0x59:
            bitwiseExclusiveOR(operand: .absoluteYWithPenalty(cpu: self))
        case 0x41:
            bitwiseExclusiveOR(operand: .indexedIndirect(cpu: self))
        case 0x51:
            bitwiseExclusiveOR(operand: .indirectIndexed(cpu: self))
        case 0x09:
            bitwiseORwithAccumulator(operand: .immediate(cpu: self))
        case 0x05:
            bitwiseORwithAccumulator(operand: .zeroPage(cpu: self))
        case 0x15:
            bitwiseORwithAccumulator(operand: .zeroPageX(cpu: self))
        case 0x0D:
            bitwiseORwithAccumulator(operand: .absolute(cpu: self))
        case 0x1D:
            bitwiseORwithAccumulator(operand: .absoluteXWithPenalty(cpu: self))
        case 0x19:
            bitwiseORwithAccumulator(operand: .absoluteYWithPenalty(cpu: self))
        case 0x01:
            bitwiseORwithAccumulator(operand: .indexedIndirect(cpu: self))
        case 0x11:
            bitwiseORwithAccumulator(operand: .indirectIndexed(cpu: self))
        case 0x24:
            testBits(operand: .zeroPage(cpu: self))
        case 0x2C:
            testBits(operand: .absolute(cpu: self))

        case 0x69:
            addWithCarry(operand: .immediate(cpu: self))
        case 0x65:
            addWithCarry(operand: .zeroPage(cpu: self))
        case 0x75:
            addWithCarry(operand: .zeroPageX(cpu: self))
        case 0x6D:
            addWithCarry(operand: .absolute(cpu: self))
        case 0x7D:
            addWithCarry(operand: .absoluteXWithPenalty(cpu: self))
        case 0x79:
            addWithCarry(operand: .absoluteYWithPenalty(cpu: self))
        case 0x61:
            addWithCarry(operand: .indexedIndirect(cpu: self))
        case 0x71:
            addWithCarry(operand: .indirectIndexed(cpu: self))
        case 0xE9:
            subtractWithCarry(operand: .immediate(cpu: self))
        case 0xE5:
            subtractWithCarry(operand: .zeroPage(cpu: self))
        case 0xF5:
            subtractWithCarry(operand: .zeroPageX(cpu: self))
        case 0xED:
            subtractWithCarry(operand: .absolute(cpu: self))
        case 0xFD:
            subtractWithCarry(operand: .absoluteXWithPenalty(cpu: self))
        case 0xF9:
            subtractWithCarry(operand: .absoluteYWithPenalty(cpu: self))
        case 0xE1:
            subtractWithCarry(operand: .indexedIndirect(cpu: self))
        case 0xF1:
            subtractWithCarry(operand: .indirectIndexed(cpu: self))
        case 0xC9:
            compareAccumulator(operand: .immediate(cpu: self))
        case 0xC5:
            compareAccumulator(operand: .zeroPage(cpu: self))
        case 0xD5:
            compareAccumulator(operand: .zeroPageX(cpu: self))
        case 0xCD:
            compareAccumulator(operand: .absolute(cpu: self))
        case 0xDD:
            compareAccumulator(operand: .absoluteXWithPenalty(cpu: self))
        case 0xD9:
            compareAccumulator(operand: .absoluteYWithPenalty(cpu: self))
        case 0xC1:
            compareAccumulator(operand: .indexedIndirect(cpu: self))
        case 0xD1:
            compareAccumulator(operand: .indirectIndexed(cpu: self))
        case 0xE0:
            compareXRegister(operand: .immediate(cpu: self))
        case 0xE4:
            compareXRegister(operand: .zeroPage(cpu: self))
        case 0xEC:
            compareXRegister(operand: .absolute(cpu: self))
        case 0xC0:
            compareYRegister(operand: .immediate(cpu: self))
        case 0xC4:
            compareYRegister(operand: .zeroPage(cpu: self))
        case 0xCC:
            compareYRegister(operand: .absolute(cpu: self))

        case 0xE6:
            incrementMemory(operand: .zeroPage(cpu: self))
        case 0xF6:
            incrementMemory(operand: .zeroPageX(cpu: self))
        case 0xEE:
            incrementMemory(operand: .absolute(cpu: self))
        case 0xFE:
            incrementMemory(operand: .absoluteX(cpu: self))
        case 0xE8:
            incrementX(operand: .implicit(cpu: self))
        case 0xC8:
            incrementY(operand: .implicit(cpu: self))
        case 0xC6:
            decrementMemory(operand: .zeroPage(cpu: self))
        case 0xD6:
            decrementMemory(operand: .zeroPageX(cpu: self))
        case 0xCE:
            decrementMemory(operand: .absolute(cpu: self))
        case 0xDE:
            decrementMemory(operand: .absoluteX(cpu: self))
        case 0xCA:
            decrementX(operand: .implicit(cpu: self))
        case 0x88:
            decrementY(operand: .implicit(cpu: self))

        case 0x0A:
            arithmeticShiftLeftForAccumulator(operand: .accumulator(cpu: self))
        case 0x06:
            arithmeticShiftLeft(operand: .zeroPage(cpu: self))
        case 0x16:
            arithmeticShiftLeft(operand: .zeroPageX(cpu: self))
        case 0x0E:
            arithmeticShiftLeft(operand: .absolute(cpu: self))
        case 0x1E:
            arithmeticShiftLeft(operand: .absoluteX(cpu: self))
        case 0x4A:
            logicalShiftRightForAccumulator(operand: .accumulator(cpu: self))
        case 0x46:
            logicalShiftRight(operand: .zeroPage(cpu: self))
        case 0x56:
            logicalShiftRight(operand: .zeroPageX(cpu: self))
        case 0x4E:
            logicalShiftRight(operand: .absolute(cpu: self))
        case 0x5E:
            logicalShiftRight(operand: .absoluteX(cpu: self))
        case 0x2A:
            rotateLeftForAccumulator(operand: .accumulator(cpu: self))
        case 0x26:
            rotateLeft(operand: .zeroPage(cpu: self))
        case 0x36:
            rotateLeft(operand: .zeroPageX(cpu: self))
        case 0x2E:
            rotateLeft(operand: .absolute(cpu: self))
        case 0x3E:
            rotateLeft(operand: .absoluteX(cpu: self))
        case 0x6A:
            rotateRightForAccumulator(operand: .accumulator(cpu: self))
        case 0x66:
            rotateRight(operand: .zeroPage(cpu: self))
        case 0x76:
            rotateRight(operand: .zeroPageX(cpu: self))
        case 0x6E:
            rotateRight(operand: .absolute(cpu: self))
        case 0x7E:
            rotateRight(operand: .absoluteX(cpu: self))

        case 0x4C:
            jump(operand: .absolute(cpu: self))
        case 0x6C:
            jump(operand: .indirect(cpu: self))
        case 0x20:
            jumpToSubroutine(operand: .absolute(cpu: self))
        case 0x60:
            returnFromSubroutine(operand: .implicit(cpu: self))
        case 0x40:
            returnFromInterrupt(operand: .implicit(cpu: self))

        case 0x90:
            branchIfCarryClear(operand: .relative(cpu: self))
        case 0xB0:
            branchIfCarrySet(operand: .relative(cpu: self))
        case 0xF0:
            branchIfEqual(operand: .relative(cpu: self))
        case 0x30:
            branchIfMinus(operand: .relative(cpu: self))
        case 0xD0:
            branchIfNotEqual(operand: .relative(cpu: self))
        case 0x10:
            branchIfPlus(operand: .relative(cpu: self))
        case 0x50:
            branchIfOverflowClear(operand: .relative(cpu: self))
        case 0x70:
            branchIfOverflowSet(operand: .relative(cpu: self))

        case 0x18:
            clearCarry(operand: .implicit(cpu: self))
        case 0xD8:
            clearDecimal(operand: .implicit(cpu: self))
        case 0x58:
            clearInterrupt(operand: .implicit(cpu: self))
        case 0xB8:
            clearOverflow(operand: .implicit(cpu: self))

        case 0x38:
            setCarryFlag(operand: .implicit(cpu: self))
        case 0xF8:
            setDecimalFlag(operand: .implicit(cpu: self))
        case 0x78:
            setInterruptDisable(operand: .implicit(cpu: self))

        case 0x00:
            forceInterrupt(operand: .implicit(cpu: self))

        // Undocumented

        case 0xEB:
            subtractWithCarry(operand: .immediate(cpu: self))

        case 0x04, 0x44, 0x64:
            doNothing(operand: .zeroPage(cpu: self))
        case 0x0C:
            doNothing(operand: .absolute(cpu: self))
        case 0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4:
            doNothing(operand: .zeroPageX(cpu: self))
        case 0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA:
            doNothing(operand: .implicit(cpu: self))
        case 0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC:
            doNothing(operand: .absoluteXWithPenalty(cpu: self))
        case 0x80, 0x82, 0x89, 0xC2, 0xE2:
            doNothing(operand: .immediate(cpu: self))

        case 0xA3:
            loadAccumulatorAndX(operand: .indexedIndirect(cpu: self))
        case 0xA7:
            loadAccumulatorAndX(operand: .zeroPage(cpu: self))
        case 0xAF:
            loadAccumulatorAndX(operand: .absolute(cpu: self))
        case 0xB3:
            loadAccumulatorAndX(operand: .indirectIndexed(cpu: self))
        case 0xB7:
            loadAccumulatorAndX(operand: .zeroPageY(cpu: self))
        case 0xBF:
            loadAccumulatorAndX(operand: .absoluteYWithPenalty(cpu: self))

        case 0x83:
            storeAccumulatorAndX(operand: .indexedIndirect(cpu: self))
        case 0x87:
            storeAccumulatorAndX(operand: .zeroPage(cpu: self))
        case 0x8F:
            storeAccumulatorAndX(operand: .absolute(cpu: self))
        case 0x97:
            storeAccumulatorAndX(operand: .zeroPageY(cpu: self))

        case 0xC3:
            decrementMemoryAndCompareAccumulator(operand: .indexedIndirect(cpu: self))
        case 0xC7:
            decrementMemoryAndCompareAccumulator(operand: .zeroPage(cpu: self))
        case 0xCF:
            decrementMemoryAndCompareAccumulator(operand: .absolute(cpu: self))
        case 0xD3:
            decrementMemoryAndCompareAccumulator(operand: .indirectIndexed(cpu: self))
        case 0xD7:
            decrementMemoryAndCompareAccumulator(operand: .zeroPageX(cpu: self))
        case 0xDB:
            decrementMemoryAndCompareAccumulator(operand: .absoluteY(cpu: self))
        case 0xDF:
            decrementMemoryAndCompareAccumulator(operand: .absoluteX(cpu: self))

        case 0xE3:
            incrementMemoryAndSubtractWithCarry(operand: .indexedIndirect(cpu: self))
        case 0xE7:
            incrementMemoryAndSubtractWithCarry(operand: .zeroPage(cpu: self))
        case 0xEF:
            incrementMemoryAndSubtractWithCarry(operand: .absolute(cpu: self))
        case 0xF3:
            incrementMemoryAndSubtractWithCarry(operand: .indirectIndexed(cpu: self))
        case 0xF7:
            incrementMemoryAndSubtractWithCarry(operand: .zeroPageX(cpu: self))
        case 0xFB:
            incrementMemoryAndSubtractWithCarry(operand: .absoluteY(cpu: self))
        case 0xFF:
            incrementMemoryAndSubtractWithCarry(operand: .absoluteX(cpu: self))

        case 0x03:
            arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: .indexedIndirect(cpu: self))
        case 0x07:
            arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: .zeroPage(cpu: self))
        case 0x0F:
            arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: .absolute(cpu: self))
        case 0x13:
            arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: .indirectIndexed(cpu: self))
        case 0x17:
            arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: .zeroPageX(cpu: self))
        case 0x1B:
            arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: .absoluteY(cpu: self))
        case 0x1F:
            arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: .absoluteX(cpu: self))

        case 0x23:
            rotateLeftAndBitwiseANDwithAccumulator(operand: .indexedIndirect(cpu: self))
        case 0x27:
            rotateLeftAndBitwiseANDwithAccumulator(operand: .zeroPage(cpu: self))
        case 0x2F:
            rotateLeftAndBitwiseANDwithAccumulator(operand: .absolute(cpu: self))
        case 0x33:
            rotateLeftAndBitwiseANDwithAccumulator(operand: .indirectIndexed(cpu: self))
        case 0x37:
            rotateLeftAndBitwiseANDwithAccumulator(operand: .zeroPageX(cpu: self))
        case 0x3B:
            rotateLeftAndBitwiseANDwithAccumulator(operand: .absoluteY(cpu: self))
        case 0x3F:
            rotateLeftAndBitwiseANDwithAccumulator(operand: .absoluteX(cpu: self))

        case 0x43:
            logicalShiftRightAndBitwiseExclusiveOR(operand: .indexedIndirect(cpu: self))
        case 0x47:
            logicalShiftRightAndBitwiseExclusiveOR(operand: .zeroPage(cpu: self))
        case 0x4F:
            logicalShiftRightAndBitwiseExclusiveOR(operand: .absolute(cpu: self))
        case 0x53:
            logicalShiftRightAndBitwiseExclusiveOR(operand: .indirectIndexed(cpu: self))
        case 0x57:
            logicalShiftRightAndBitwiseExclusiveOR(operand: .zeroPageX(cpu: self))
        case 0x5B:
            logicalShiftRightAndBitwiseExclusiveOR(operand: .absoluteY(cpu: self))
        case 0x5F:
            logicalShiftRightAndBitwiseExclusiveOR(operand: .absoluteX(cpu: self))

        case 0x63:
            rotateRightAndAddWithCarry(operand: .indexedIndirect(cpu: self))
        case 0x67:
            rotateRightAndAddWithCarry(operand: .zeroPage(cpu: self))
        case 0x6F:
            rotateRightAndAddWithCarry(operand: .absolute(cpu: self))
        case 0x73:
            rotateRightAndAddWithCarry(operand: .indirectIndexed(cpu: self))
        case 0x77:
            rotateRightAndAddWithCarry(operand: .zeroPageX(cpu: self))
        case 0x7B:
            rotateRightAndAddWithCarry(operand: .absoluteY(cpu: self))
        case 0x7F:
            rotateRightAndAddWithCarry(operand: .absoluteX(cpu: self))

        default:
            doNothing(operand: .implicit(cpu: self))
        }
    }
}

// MARK: - Addressing Mode
extension Operand {

    static func implicit(cpu: CPU) -> UInt16 {
        return 0x00
    }

    static func accumulator(cpu: CPU) -> UInt16 {
        return cpu.registers.A.u16
    }

    static func immediate(cpu: CPU) -> UInt16 {
        let operand = cpu.registers.PC
        cpu.registers.PC &+= 1
        return operand
    }

    static func zeroPage(cpu: CPU) -> UInt16 {
        let operand = cpu.read(at: cpu.registers.PC).u16 & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static func zeroPageX(cpu: CPU) -> UInt16 {
        cpu.tick()

        let operand = (cpu.read(at: cpu.registers.PC).u16 &+ cpu.registers.X.u16) & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static func zeroPageY(cpu: CPU) -> UInt16 {
        cpu.tick()

        let operand = (cpu.read(at: cpu.registers.PC).u16 &+ cpu.registers.Y.u16) & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static func absolute(cpu: CPU) -> UInt16 {
        let operand = cpu.readWord(at: cpu.registers.PC)
        cpu.registers.PC &+= 2
        return operand
    }

    static func absoluteX(cpu: CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.X.u16 & 0xFFFF
        cpu.registers.PC &+= 2
        cpu.tick()
        return operand
    }

    static func absoluteXWithPenalty(cpu: CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.X.u16 & 0xFFFF
        cpu.registers.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.registers.X) {
            cpu.tick()
        }
        return operand
    }

    static func absoluteY(cpu: CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.Y.u16 & 0xFFFF
        cpu.registers.PC &+= 2
        cpu.tick()
        return operand
    }

    static func absoluteYWithPenalty(cpu: CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.Y.u16 & 0xFFFF
        cpu.registers.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.registers.Y) {
            cpu.tick()
        }
        return operand
    }

    static func relative(cpu: CPU) -> UInt16 {
        let operand = cpu.read(at: cpu.registers.PC).u16
        cpu.registers.PC &+= 1
        return operand
    }

    static func indirect(cpu: CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = cpu.readOnIndirect(operand: data)
        cpu.registers.PC &+= 2
        return operand
    }

    static func indexedIndirect(cpu: CPU) -> UInt16 {
        let data = cpu.read(at: cpu.registers.PC)
        let operand = cpu.readOnIndirect(operand: (data &+ cpu.registers.X).u16 & 0xFF)
        cpu.registers.PC &+= 1

        cpu.tick()

        return operand
    }

    static func indirectIndexed(cpu: CPU) -> UInt16 {
        let data = cpu.read(at: cpu.registers.PC).u16
        let operand = cpu.readOnIndirect(operand: data) &+ cpu.registers.Y.u16
        cpu.registers.PC &+= 1

        if CPU.pageCrossed(value: operand &- cpu.registers.Y.u16, operand: cpu.registers.Y) {
            cpu.tick()
        }
        return operand
    }

}

extension CPU {
    static func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
        return CPU.pageCrossed(value: value, operand: operand.u16)
    }

    static func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
        return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
    }

    static func pageCrossed(value: Int, operand: Int) -> Bool {
        return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
    }
}

extension Memory {
    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}

// MARK: - Operations
extension CPU {
    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand) {
        registers.A = read(at: operand)
    }

    /// LDX
    func loadXRegister(operand: Operand) {
        registers.X = read(at: operand)
    }

    /// LDY
    func loadYRegister(operand: Operand) {
        registers.Y = read(at: operand)
    }

    /// STA
    func storeAccumulator(operand: Operand) {
        write(registers.A, at: operand)
    }

    func storeAccumulatorWithTick(operand: Operand) {
        write(registers.A, at: operand)
        tick()
    }

    /// STX
    func storeXRegister(operand: Operand) {
        write(registers.X, at: operand)
    }

    /// STY
    func storeYRegister(operand: Operand) {
        write(registers.Y, at: operand)
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand) {
        registers.X = registers.A
        tick()
    }

    /// TSX
    func transferStackPointerToX(operand: Operand) {
        registers.X = registers.S
        tick()
    }

    /// TAY
    func transferAccumulatorToY(operand: Operand) {
        registers.Y = registers.A
        tick()
    }

    /// TXA
    func transferXtoAccumulator(operand: Operand) {
        registers.A = registers.X
        tick()
    }

    /// TXS
    func transferXtoStackPointer(operand: Operand) {
        registers.S = registers.X
        tick()
    }

    /// TYA
    func transferYtoAccumulator(operand: Operand) {
        registers.A = registers.Y
        tick()
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand) {
        pushStack(registers.A)
        tick()
    }

    /// PHP
    func pushProcessorStatus(operand: Operand) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.operatedB.rawValue)
        tick()
    }

    /// PLA
    func pullAccumulator(operand: Operand) {
        registers.A = pullStack()
        tick(count: 2)
    }

    /// PLP
    func pullProcessorStatus(operand: Operand) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        tick(count: 2)
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand) {
        registers.A &= read(at: operand)
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand) {
        registers.A ^= read(at: operand)
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand) {
        registers.A |= read(at: operand)
    }

    /// BIT
    func testBits(operand: Operand) {
        let value = read(at: operand)
        let data = registers.A & value
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) } else { registers.P.remove(.Z) }
        if value[6] == 1 { registers.P.formUnion(.V) } else { registers.P.remove(.V) }
        if value[7] == 1 { registers.P.formUnion(.N) } else { registers.P.remove(.N) }
    }

    // MARK: - Arithmetic instructions

    /// ADC
    func addWithCarry(operand: Operand) {
        let a = registers.A
        let val = read(at: operand)
        var result = a &+ val

        if registers.P.contains(.C) { result &+= 1 }

        registers.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { registers.P.formUnion(.C) }
        if c6 ^ c7 == 1 { registers.P.formUnion(.V) }

        registers.A = result
    }

    /// SBC
    func subtractWithCarry(operand: Operand) {
        let a = registers.A
        let val = ~read(at: operand)
        var result = a &+ val

        if registers.P.contains(.C) { result &+= 1 }

        registers.P.remove([.C, .Z, .V, .N])

        // http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
        let a7 = a[7]
        let v7 = val[7]
        let c6 = a7 ^ v7 ^ result[7]
        let c7 = (a7 & v7) | (a7 & c6) | (v7 & c6)

        if c7 == 1 { registers.P.formUnion(.C) }
        if c6 ^ c7 == 1 { registers.P.formUnion(.V) }

        registers.A = result
    }

    /// CMP
    func compareAccumulator(operand: Operand) {
        let cmp = Int16(registers.A) &- Int16(read(at: operand))

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if 0 <= cmp { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

    }

    /// CPX
    func compareXRegister(operand: Operand) {
        let value = read(at: operand)
        let cmp = registers.X &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.X >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

    }

    /// CPY
    func compareYRegister(operand: Operand) {
        let value = read(at: operand)
        let cmp = registers.Y &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.Y >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand) {
        let result = read(at: operand) &+ 1

        registers.P.setZN(result)
        write(result, at: operand)

        tick()

    }

    /// INX
    func incrementX(operand: Operand) {
        registers.X = registers.X &+ 1
        tick()
    }

    /// INY
    func incrementY(operand: Operand) {
        registers.Y = registers.Y &+ 1
        tick()
    }

    /// DEC
    func decrementMemory(operand: Operand) {
        let result = read(at: operand) &- 1

        registers.P.setZN(result)

        write(result, at: operand)

        tick()

    }

    /// DEX
    func decrementX(operand: Operand) {
        registers.X = registers.X &- 1
        tick()
    }

    /// DEY
    func decrementY(operand: Operand) {
        registers.Y = registers.Y &- 1
        tick()
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand) {
        var data = read(at: operand)

        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand) {
        registers.P.remove([.C, .Z, .N])
        if registers.A[7] == 1 { registers.P.formUnion(.C) }

        registers.A <<= 1

        tick()
    }

    /// LSR
    func logicalShiftRight(operand: Operand) {
        var data = read(at: operand)

        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
    }

    func logicalShiftRightForAccumulator(operand: Operand) {
        registers.P.remove([.C, .Z, .N])
        if registers.A[0] == 1 { registers.P.formUnion(.C) }

        registers.A >>= 1

        tick()
    }

    /// ROL
    func rotateLeft(operand: Operand) {
        var data = read(at: operand)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
    }

    func rotateLeftForAccumulator(operand: Operand) {
        let c = registers.A & 0x80

        var a = registers.A << 1
        if registers.P.contains(.C) { a |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
    }

    /// ROR
    func rotateRight(operand: Operand) {
        var data = read(at: operand)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
    }

    func rotateRightForAccumulator(operand: Operand) {
        let c = registers.A & 0x01

        var a = registers.A >> 1
        if registers.P.contains(.C) { a |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
    }

    // MARK: - Jump instructions

    /// JMP
    func jump(operand: Operand) {
        registers.PC = operand
    }

    /// JSR
    func jumpToSubroutine(operand: Operand) {
        pushStack(word: registers.PC &- 1)
        tick()
        registers.PC = operand
    }

    /// RTS
    func returnFromSubroutine(operand: Operand) {
        tick(count: 3)
        registers.PC = pullStack() &+ 1
    }

    /// RTI
    func returnFromInterrupt(operand: Operand) {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        tick(count: 2)
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        registers.PC = pullStack()
    }

    // MARK: - Branch instructions

    fileprivate func branch(operand: Operand, test: Bool) {
        if test {
            tick()
            let pc = Int(registers.PC)
            let offset = Int(operand.i8)
            if CPU.pageCrossed(value: pc, operand: offset) {
                tick()
            }
            registers.PC = UInt16(pc &+ offset)
        }
    }

    /// BCC
    func branchIfCarryClear(operand: Operand) {
        branch(operand: operand, test: !registers.P.contains(.C))
    }

    /// BCS
    func branchIfCarrySet(operand: Operand) {
        branch(operand: operand, test: registers.P.contains(.C))
    }

    /// BEQ
    func branchIfEqual(operand: Operand) {
        branch(operand: operand, test: registers.P.contains(.Z))
    }

    /// BMI
    func branchIfMinus(operand: Operand) {
        branch(operand: operand, test: registers.P.contains(.N))
    }

    /// BNE
    func branchIfNotEqual(operand: Operand) {
        branch(operand: operand, test: !registers.P.contains(.Z))
    }

    /// BPL
    func branchIfPlus(operand: Operand) {
        branch(operand: operand, test: !registers.P.contains(.N))
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand) {
        branch(operand: operand, test: !registers.P.contains(.V))
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand) {
        branch(operand: operand, test: registers.P.contains(.V))
    }

    // MARK: - Flag control instructions

    /// CLC
    func clearCarry(operand: Operand) {
        registers.P.remove(.C)
        tick()
    }

    /// CLD
    func clearDecimal(operand: Operand) {
        registers.P.remove(.D)
        tick()
    }

    /// CLI
    func clearInterrupt(operand: Operand) {
        registers.P.remove(.I)
        tick()
    }

    /// CLV
    func clearOverflow(operand: Operand) {
        registers.P.remove(.V)
        tick()
    }

    /// SEC
    func setCarryFlag(operand: Operand) {
        registers.P.formUnion(.C)
        tick()
    }

    /// SED
    func setDecimalFlag(operand: Operand) {
        registers.P.formUnion(.D)
        tick()
    }

    /// SEI
    func setInterruptDisable(operand: Operand) {
        registers.P.formUnion(.I)
        tick()
    }

    // MARK: - Misc

    /// BRK
    func forceInterrupt(operand: Operand) {
        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        tick()
        registers.PC = readWord(at: 0xFFFE)
    }

    /// NOP
    func doNothing(operand: Operand) {
        tick()
    }

    // MARK: - Illegal

    /// LAX
    func loadAccumulatorAndX(operand: Operand) {
        let data = read(at: operand)
        registers.A = data
        registers.X = data
    }

    /// SAX
    func storeAccumulatorAndX(operand: Operand) {
        write(registers.A & registers.X, at: operand)
    }

    /// DCP
    func decrementMemoryAndCompareAccumulator(operand: Operand) {
        // decrementMemory excluding tick
        let result = read(at: operand) &- 1
        registers.P.setZN(result)
        write(result, at: operand)

        compareAccumulator(operand: operand)
    }

    /// ISB
    func incrementMemoryAndSubtractWithCarry(operand: Operand) {
        // incrementMemory excluding tick
        let result = read(at: operand) &+ 1
        registers.P.setZN(result)
        write(result, at: operand)

        subtractWithCarry(operand: operand)
    }

    /// SLO
    func arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: Operand) {
        // arithmeticShiftLeft excluding tick
        var data = read(at: operand)
        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1
        registers.P.setZN(data)
        write(data, at: operand)

        bitwiseORwithAccumulator(operand: operand)
    }

    /// RLA
    func rotateLeftAndBitwiseANDwithAccumulator(operand: Operand) {
        // rotateLeft excluding tick
        var data = read(at: operand)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)
        write(data, at: operand)

        bitwiseANDwithAccumulator(operand: operand)
    }

    /// SRE
    func logicalShiftRightAndBitwiseExclusiveOR(operand: Operand) {
        // logicalShiftRight excluding tick
        var data = read(at: operand)
        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)
        write(data, at: operand)

        bitwiseExclusiveOR(operand: operand)
    }

    /// RRA
    func rotateRightAndAddWithCarry(operand: Operand) {
        // rotateRight excluding tick
        var data = read(at: operand)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)
        write(data, at: operand)

        addWithCarry(operand: operand)
    }
}
