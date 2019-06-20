extension CPU {

    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand?) -> UInt16? {
        registers.A = memory.read(addr: operand!)
        return nil
    }

    /// LDX
    func loadXRegister(operand: Operand?) -> UInt16? {
        registers.X = memory.read(addr: operand!)
        return nil
    }

    /// LDY
    func loadYRegister(operand: Operand?) -> UInt16? {
        registers.Y = memory.read(addr: operand!)
        return nil
    }

    /// STA
    func storeAccumulator(operand: Operand?) -> UInt16? {
        memory.write(addr: operand!, data: registers.A)
        return nil
    }

    /// STX
    func storeXRegister(operand: Operand?) -> UInt16? {
        memory.write(addr: operand!, data: registers.X)
        return nil
    }

    /// STY
    func storeYRegister(operand: Operand?) -> UInt16? {
        memory.write(addr: operand!, data: registers.Y)
        return nil
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand?) -> UInt16? {
        registers.X = registers.A
        return nil
    }

    /// TAY
    func transferAccumulatorToY(operand: Operand?) -> UInt16? {
        registers.Y = registers.A
        return nil
    }

    /// TXA
    func transferXtoAccumulator(operand: Operand?) -> UInt16? {
        registers.A = registers.X
        return nil
    }

    /// TYA
    func transferYtoAccumulator(operand: Operand?) -> UInt16? {
        registers.A = registers.Y
        return nil
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand?) -> UInt16? {
        pushStack(data: registers.A)
        return nil
    }

    /// PHP
    func pushProcessorStatus(operand: Operand?) -> UInt16? {
        pushStack(data: registers.P.rawValue)
        return nil
    }

    /// PLA
    func pullAccumulator(operand: Operand?) -> UInt16? {
        registers.A = pullStack()
        return nil
    }

    /// PLP
    func pullProcessorStatus(operand: Operand?) -> UInt16? {
        registers.P = Status(rawValue: pullStack())
        return nil
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand?) -> UInt16? {
        registers.A &= memory.read(addr: operand!)
        return nil
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand?) -> UInt16? {
        registers.A ^= memory.read(addr: operand!)
        return nil
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand?) -> UInt16? {
        registers.A |= memory.read(addr: operand!)
        return nil
    }

    /// BIT
    func testBits(operand: Operand?) -> UInt16? {
        let data = registers.A & memory.read(addr: operand!)
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x40 != 0 { registers.P.formUnion(.V) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }
        return nil
    }

    // MARK: - Arithmetic instructions

    /// ADC
    func addWithCarry(operand: Operand?) -> UInt16? {
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
        return nil
    }

    /// SBC
    func subtractWithCarry(operand: Operand?) -> UInt16? {
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
        return nil
    }

    /// CMP
    func compareAccumulator(operand: Operand?) -> UInt16? {
        let cmp = Int16(registers.A) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return nil
    }

    /// CPX
    func compareXRegister(operand: Operand?) -> UInt16? {
        let cmp = Int16(registers.X) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return nil
    }

    /// CPY
    func compareYRegister(operand: Operand?) -> UInt16? {
        let cmp = Int16(registers.Y) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return nil
    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand?) -> UInt16? {
        let result = memory.read(addr: operand!) &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: result)

        return nil
    }

    /// INX
    func incrementX(_: Operand?) -> UInt16? {
        let result = registers.X &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return nil
    }

    /// INY
    func incrementY(operand: Operand?) -> UInt16? {
        let result = registers.Y &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.Y = result

        return nil
    }

    /// DEC
    func decrementMemory(operand: Operand?) -> UInt16? {
        let result = memory.read(addr: operand!) &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: result)

        return nil
    }

    /// DEX
    func decrementX(operand: Operand?) -> UInt16? {
        let result = registers.X &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return nil
    }

    /// DEY
    func decrementY(operand: Operand?) -> UInt16? {
        let result = registers.Y &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return nil
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand?) -> UInt16? {
        var data = memory.read(addr: operand!)

        registers.P.remove(.C)
        if data & 0x80 != 0 { registers.P.formUnion(.C) }

        data = (data << 1) & 0xFF

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)

        return nil
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand?) -> UInt16? {
        registers.P.remove(.C)
        if registers.A & 0x80 != 0 { registers.P.formUnion(.C) }

        registers.A = (registers.A << 1) & 0xFF

        return nil
    }

    /// LSR
    func logicalShiftRight(operand: Operand?) -> UInt16? {
        var data = memory.read(addr: operand!)

        registers.P.remove(.C)
        if data & 0x80 != 0 { registers.P.formUnion(.C) }

        data >>= 1

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)

        return nil
    }

    func logicalShiftRightForAccumulator(operand: Operand?) -> UInt16? {
        registers.P.remove(.C)
        if registers.A & 0x80 != 0 { registers.P.formUnion(.C) }

        registers.A >>= 1

        return nil
    }

    /// ROL
    func rotateLeft(operand: Operand?) -> UInt16? {
        var data = memory.read(addr: operand!)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        memory.write(addr: operand!, data: data)
        return nil
    }

    func rotateLeftForAccumulator(_: Operand?) -> UInt16? {
        let c = registers.A & 0x80

        var a = registers.A << 1
        if registers.P.contains(.C) { a |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a
        return nil
    }

    /// ROR
    func rotateRight(operand: Operand?) -> UInt16? {
        var data = memory.read(addr: operand!)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        memory.write(addr: operand!, data: data)
        return nil
    }

    func rotateRightForAccumulator(operand: Operand?) -> UInt16? {
        let c = registers.A & 0x01

        var a = registers.A >> 1
        if registers.P.contains(.C) { a |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        registers.A = a
        return nil
    }

    // MARK: - Jump instructions

    /// JMP
    func jump(operand: Operand?) -> UInt16? {
        return operand!
    }

    /// JSR
    func jumpToSubroutine(operand: Operand?) -> UInt16? {
        pushStack(word: registers.PC &- 1)
        return operand!
    }

    /// RTS
    func returnFromSubroutine(operand: Operand?) -> UInt16? {
        return pullStack() + 1
    }

    /// RTI
    func returnFromInterrupt(operand: Operand?) -> UInt16? {
        registers.P = Status(rawValue: pullStack())
        return pullStack()
    }

    // MARK: - Branch instructions

    /// BCC
    func branchIfCarryClear(operand: Operand?) -> UInt16? {
        if !registers.P.contains(.C) {
            return operand!
        }
        return nil
    }

    /// BCS
    func branchIfCarrySet(operand: Operand?) -> UInt16? {
        if registers.P.contains(.C) {
            return operand!
        }
        return nil
    }

    /// BEQ
    func branchIfEqual(operand: Operand?) -> UInt16? {
        if registers.P.contains(.Z) {
            return operand!
        }
        return nil
    }

    /// BMI
    func branchIfMinus(operand: Operand?) -> UInt16? {
        if registers.P.contains(.N) {
            return operand!
        }
        return nil
    }

    /// BNE
    func branchIfNotEqual(operand: Operand?) -> UInt16? {
        if !registers.P.contains(.Z) {
            return operand!
        }
        return nil
    }

    /// BPL
    func branchIfPlus(operand: Operand?) -> UInt16? {
        if !registers.P.contains(.N) {
            return operand!
        }
        return nil
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand?) -> UInt16? {
        if !registers.P.contains(.V) {
            return operand!
        }
        return nil
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand?) -> UInt16? {
        if registers.P.contains(.V) {
            return operand!
        }
        return nil
    }

    // MARK: - Flag control instructions

    /// CLC
    func clearCarry(operand: Operand?) -> UInt16? {
        registers.P.remove(.C)
        return nil
    }

    /// CLD
    func clearDecimal(operand: Operand?) -> UInt16? {
        registers.P.remove(.D)
        return nil
    }

    /// CLI
    func clearInterrupt(operand: Operand?) -> UInt16? {
        registers.P.remove(.I)
        return nil
    }

    /// CLV
    func clearOverflow(operand: Operand?) -> UInt16? {
        registers.P.remove(.V)
        return nil
    }

    /// SEC
    func setCarryFlag(operand: Operand?) -> UInt16? {
        registers.P.formUnion(.C)
        return nil
    }

    /// SED
    func setDecimalFlag(operand: Operand?) -> UInt16? {
        registers.P.formUnion(.D)
        return nil
    }

    /// SEI
    func setInterruptDisable(operand: Operand?) -> UInt16? {
        registers.P.formUnion(.I)
        return nil
    }

    // MARK: - Misc

    /// BRK
    func forceInterrupt(operand: Operand?) -> UInt16? {
        registers.P.formUnion(.B)
        return nil
    }
}
