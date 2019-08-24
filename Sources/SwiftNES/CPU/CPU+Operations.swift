// swiftlint:disable file_length

extension CPU {

    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = read(at: operand!)
        return .next
    }

    /// LDX
    func loadXRegister(operand: Operand?) -> PCUpdate {
        registers.X = read(at: operand!)
        return .next
    }

    /// LDY
    func loadYRegister(operand: Operand?) -> PCUpdate {
        registers.Y = read(at: operand!)
        return .next
    }

    /// STA
    func storeAccumulator(operand: Operand?) -> PCUpdate {
        write(registers.A, at: operand!)

        if [.absoluteX, .absoluteY, .indirectIndexed].contains(currentStep.addressingMode) {
            tick()
        }

        return .next
    }

    /// STX
    func storeXRegister(operand: Operand?) -> PCUpdate {
        write(registers.X, at: operand!)
        return .next
    }

    /// STY
    func storeYRegister(operand: Operand?) -> PCUpdate {
        write(registers.Y, at: operand!)
        return .next
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand?) -> PCUpdate {
        registers.X = registers.A
        tick()
        return .next
    }

    /// TSX
    func transferStackPointerToX(operand: Operand?) -> PCUpdate {
        registers.X = registers.S
        tick()
        return .next
    }

    /// TAY
    func transferAccumulatorToY(operand: Operand?) -> PCUpdate {
        registers.Y = registers.A
        tick()
        return .next
    }

    /// TXA
    func transferXtoAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = registers.X
        tick()
        return .next
    }

    /// TXS
    func transferXtoStackPointer(operand: Operand?) -> PCUpdate {
        registers.S = registers.X
        tick()
        return .next
    }

    /// TYA
    func transferYtoAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = registers.Y
        tick()
        return .next
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand?) -> PCUpdate {
        pushStack(registers.A)
        tick()
        return .next
    }

    /// PHP
    func pushProcessorStatus(operand: Operand?) -> PCUpdate {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.operatedB.rawValue)
        tick()
        return .next
    }

    /// PLA
    func pullAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = pullStack()
        tick()
        return .next
    }

    /// PLP
    func pullProcessorStatus(operand: Operand?) -> PCUpdate {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        tick(count: 2)
        return .next
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand?) -> PCUpdate {
        registers.A &= read(at: operand!)
        return .next
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand?) -> PCUpdate {
        registers.A ^= read(at: operand!)
        return .next
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand?) -> PCUpdate {
        registers.A |= read(at: operand!)
        return .next
    }

    /// BIT
    func testBits(operand: Operand?) -> PCUpdate {
        let value = read(at: operand!)
        let data = registers.A & value
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) } else { registers.P.remove(.Z) }
        if value[6] == 1 { registers.P.formUnion(.V) } else { registers.P.remove(.V) }
        if value[7] == 1 { registers.P.formUnion(.N) } else { registers.P.remove(.N) }
        return .next
    }

    // MARK: - Arithmetic instructions

    /// ADC
    func addWithCarry(operand: Operand?) -> PCUpdate {
        let a = registers.A
        let val = read(at: operand!)
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
        return .next
    }

    /// SBC
    func subtractWithCarry(operand: Operand?) -> PCUpdate {
        let a = registers.A
        let val = ~read(at: operand!)
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
        return .next
    }

    /// CMP
    func compareAccumulator(operand: Operand?) -> PCUpdate {
        let cmp = Int16(registers.A) &- Int16(read(at: operand!))

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if 0 <= cmp { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return .next
    }

    /// CPX
    func compareXRegister(operand: Operand?) -> PCUpdate {
        let value = read(at: operand!)
        let cmp = registers.X &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.X >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return .next
    }

    /// CPY
    func compareYRegister(operand: Operand?) -> PCUpdate {
        let value = read(at: operand!)
        let cmp = registers.Y &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.Y >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return .next
    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand?) -> PCUpdate {
        let result = read(at: operand!) &+ 1

        registers.P.setZN(result)
        write(result, at: operand!)

        tick()

        return .next
    }

    /// INX
    func incrementX(_: Operand?) -> PCUpdate {
        registers.X = registers.X &+ 1
        return .next
    }

    /// INY
    func incrementY(operand: Operand?) -> PCUpdate {
        registers.Y = registers.Y &+ 1
        return .next
    }

    /// DEC
    func decrementMemory(operand: Operand?) -> PCUpdate {
        let result = read(at: operand!) &- 1

        registers.P.setZN(result)

        write(result, at: operand!)

        tick()

        return .next
    }

    /// DEX
    func decrementX(operand: Operand?) -> PCUpdate {
        registers.X = registers.X &- 1
        tick()
        return .next
    }

    /// DEY
    func decrementY(operand: Operand?) -> PCUpdate {
        registers.Y = registers.Y &- 1
        tick()
        return .next
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand?) -> PCUpdate {
        var data = read(at: operand!)

        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1

        registers.P.setZN(data)

        write(data, at: operand!)

        tick()
        return .next
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand?) -> PCUpdate {
        registers.P.remove([.C, .Z, .N])
        if registers.A[7] == 1 { registers.P.formUnion(.C) }

        registers.A <<= 1

        tick()
        return .next
    }

    /// LSR
    func logicalShiftRight(operand: Operand?) -> PCUpdate {
        var data = read(at: operand!)

        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)

        write(data, at: operand!)

        tick()
        return .next
    }

    func logicalShiftRightForAccumulator(operand: Operand?) -> PCUpdate {
        registers.P.remove([.C, .Z, .N])
        if registers.A[0] == 1 { registers.P.formUnion(.C) }

        registers.A >>= 1

        tick()
        return .next
    }

    /// ROL
    func rotateLeft(operand: Operand?) -> PCUpdate {
        var data = read(at: operand!)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand!)

        tick()
        return .next
    }

    func rotateLeftForAccumulator(_: Operand?) -> PCUpdate {
        let c = registers.A & 0x80

        var a = registers.A << 1
        if registers.P.contains(.C) { a |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
        return .next
    }

    /// ROR
    func rotateRight(operand: Operand?) -> PCUpdate {
        var data = read(at: operand!)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        write(data, at: operand!)

        tick()
        return .next
    }

    func rotateRightForAccumulator(operand: Operand?) -> PCUpdate {
        let c = registers.A & 0x01

        var a = registers.A >> 1
        if registers.P.contains(.C) { a |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a

        tick()
        return .next
    }

    // MARK: - Jump instructions

    /// JMP
    func jump(operand: Operand?) -> PCUpdate {
        return .jump(addr: operand!)
    }

    /// JSR
    func jumpToSubroutine(operand: Operand?) -> PCUpdate {
        pushStack(word: registers.PC &- 1)
        tick()
        return .jump(addr: operand!)
    }

    /// RTS
    func returnFromSubroutine(operand: Operand?) -> PCUpdate {
        tick(count: 3)
        return .jump(addr: pullStack() &+ 1)
    }

    /// RTI
    func returnFromInterrupt(operand: Operand?) -> PCUpdate {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        tick(count: 2)
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        return .jump(addr: pullStack())
    }

    // MARK: - Branch instructions

    /// BCC
    func branchIfCarryClear(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.C) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BCS
    func branchIfCarrySet(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.C) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BEQ
    func branchIfEqual(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.Z) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BMI
    func branchIfMinus(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.N) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BNE
    func branchIfNotEqual(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.Z) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BPL
    func branchIfPlus(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.N) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.V) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.V) {
            tick()
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    // MARK: - Flag control instructions

    /// CLC
    func clearCarry(operand: Operand?) -> PCUpdate {
        registers.P.remove(.C)
        tick()
        return .next
    }

    /// CLD
    func clearDecimal(operand: Operand?) -> PCUpdate {
        registers.P.remove(.D)
        tick()
        return .next
    }

    /// CLI
    func clearInterrupt(operand: Operand?) -> PCUpdate {
        registers.P.remove(.I)
        tick()
        return .next
    }

    /// CLV
    func clearOverflow(operand: Operand?) -> PCUpdate {
        registers.P.remove(.V)
        tick()
        return .next
    }

    /// SEC
    func setCarryFlag(operand: Operand?) -> PCUpdate {
        registers.P.formUnion(.C)
        tick()
        return .next
    }

    /// SED
    func setDecimalFlag(operand: Operand?) -> PCUpdate {
        registers.P.formUnion(.D)
        tick()
        return .next
    }

    /// SEI
    func setInterruptDisable(operand: Operand?) -> PCUpdate {
        registers.P.formUnion(.I)
        tick()
        return .next
    }

    // MARK: - Misc

    /// BRK
    func forceInterrupt(operand: Operand?) -> PCUpdate {
        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.PC = readWord(at: 0xFFFE)
        tick()
        return .next
    }

    /// NOP
    func doNothing(_ operand: Operand?) -> PCUpdate {
        return .next
    }

    // MARK: - Illegal

    /// LAX
    func loadAccumulatorAndX(operand: Operand?) -> PCUpdate {
        let data = read(at: operand!)
        registers.A = data
        registers.X = data
        return .next
    }

    /// SAX
    func storeAccumulatorAndX(operand: Operand?) -> PCUpdate {
        write(registers.A & registers.X, at: operand!)
        return .next
    }

    /// DCP
    func decrementMemoryAndCompareAccumulator(operand: Operand?) -> PCUpdate {
        _  = decrementMemory(operand: operand)
        return compareAccumulator(operand: operand)
    }

    /// ISB
    func incrementMemoryAndSubtractWithCarry(operand: Operand?) -> PCUpdate {
        _ = incrementMemory(operand: operand)
        return subtractWithCarry(operand: operand)
    }

    /// SLO
    func arithmeticShiftLeftAndBitwiseORwithAccumulator(operand: Operand?) -> PCUpdate {
        _ = arithmeticShiftLeft(operand: operand)
        return bitwiseORwithAccumulator(operand: operand)
    }

    /// RLA
    func rotateLeftAndBitwiseANDwithAccumulator(operand: Operand?) -> PCUpdate {
        _ = rotateLeft(operand: operand)
        return bitwiseANDwithAccumulator(operand: operand)
    }

    /// SRE
    func logicalShiftRightAndBitwiseExclusiveOR(operand: Operand?) -> PCUpdate {
        _ = logicalShiftRight(operand: operand)
        return bitwiseExclusiveOR(operand: operand)
    }

    /// RRA
    func rotateRightAndAddWithCarry(operand: Operand?) -> PCUpdate {
        _ = rotateRight(operand: operand)
        return addWithCarry(operand: operand)
    }
}
