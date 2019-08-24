// swiftlint:disable file_length

extension CPU {

    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand) -> NextPC {
        registers.A = read(at: operand)
        return registers.PC
    }

    /// LDX
    func loadXRegister(operand: Operand) -> NextPC {
        registers.X = read(at: operand)
        return registers.PC
    }

    /// LDY
    func loadYRegister(operand: Operand) -> NextPC {
        registers.Y = read(at: operand)
        return registers.PC
    }

    /// STA
    func storeAccumulator(operand: Operand) -> NextPC {
        write(registers.A, at: operand)

        if [.absoluteX, .absoluteY, .indirectIndexed].contains(currentStep.addressingMode) {
            tick()
        }

        return registers.PC
    }

    /// STX
    func storeXRegister(operand: Operand) -> NextPC {
        write(registers.X, at: operand)
        return registers.PC
    }

    /// STY
    func storeYRegister(operand: Operand) -> NextPC {
        write(registers.Y, at: operand)
        return registers.PC
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand) -> NextPC {
        registers.X = registers.A
        tick()
        return registers.PC
    }

    /// TSX
    func transferStackPointerToX(operand: Operand) -> NextPC {
        registers.X = registers.S
        tick()
        return registers.PC
    }

    /// TAY
    func transferAccumulatorToY(operand: Operand) -> NextPC {
        registers.Y = registers.A
        tick()
        return registers.PC
    }

    /// TXA
    func transferXtoAccumulator(operand: Operand) -> NextPC {
        registers.A = registers.X
        tick()
        return registers.PC
    }

    /// TXS
    func transferXtoStackPointer(operand: Operand) -> NextPC {
        registers.S = registers.X
        tick()
        return registers.PC
    }

    /// TYA
    func transferYtoAccumulator(operand: Operand) -> NextPC {
        registers.A = registers.Y
        tick()
        return registers.PC
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand) -> NextPC {
        pushStack(registers.A)
        tick()
        return registers.PC
    }

    /// PHP
    func pushProcessorStatus(operand: Operand) -> NextPC {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.operatedB.rawValue)
        tick()
        return registers.PC
    }

    /// PLA
    func pullAccumulator(operand: Operand) -> NextPC {
        registers.A = pullStack()
        tick()
        return registers.PC
    }

    /// PLP
    func pullProcessorStatus(operand: Operand) -> NextPC {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        tick(count: 2)
        return registers.PC
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand) -> NextPC {
        registers.A &= read(at: operand)
        return registers.PC
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand) -> NextPC {
        registers.A ^= read(at: operand)
        return registers.PC
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand) -> NextPC {
        registers.A |= read(at: operand)
        return registers.PC
    }

    /// BIT
    func testBits(operand: Operand) -> NextPC {
        let value = read(at: operand)
        let data = registers.A & value
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) } else { registers.P.remove(.Z) }
        if value[6] == 1 { registers.P.formUnion(.V) } else { registers.P.remove(.V) }
        if value[7] == 1 { registers.P.formUnion(.N) } else { registers.P.remove(.N) }
        return registers.PC
    }

    // MARK: - Arithmetic instructions

    /// ADC
    func addWithCarry(operand: Operand) -> NextPC {
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
        return registers.PC
    }

    /// SBC
    func subtractWithCarry(operand: Operand) -> NextPC {
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
        return registers.PC
    }

    /// CMP
    func compareAccumulator(operand: Operand) -> NextPC {
        let cmp = Int16(registers.A) &- Int16(read(at: operand))

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if 0 <= cmp { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return registers.PC
    }

    /// CPX
    func compareXRegister(operand: Operand) -> NextPC {
        let value = read(at: operand)
        let cmp = registers.X &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.X >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return registers.PC
    }

    /// CPY
    func compareYRegister(operand: Operand) -> NextPC {
        let value = read(at: operand)
        let cmp = registers.Y &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.Y >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return registers.PC
    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand) -> NextPC {
        let result = read(at: operand) &+ 1

        registers.P.setZN(result)
        write(result, at: operand)

        tick()

        return registers.PC
    }

    /// INX
    func incrementX(_: Operand) -> NextPC {
        registers.X = registers.X &+ 1
        return registers.PC
    }

    /// INY
    func incrementY(operand: Operand) -> NextPC {
        registers.Y = registers.Y &+ 1
        return registers.PC
    }

    /// DEC
    func decrementMemory(operand: Operand) -> NextPC {
        let result = read(at: operand) &- 1

        registers.P.setZN(result)

        write(result, at: operand)

        tick()

        return registers.PC
    }

    /// DEX
    func decrementX(operand: Operand) -> NextPC {
        registers.X = registers.X &- 1
        tick()
        return registers.PC
    }

    /// DEY
    func decrementY(operand: Operand) -> NextPC {
        registers.Y = registers.Y &- 1
        tick()
        return registers.PC
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand) -> NextPC {
        var data = read(at: operand)

        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand) -> NextPC {
        registers.P.remove([.C, .Z, .N])
        if registers.A[7] == 1 { registers.P.formUnion(.C) }

        registers.A <<= 1

        tick()
        return registers.PC
    }

    /// LSR
    func logicalShiftRight(operand: Operand) -> NextPC {
        var data = read(at: operand)

        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func logicalShiftRightForAccumulator(operand: Operand) -> NextPC {
        registers.P.remove([.C, .Z, .N])
        if registers.A[0] == 1 { registers.P.formUnion(.C) }

        registers.A >>= 1

        tick()
        return registers.PC
    }

    /// ROL
    func rotateLeft(operand: Operand) -> NextPC {
        var data = read(at: operand)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func rotateLeftForAccumulator(_: Operand) -> NextPC {
        let c = registers.A & 0x80

        var a = registers.A << 1
        if registers.P.contains(.C) { a |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
        return registers.PC
    }

    /// ROR
    func rotateRight(operand: Operand) -> NextPC {
        var data = read(at: operand)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand)

        tick()
        return registers.PC
    }

    func rotateRightForAccumulator(operand: Operand) -> NextPC {
        let c = registers.A & 0x01

        var a = registers.A >> 1
        if registers.P.contains(.C) { a |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
        return registers.PC
    }

    // MARK: - Jump instructions

    /// JMP
    func jump(operand: Operand) -> NextPC {
        return operand
    }

    /// JSR
    func jumpToSubroutine(operand: Operand) -> NextPC {
        pushStack(word: registers.PC &- 1)
        tick()
        return operand
    }

    /// RTS
    func returnFromSubroutine(operand: Operand) -> NextPC {
        tick(count: 3)
        return pullStack() &+ 1
    }

    /// RTI
    func returnFromInterrupt(operand: Operand) -> NextPC {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        tick(count: 2)
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        return pullStack()
    }

    // MARK: - Branch instructions

    /// BCC
    func branchIfCarryClear(operand: Operand) -> NextPC {
        if !registers.P.contains(.C) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    /// BCS
    func branchIfCarrySet(operand: Operand) -> NextPC {
        if registers.P.contains(.C) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    /// BEQ
    func branchIfEqual(operand: Operand) -> NextPC {
        if registers.P.contains(.Z) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    /// BMI
    func branchIfMinus(operand: Operand) -> NextPC {
        if registers.P.contains(.N) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    /// BNE
    func branchIfNotEqual(operand: Operand) -> NextPC {
        if !registers.P.contains(.Z) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    /// BPL
    func branchIfPlus(operand: Operand) -> NextPC {
        if !registers.P.contains(.N) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand) -> NextPC {
        if !registers.P.contains(.V) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand) -> NextPC {
        if registers.P.contains(.V) {
            tick()
            return UInt16(Int(registers.PC) &+ Int(operand.i8))
        }
        return registers.PC
    }

    // MARK: - Flag control instructions

    /// CLC
    func clearCarry(operand: Operand) -> NextPC {
        registers.P.remove(.C)
        tick()
        return registers.PC
    }

    /// CLD
    func clearDecimal(operand: Operand) -> NextPC {
        registers.P.remove(.D)
        tick()
        return registers.PC
    }

    /// CLI
    func clearInterrupt(operand: Operand) -> NextPC {
        registers.P.remove(.I)
        tick()
        return registers.PC
    }

    /// CLV
    func clearOverflow(operand: Operand) -> NextPC {
        registers.P.remove(.V)
        tick()
        return registers.PC
    }

    /// SEC
    func setCarryFlag(operand: Operand) -> NextPC {
        registers.P.formUnion(.C)
        tick()
        return registers.PC
    }

    /// SED
    func setDecimalFlag(operand: Operand) -> NextPC {
        registers.P.formUnion(.D)
        tick()
        return registers.PC
    }

    /// SEI
    func setInterruptDisable(operand: Operand) -> NextPC {
        registers.P.formUnion(.I)
        tick()
        return registers.PC
    }

    // MARK: - Misc

    /// BRK
    func forceInterrupt(operand: Operand) -> NextPC {
        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        tick()
        return readWord(at: 0xFFFE)
    }

    /// NOP
    func doNothing(_ operand: Operand) -> NextPC {
        return registers.PC
    }

    // MARK: - Illegal

    /// LAX
    func loadAccumulatorAndX(operand: Operand) -> NextPC {
        let data = read(at: operand)
        registers.A = data
        registers.X = data
        return registers.PC
    }

    /// SAX
    func storeAccumulatorAndX(operand: Operand) -> NextPC {
        write(registers.A & registers.X, at: operand)
        return registers.PC
    }

    /// DCP
    func decrementMemoryAndCompareAccumulator(operand: Operand) -> NextPC {
        _  = decrementMemory(operand: operand)
        return compareAccumulator(operand: operand)
    }

    /// ISB
    func incrementMemoryAndSubtractWithCarry(operand: Operand) -> NextPC {
        _ = incrementMemory(operand: operand)
        return subtractWithCarry(operand: operand)
    }

    /// SLO
    func arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: Operand) -> NextPC {
        _ = arithmeticShiftLeft(operand: operand)
        return bitwiseORwithAccumulator(operand: operand)
    }

    /// RLA
    func rotateLeftAndBitwiseANDwithAccumulator(operand: Operand) -> NextPC {
        _ = rotateLeft(operand: operand)
        return bitwiseANDwithAccumulator(operand: operand)
    }

    /// SRE
    func logicalShiftRightAndBitwiseExclusiveOR(operand: Operand) -> NextPC {
        _ = logicalShiftRight(operand: operand)
        return bitwiseExclusiveOR(operand: operand)
    }

    /// RRA
    func rotateRightAndAddWithCarry(operand: Operand) -> NextPC {
        _ = rotateRight(operand: operand)
        return addWithCarry(operand: operand)
    }
}
