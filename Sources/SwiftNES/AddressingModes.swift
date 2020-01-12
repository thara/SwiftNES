typealias AddressingModeFunc = (inout CPUState, inout CPUMemory) -> UInt16

func implicit(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    return 0x00
}

func accumulator(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    return cpu.A.u16
}

func immediate(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer { cpu.PC &+= 1 }
    return cpu.PC
}

func zeroPage(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer { cpu.PC &+= 1 }
    return memory[cpu.PC].u16 & 0xFF
}

func zeroPageX(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer {
        cpu.tick()
        cpu.PC &+= 1
    }
    return (memory[cpu.PC].u16 &+ cpu.X.u16) & 0xFF
}

func zeroPageY(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer {
        cpu.tick()
        cpu.PC &+= 1
    }
    return (memory[cpu.PC].u16 &+ cpu.Y.u16) & 0xFF
}

func absolute(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer { cpu.PC &+= 2 }
    return memory.readWord(at: cpu.PC)
}

func absoluteX(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer {
        cpu.tick()
        cpu.PC &+= 2
    }
    let data = memory.readWord(at: cpu.PC)
    return data &+ cpu.X.u16 & 0xFFFF
}

func absoluteXWithPenalty(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
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

func absoluteY(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer {
        cpu.tick()
        cpu.PC &+= 2
    }
    let data = memory.readWord(at: cpu.PC)
    return data &+ cpu.Y.u16 & 0xFFFF
}

func absoluteYWithPenalty(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
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

func relative(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer {
        cpu.PC &+= 1
    }
    return memory[cpu.PC].u16
}

func indirect(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer {
        cpu.PC &+= 2
    }
    let data = memory.readWord(at: cpu.PC)
    return readOnIndirect(operand: data, from: &memory)
}

func indexedIndirect(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
    defer {
        cpu.tick()
        cpu.PC &+= 1
    }
    let data = memory[cpu.PC]
    return readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF, from: &memory)
}

func indirectIndexed(cpu: inout CPUState, memory: inout CPUMemory) -> UInt16 {
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
