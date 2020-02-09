// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
typealias FetchOperand = (inout CPU) -> UInt16

@inline(__always)
func implicit(on cpu: inout CPU) -> UInt16 {
    return 0x00
}

@inline(__always)
func accumulator(on cpu: inout CPU) -> UInt16 {
    return cpu.A.u16
}

@inline(__always)
func immediate(on cpu: inout CPU) -> UInt16 {
    let operand = cpu.PC
    cpu.PC &+= 1
    return operand
}

@inline(__always)
func zeroPage(on cpu: inout CPU) -> UInt16 {
    let operand = cpu.read(at: cpu.PC).u16 & 0xFF
    cpu.PC &+= 1
    return operand
}

@inline(__always)
func zeroPageX(on cpu: inout CPU) -> UInt16 {
    cpu.tick()

    let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.X.u16) & 0xFF
    cpu.PC &+= 1
    return operand
}

@inline(__always)
func zeroPageY(on cpu: inout CPU) -> UInt16 {
    cpu.tick()

    let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.Y.u16) & 0xFF
    cpu.PC &+= 1
    return operand
}

@inline(__always)
func absolute(on cpu: inout CPU) -> UInt16 {
    let operand = cpu.readWord(at: cpu.PC)
    cpu.PC &+= 2
    return operand
}

@inline(__always)
func absoluteX(on cpu: inout CPU) -> UInt16 {
    let data = cpu.readWord(at: cpu.PC)
    let operand = data &+ cpu.X.u16 & 0xFFFF
    cpu.PC &+= 2
    cpu.tick()
    return operand
}

@inline(__always)
func absoluteXWithPenalty(on cpu: inout CPU) -> UInt16 {
    let data = cpu.readWord(at: cpu.PC)
    let operand = data &+ cpu.X.u16 & 0xFFFF
    cpu.PC &+= 2

    if pageCrossed(value: data, operand: cpu.X) {
        cpu.tick()
    }
    return operand
}

@inline(__always)
func absoluteY(on cpu: inout CPU) -> UInt16 {
    let data = cpu.readWord(at: cpu.PC)
    let operand = data &+ cpu.Y.u16 & 0xFFFF
    cpu.PC &+= 2
    cpu.tick()
    return operand
}

@inline(__always)
func absoluteYWithPenalty(on cpu: inout CPU) -> UInt16 {
    let data = cpu.readWord(at: cpu.PC)
    let operand = data &+ cpu.Y.u16 & 0xFFFF
    cpu.PC &+= 2

    if pageCrossed(value: data, operand: cpu.Y) {
        cpu.tick()
    }
    return operand
}

@inline(__always)
func relative(on cpu: inout CPU) -> UInt16 {
    let operand = cpu.read(at: cpu.PC).u16
    cpu.PC &+= 1
    return operand
}

@inline(__always)
func indirect(on cpu: inout CPU) -> UInt16 {
    let data = cpu.readWord(at: cpu.PC)
    let operand = cpu.readOnIndirect(operand: data)
    cpu.PC &+= 2
    return operand
}

@inline(__always)
func indexedIndirect(on cpu: inout CPU) -> UInt16 {
    let data = cpu.read(at: cpu.PC)
    let operand = cpu.readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF)
    cpu.PC &+= 1

    cpu.tick()

    return operand
}

@inline(__always)
func indirectIndexed(on cpu: inout CPU) -> UInt16 {
    let data = cpu.read(at: cpu.PC).u16
    let operand = cpu.readOnIndirect(operand: data) &+ cpu.Y.u16
    cpu.PC &+= 1

    if pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
        cpu.tick()
    }
    return operand
}
