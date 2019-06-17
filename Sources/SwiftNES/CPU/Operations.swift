extension CPU {

    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand?) -> UInt16 {
        registers.A = memory.read(addr: operand!)
        return 1
    }

    /// LDX
    func loadXRegister(operand: Operand?) -> UInt16 {
        registers.X = memory.read(addr: operand!)
        return 1
    }

    /// LDY
    func loadYRegister(operand: Operand?) -> UInt16 {
        registers.Y = memory.read(addr: operand!)
        return 1
    }

    /// STA
    func storeAccumulator(operand: Operand?) -> UInt16 {
        memory.write(addr: operand!, data: registers.A)
        return 1
    }

    /// STX
    func storeXRegister(operand: Operand?) -> UInt16 {
        memory.write(addr: operand!, data: registers.X)
        return 1
    }

    /// STY
    func storeYRegister(operand: Operand?) -> UInt16 {
        memory.write(addr: operand!, data: registers.Y)
        return 1
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand?) -> UInt16 {
        registers.X = registers.A
        return 1
    }

    /// TAY
    func transferAccumulatorToY(operand: Operand?) -> UInt16 {
        registers.Y = registers.A
        return 1
    }

    /// TXA
    func transferXtoAccumulator(operand: Operand?) -> UInt16 {
        registers.A = registers.X
        return 1
    }

    /// TYA
    func transferYtoAccumulator(operand: Operand?) -> UInt16 {
        registers.A = registers.Y
        return 1
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand?) -> UInt16 {
        pushStack(data: registers.A)
        return 1
    }

    /// PHP
    func pushProcessorStatus(operand: Operand?) -> UInt16 {
        pushStack(data: registers.P.rawValue)
        return 1
    }

    /// PLA
    func pullAccumulator(operand: Operand?) -> UInt16 {
        registers.A = pullStack()
        return 1
    }

    /// PLP
    func pullProcessorStatus(operand: Operand?) -> UInt16 {
        registers.P = Status(rawValue: pullStack())
        return 1
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand?) -> UInt16 {
        registers.A &= memory.read(addr: operand!)
        return 1
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand?) -> UInt16 {
        registers.A ^= memory.read(addr: operand!)
        return 1
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand?) -> UInt16 {
        registers.A |= memory.read(addr: operand!)
        return 1
    }

    /// BIT
    func testBits(operand: Operand?) -> UInt16 {
        let data = registers.A & memory.read(addr: operand!)
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x40 != 0 { registers.P.formUnion(.V) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }
        return 1
    }

    // MARK: - Arithmetic instructions

    /// ADC
    func addWithCarry(operand: Operand?) -> UInt16 {
        let a = Int16(registers.A)
        let val = Int16(memory.read(addr: operand!))
        var result = a + val
        if registers.P.contains(.C) { result += 1 }

        registers.P.remove([.C, .Z, .V, .N])
        if result & 0x100 == 1 { registers.P.formUnion(.C)}
        if (a ^ val) & 0x80 == 0 && (val ^ result) & 0x80 == 1 {
            registers.P.formUnion(.V)
        }
        registers.A = UInt8(result & 0xFF)
        return 1
    }

    /// SBC
    func subtractWithCarry(operand: Operand?) -> UInt16 {
        let a = Int16(registers.A)
        let val = Int16(memory.read(addr: operand!))
        var result = a - val
        if registers.P.contains(.C) { result -= 1 }

        registers.P.remove([.C, .Z, .V, .N])
        if result & 0x100 == 1 { registers.P.formUnion(.C)}
        if (a ^ val) & 0x80 == 0 && (val ^ result) & 0x80 == 1 {
            registers.P.formUnion(.V)
        }
        registers.A = UInt8(result & 0xFF)
        return 1
    }

    /// CMP
    func compareAccumulator(operand: Operand?) -> UInt16 {
        let cmp = Int16(registers.A) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return 1
    }

    /// CPX
    func compareXRegister(operand: Operand?) -> UInt16 {
        let cmp = Int16(registers.X) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return 1
    }

    /// CPY
    func compareYRegister(operand: Operand?) -> UInt16 {
        let cmp = Int16(registers.Y) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return 1
    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand?) -> UInt16 {
        let result = memory.read(addr: operand!) &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: result)

        return 1
    }

    /// INX
    func incrementX(_: Operand?) -> UInt16 {
        let result = registers.X &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return 1
    }

    /// INY
    func incrementY(operand: Operand?) -> UInt16 {
        let result = registers.Y &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.Y = result

        return 1
    }

    /// DEC
    func decrementMemory(operand: Operand?) -> UInt16 {
        let result = memory.read(addr: operand!) &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: result)

        return 1
    }

    /// DEX
    func decrementX(operand: Operand?) -> UInt16 {
        let result = registers.X &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return 1
    }

    /// DEY
    func decrementY(operand: Operand?) -> UInt16 {
        let result = registers.Y &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return 1
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand?) -> UInt16 {
        var data = memory.read(addr: operand!)

        registers.P.remove(.C)
        if data & 0x80 != 0 { registers.P.formUnion(.C) }

        data = (data << 1) & 0xFF

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)

        return 1
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand?) -> UInt16 {
        registers.P.remove(.C)
        if registers.A & 0x80 != 0 { registers.P.formUnion(.C) }

        registers.A = (registers.A << 1) & 0xFF

        return 1
    }

    /// LSR
    func logicalShiftRight(operand: Operand?) -> UInt16 {
        var data = memory.read(addr: operand!)

        registers.P.remove(.C)
        if data & 0x80 != 0 { registers.P.formUnion(.C) }

        data >>= 1

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)

        return 1
    }

    func logicalShiftRightForAccumulator(operand: Operand?) -> UInt16 {
        registers.P.remove(.C)
        if registers.A & 0x80 != 0 { registers.P.formUnion(.C) }

        registers.A >>= 1

        return 1
    }

    /// ROL
    func rotateLeft(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// ROR
    func rotateRight(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    // MARK: - Jump instructions

    /// JMP
    func jump(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// JSR
    func jumpToSubroutine(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// RTS
    func returnFromSubroutine(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// RTI
    func returnFromInterrupt(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    // MARK: - Branch instructions

    /// BCC
    func branchIfCarryClear(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// BCS
    func branchIfCarrySet(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// BEQ
    func branchIfEqual(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// BMI
    func branchIfMinus(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// BNE
    func branchIfNotEqual(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// BPL
    func branchIfPlus(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    // MARK: - Flag control instructions

    /// CLC
    func clearCarry(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// CLD
    func clearDecimal(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// CLI
    func clearInterrupt(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// CLV
    func clearOverflow(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// SEC
    func setCarryFlag(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// SED
    func setDecimalFlag(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    /// SEI
    func setInterruptDisable(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }

    // MARK: - Misc

    /// BRK
    func forceInterrupt(operand: Operand?) -> UInt16 {
        //TODO
        return 1
    }
}
