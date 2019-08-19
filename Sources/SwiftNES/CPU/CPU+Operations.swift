extension CPU {

    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = memory.read(at: operand!)
        return .next
    }

    /// LDX
    func loadXRegister(operand: Operand?) -> PCUpdate {
        registers.X = memory.read(at: operand!)
        return .next
    }

    /// LDY
    func loadYRegister(operand: Operand?) -> PCUpdate {
        registers.Y = memory.read(at: operand!)
        return .next
    }

    /// STA
    func storeAccumulator(operand: Operand?) -> PCUpdate {
        memory.write(registers.A, at: operand!)
        return .next
    }

    /// STX
    func storeXRegister(operand: Operand?) -> PCUpdate {
        memory.write(registers.X, at: operand!)
        return .next
    }

    /// STY
    func storeYRegister(operand: Operand?) -> PCUpdate {
        memory.write(registers.Y, at: operand!)
        return .next
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand?) -> PCUpdate {
        registers.X = registers.A
        return .next
    }

    /// TSX
    func transferStackPointerToX(operand: Operand?) -> PCUpdate {
        registers.X = registers.S
        return .next
    }

    /// TAY
    func transferAccumulatorToY(operand: Operand?) -> PCUpdate {
        registers.Y = registers.A
        return .next
    }

    /// TXA
    func transferXtoAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = registers.X
        return .next
    }

    /// TXS
    func transferXtoStackPointer(operand: Operand?) -> PCUpdate {
        registers.S = registers.X
        return .next
    }

    /// TYA
    func transferYtoAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = registers.Y
        return .next
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand?) -> PCUpdate {
        pushStack(registers.A)
        return .next
    }

    /// PHP
    func pushProcessorStatus(operand: Operand?) -> PCUpdate {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.operatedB.rawValue)
        return .next
    }

    /// PLA
    func pullAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = pullStack()
        return .next
    }

    /// PLP
    func pullProcessorStatus(operand: Operand?) -> PCUpdate {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        return .next
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand?) -> PCUpdate {
        registers.A &= memory.read(at: operand!)
        return .next
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand?) -> PCUpdate {
        registers.A ^= memory.read(at: operand!)
        return .next
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand?) -> PCUpdate {
        registers.A |= memory.read(at: operand!)
        return .next
    }

    /// BIT
    func testBits(operand: Operand?) -> PCUpdate {
        let value = memory.read(at: operand!)
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
        let val = memory.read(at: operand!)
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
        let val = ~memory.read(at: operand!)
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
        let cmp = Int16(registers.A) &- Int16(memory.read(at: operand!))

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if 0 <= cmp { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return .next
    }

    /// CPX
    func compareXRegister(operand: Operand?) -> PCUpdate {
        let value = memory.read(at: operand!)
        let cmp = registers.X &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.X >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return .next
    }

    /// CPY
    func compareYRegister(operand: Operand?) -> PCUpdate {
        let value = memory.read(at: operand!)
        let cmp = registers.Y &- value

        registers.P.remove([.C, .Z, .N])
        registers.P.setZN(cmp)
        if registers.Y >= value { registers.P.formUnion(.C) } else { registers.P.remove(.C) }

        return .next
    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand?) -> PCUpdate {
        let result = memory.read(at: operand!) &+ 1

        registers.P.setZN(result)
        memory.write(result, at: operand!)

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
        let result = memory.read(at: operand!) &- 1

        registers.P.setZN(result)

        memory.write(result, at: operand!)

        return .next
    }

    /// DEX
    func decrementX(operand: Operand?) -> PCUpdate {
        registers.X = registers.X &- 1
        return .next
    }

    /// DEY
    func decrementY(operand: Operand?) -> PCUpdate {
        registers.Y = registers.Y &- 1
        return .next
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand?) -> PCUpdate {
        var data = memory.read(at: operand!)

        registers.P.remove([.C, .Z, .N])
        if data[7] == 1 { registers.P.formUnion(.C) }

        data <<= 1

        registers.P.setZN(data)

        memory.write(data, at: operand!)

        return .next
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand?) -> PCUpdate {
        registers.P.remove([.C, .Z, .N])
        if registers.A[7] == 1 { registers.P.formUnion(.C) }

        registers.A <<= 1

        return .next
    }

    /// LSR
    func logicalShiftRight(operand: Operand?) -> PCUpdate {
        var data = memory.read(at: operand!)

        registers.P.remove([.C, .Z, .N])
        if data[0] == 1 { registers.P.formUnion(.C) }

        data >>= 1

        registers.P.setZN(data)

        memory.write(data, at: operand!)

        return .next
    }

    func logicalShiftRightForAccumulator(operand: Operand?) -> PCUpdate {
        registers.P.remove([.C, .Z, .N])
        if registers.A[0] == 1 { registers.P.formUnion(.C) }

        registers.A >>= 1

        return .next
    }

    /// ROL
    func rotateLeft(operand: Operand?) -> PCUpdate {
        var data = memory.read(at: operand!)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        memory.write(data, at: operand!)

        return .next
    }

    func rotateLeftForAccumulator(_: Operand?) -> PCUpdate {
        let c = registers.A & 0x80

        var a = registers.A << 1
        if registers.P.contains(.C) { a |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        registers.A = a
        return .next
    }

    /// ROR
    func rotateRight(operand: Operand?) -> PCUpdate {
        var data = memory.read(at: operand!)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.P.setZN(data)

        memory.write(data, at: operand!)
        return .next
    }

    func rotateRightForAccumulator(operand: Operand?) -> PCUpdate {
        let c = registers.A & 0x01

        var a = registers.A >> 1
        if registers.P.contains(.C) { a |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a
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
        return .jump(addr: operand!)
    }

    /// RTS
    func returnFromSubroutine(operand: Operand?) -> PCUpdate {
        return .jump(addr: pullStack() &+ 1)
    }

    /// RTI
    func returnFromInterrupt(operand: Operand?) -> PCUpdate {
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        registers.P = Status(rawValue: pullStack() & ~Status.B.rawValue | Status.R.rawValue)
        return .jump(addr: pullStack())
    }

    // MARK: - Branch instructions

    /// BCC
    func branchIfCarryClear(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.C) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BCS
    func branchIfCarrySet(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.C) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BEQ
    func branchIfEqual(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.Z) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BMI
    func branchIfMinus(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.N) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BNE
    func branchIfNotEqual(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.Z) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BPL
    func branchIfPlus(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.N) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.V) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.V) {
            return .branch(offset: operand!.i8)
        }
        return .next
    }

    // MARK: - Flag control instructions

    /// CLC
    func clearCarry(operand: Operand?) -> PCUpdate {
        registers.P.remove(.C)
        return .next
    }

    /// CLD
    func clearDecimal(operand: Operand?) -> PCUpdate {
        registers.P.remove(.D)
        return .next
    }

    /// CLI
    func clearInterrupt(operand: Operand?) -> PCUpdate {
        registers.P.remove(.I)
        return .next
    }

    /// CLV
    func clearOverflow(operand: Operand?) -> PCUpdate {
        registers.P.remove(.V)
        return .next
    }

    /// SEC
    func setCarryFlag(operand: Operand?) -> PCUpdate {
        registers.P.formUnion(.C)
        return .next
    }

    /// SED
    func setDecimalFlag(operand: Operand?) -> PCUpdate {
        registers.P.formUnion(.D)
        return .next
    }

    /// SEI
    func setInterruptDisable(operand: Operand?) -> PCUpdate {
        registers.P.formUnion(.I)
        return .next
    }

    // MARK: - Misc

    /// BRK
    func forceInterrupt(operand: Operand?) -> PCUpdate {
        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.PC = memory.readWord(at: 0xFFFE)
        return .next
    }

    /// NOP
    func doNothing(_ operand: Operand?) -> PCUpdate {
        return .next
    }
}
