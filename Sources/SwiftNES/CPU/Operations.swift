extension CPU {

    // Implements for Load/Store Operations

    /// LDA
    func loadAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = memory.read(addr: operand!)
        return .next
    }

    /// LDX
    func loadXRegister(operand: Operand?) -> PCUpdate {
        registers.X = memory.read(addr: operand!)
        return .next
    }

    /// LDY
    func loadYRegister(operand: Operand?) -> PCUpdate {
        registers.Y = memory.read(addr: operand!)
        return .next
    }

    /// STA
    func storeAccumulator(operand: Operand?) -> PCUpdate {
        memory.write(addr: operand!, data: registers.A)
        return .next
    }

    /// STX
    func storeXRegister(operand: Operand?) -> PCUpdate {
        memory.write(addr: operand!, data: registers.X)
        return .next
    }

    /// STY
    func storeYRegister(operand: Operand?) -> PCUpdate {
        memory.write(addr: operand!, data: registers.Y)
        return .next
    }

    // MARK: - Register Operations

    /// TAX
    func transferAccumulatorToX(operand: Operand?) -> PCUpdate {
        registers.X = registers.A
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

    /// TYA
    func transferYtoAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = registers.Y
        return .next
    }

    // MARK: - Stack instructions

    /// PHA
    func pushAccumulator(operand: Operand?) -> PCUpdate {
        pushStack(data: registers.A)
        return .next
    }

    /// PHP
    func pushProcessorStatus(operand: Operand?) -> PCUpdate {
        pushStack(data: registers.P.rawValue)
        return .next
    }

    /// PLA
    func pullAccumulator(operand: Operand?) -> PCUpdate {
        registers.A = pullStack()
        return .next
    }

    /// PLP
    func pullProcessorStatus(operand: Operand?) -> PCUpdate {
        registers.P = Status(rawValue: pullStack())
        return .next
    }

    // MARK: - Logical instructions

    /// AND
    func bitwiseANDwithAccumulator(operand: Operand?) -> PCUpdate {
        registers.A &= memory.read(addr: operand!)
        return .next
    }

    /// EOR
    func bitwiseExclusiveOR(operand: Operand?) -> PCUpdate {
        registers.A ^= memory.read(addr: operand!)
        return .next
    }

    /// ORA
    func bitwiseORwithAccumulator(operand: Operand?) -> PCUpdate {
        registers.A |= memory.read(addr: operand!)
        return .next
    }

    /// BIT
    func testBits(operand: Operand?) -> PCUpdate {
        let data = registers.A & memory.read(addr: operand!)
        registers.P.remove([.Z, .V, .N])
        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0b01000000 != 0 { registers.P.formUnion(.V) }
        if data & 0b10000000 != 0 { registers.P.formUnion(.N) }
        return .next
    }

    // MARK: - Arithmetic instructions

    /// ADC
    func addWithCarry(operand: Operand?) -> PCUpdate {
        let a = Int16(registers.A)
        let val = Int16(memory.read(addr: operand!))
        var result = a + val
        if registers.P.contains(.C) { result += 1 }

        registers.P.remove([.C, .Z, .V, .N])
        if result & 0x100 == 0x100 { registers.P.formUnion(.C)}
        // same sign -> different sign
        if (a ^ val) & 0x80 != 0x80 && (a ^ result) & 0x80 == 0x80 {
            registers.P.formUnion(.V)
        }
        registers.A = UInt8(result & 0xFF)
        return .next
    }

    /// SBC
    func subtractWithCarry(operand: Operand?) -> PCUpdate {
        let a = Int16(registers.A)
        let val = Int16(memory.read(addr: operand!))
        var result = a - val
        if registers.P.contains(.C) { result -= 1 }

        registers.P.remove([.C, .Z, .V, .N])
        if result & 0x100 != 0x100 { registers.P.formUnion(.C)}
        // different sign -> same sign
        if (a ^ val) & 0x80 == 0x80 && (a ^ result) & 0x80 != 0x80 {
            registers.P.formUnion(.V)
        }
        registers.A = UInt8(result & 0xFF)
        return .next
    }

    /// CMP
    func compareAccumulator(operand: Operand?) -> PCUpdate {
        let cmp = Int16(registers.A) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return .next
    }

    /// CPX
    func compareXRegister(operand: Operand?) -> PCUpdate {
        let cmp = Int16(registers.X) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return .next
    }

    /// CPY
    func compareYRegister(operand: Operand?) -> PCUpdate {
        let cmp = Int16(registers.Y) - Int16(memory.read(addr: operand!))

        registers.P.remove([.C, .Z, .N])
        if cmp == 0 { registers.P.formUnion(.Z) }
        if cmp & 0x80 != 0 { registers.P.formUnion(.N) }
        if 0 < cmp { registers.P.formUnion(.C) }

        return .next
    }

    // MARK: - Increment/Decrement instructions

    /// INC
    func incrementMemory(operand: Operand?) -> PCUpdate {
        let result = memory.read(addr: operand!) &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: result)

        return .next
    }

    /// INX
    func incrementX(_: Operand?) -> PCUpdate {
        let result = registers.X &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return .next
    }

    /// INY
    func incrementY(operand: Operand?) -> PCUpdate {
        let result = registers.Y &+ 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.Y = result

        return .next
    }

    /// DEC
    func decrementMemory(operand: Operand?) -> PCUpdate {
        let result = memory.read(addr: operand!) &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: result)

        return .next
    }

    /// DEX
    func decrementX(operand: Operand?) -> PCUpdate {
        let result = registers.X &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return .next
    }

    /// DEY
    func decrementY(operand: Operand?) -> PCUpdate {
        let result = registers.Y &- 1

        if result == 0 { registers.P.formUnion(.Z) }
        if result & 0x80 != 0 { registers.P.formUnion(.N) }

        registers.X = result

        return .next
    }

    // MARK: - Shift instructions

    /// ASL
    func arithmeticShiftLeft(operand: Operand?) -> PCUpdate {
        var data = memory.read(addr: operand!)

        registers.P.remove([.C, .Z, .N])
        if data & 0x80 != 0 { registers.P.formUnion(.C) }

        data <<= 1

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)

        return .next
    }

    func arithmeticShiftLeftForAccumulator(operand: Operand?) -> PCUpdate {
        registers.P.remove([.C, .Z, .N])
        if registers.A & 0x80 != 0 { registers.P.formUnion(.C) }

        registers.A <<= 1

        return .next
    }

    /// LSR
    func logicalShiftRight(operand: Operand?) -> PCUpdate {
        var data = memory.read(addr: operand!)

        registers.P.remove([.C, .Z, .N])
        if data & 0x80 != 0 { registers.P.formUnion(.C) }

        data >>= 1

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)

        return .next
    }

    func logicalShiftRightForAccumulator(operand: Operand?) -> PCUpdate {
        registers.P.remove([.C, .Z, .N])
        if registers.A & 0x80 != 0 { registers.P.formUnion(.C) }

        registers.A >>= 1

        return .next
    }

    /// ROL
    func rotateLeft(operand: Operand?) -> PCUpdate {
        var data = memory.read(addr: operand!)
        let c = data & 0x80

        data <<= 1
        if registers.P.contains(.C) { data |= 0x01 }

        registers.P.remove([.C, .Z, .N])
        if c == 0x80 { registers.P.formUnion(.C) }

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)

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
        var data = memory.read(addr: operand!)
        let c = data & 0x01

        data >>= 1
        if registers.P.contains(.C) { data |= 0x80 }

        registers.P.remove([.C, .Z, .N])
        if c == 1 { registers.P.formUnion(.C) }

        if data == 0 { registers.P.formUnion(.Z) }
        if data & 0x80 != 0 { registers.P.formUnion(.N) }

        memory.write(addr: operand!, data: data)
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
        return .jump(addr: pullStack() + 1)
    }

    /// RTI
    func returnFromInterrupt(operand: Operand?) -> PCUpdate {
        registers.P = Status(rawValue: pullStack())
        return .jump(addr: pullStack())
    }

    // MARK: - Branch instructions

    /// BCC
    func branchIfCarryClear(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.C) {
            return .jump(addr: operand!)
        }
        return .next
    }

    /// BCS
    func branchIfCarrySet(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.C) {
            return .jump(addr: operand!)
        }
        return .next
    }

    /// BEQ
    func branchIfEqual(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.Z) {
            return .jump(addr: operand!)
        }
        return .next
    }

    /// BMI
    func branchIfMinus(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.N) {
            return .jump(addr: operand!)
        }
        return .next
    }

    /// BNE
    func branchIfNotEqual(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.Z) {
            return .jump(addr: operand!)
        }
        return .next
    }

    /// BPL
    func branchIfPlus(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.N) {
            return .jump(addr: operand!)
        }
        return .next
    }

    /// BVC
    func branchIfOverflowClear(operand: Operand?) -> PCUpdate {
        if !registers.P.contains(.V) {
            return .jump(addr: operand!)
        }
        return .next
    }

    /// BVS
    func branchIfOverflowSet(operand: Operand?) -> PCUpdate {
        if registers.P.contains(.V) {
            return .jump(addr: operand!)
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
        registers.P.formUnion(.B)
        return .next
    }
}
