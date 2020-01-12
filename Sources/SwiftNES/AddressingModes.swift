typealias AddressingModeFunc = (inout CPUState, inout CPUMemory) -> UInt16

struct AddressingModes {
    private let delegate: AddressingModeFunc

    init(f: @escaping AddressingModeFunc) {
        self.delegate = f
    }

    func callAsFunction(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
        return delegate(&cpu, &memory)
    }

    static let implicit = AddressingModes { _, _ in 0x00 }

    static let accumulator = AddressingModes { cpu, _ in cpu.A.u16 }

    static let immediate = AddressingModes { cpu, memory in
        defer { cpu.PC &+= 1 }
        return cpu.PC
    }

    static let zeroPage = AddressingModes { cpu, memory in
        defer { cpu.PC &+= 1 }
        return memory[cpu.PC].u16 & 0xFF
    }

    static let zeroPageX = AddressingModes { cpu, memory in
        defer {
            cpu.tick()
            cpu.PC &+= 1
        }
        return (memory[cpu.PC].u16 &+ cpu.X.u16) & 0xFF
    }

    static let zeroPageY = AddressingModes { cpu, memory in
        defer {
            cpu.tick()
            cpu.PC &+= 1
        }
        return (memory[cpu.PC].u16 &+ cpu.Y.u16) & 0xFF
    }

    static let absolute = AddressingModes { cpu, memory in
        defer { cpu.PC &+= 2 }
        return memory.readWord(at: cpu.PC)
    }

    static let absoluteX = AddressingModes { cpu, memory in
        defer {
            cpu.tick()
            cpu.PC &+= 2
        }
        let data = memory.readWord(at: cpu.PC)
        return data &+ cpu.X.u16 & 0xFFFF
    }

    static let absoluteXWithPenalty = AddressingModes { cpu, memory in
        defer {
            cpu.PC &+= 2
        }
        let data = memory.readWord(at: cpu.PC)
        let operand = data &+ cpu.X.u16 & 0xFFFF
        if pageCrossed(value: data, operand: cpu.X) {
            cpu.tick()
        }
        return operand
    }

    static let absoluteY = AddressingModes { cpu, memory in
        defer {
            cpu.tick()
            cpu.PC &+= 2
        }
        let data = memory.readWord(at: cpu.PC)
        return data &+ cpu.Y.u16 & 0xFFFF
    }

    static let absoluteYWithPenalty = AddressingModes { cpu, memory in
        defer {
            cpu.PC &+= 2
        }
        let data = memory.readWord(at: cpu.PC)
        let operand = data &+ cpu.Y.u16 & 0xFFFF
        if pageCrossed(value: data, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }

    static let relative = AddressingModes { cpu, memory in
        defer {
            cpu.PC &+= 1
        }
        return memory[cpu.PC].u16
    }

    static let indirect = AddressingModes { cpu, memory in
        defer {
            cpu.PC &+= 2
        }
        let data = memory.readWord(at: cpu.PC)
        return readOnIndirect(operand: data, from: &memory)
    }

    static let indexedIndirect = AddressingModes { cpu, memory in
        defer {
            cpu.tick()
            cpu.PC &+= 1
        }
        let data = memory[cpu.PC]
        return readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF, from: &memory)
    }

    static let indirectIndexed = AddressingModes { cpu, memory in
        defer {
            cpu.PC &+= 1
        }
        let data = memory[cpu.PC].u16
        let operand = readOnIndirect(operand: data, from: &memory) &+ cpu.Y.u16
        if pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }
}

func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
    return pageCrossed(value: value, operand: operand.u16)
}

func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

func pageCrossed(value: Int, operand: Int) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

func readOnIndirect(operand: UInt16, from memory: inout CPUMemory) -> UInt16 {
    let low = memory[operand].u16
    let high = memory[operand & 0xFF00 | ((operand &+ 1) & 0x00FF)].u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
    return low | high
}
