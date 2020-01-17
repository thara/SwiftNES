// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes

@inline(__always)
func implicit(from nes: inout NES) -> UInt16 {
    return 0x00
}

@inline(__always)
func accumulator(from nes: inout NES) -> UInt16 {
    return nes.cpu.A.u16
}

@inline(__always)
func immediate(from nes: inout NES) -> UInt16 {
    let operand = nes.cpu.PC
    nes.cpu.PC &+= 1
    return operand
}

@inline(__always)
func zeroPage(from nes: inout NES) -> UInt16 {
    let operand = readCPU(at: nes.cpu.PC, from: &nes).u16 & 0xFF
    nes.cpu.PC &+= 1
    return operand
}

@inline(__always)
func zeroPageX(from nes: inout NES) -> UInt16 {
    nes.cpu.tick()

    let operand = (readCPU(at: nes.cpu.PC, from: &nes).u16 &+ nes.cpu.X.u16) & 0xFF
    nes.cpu.PC &+= 1
    return operand
}

@inline(__always)
func zeroPageY(from nes: inout NES) -> UInt16 {
    nes.cpu.tick()

    let operand = (readCPU(at: nes.cpu.PC, from: &nes).u16 &+ nes.cpu.Y.u16) & 0xFF
    nes.cpu.PC &+= 1
    return operand
}

@inline(__always)
func absolute(from nes: inout NES) -> UInt16 {
    let operand = readWord(at: nes.cpu.PC, from: &nes)
    nes.cpu.PC &+= 2
    return operand
}

@inline(__always)
func absoluteX(from nes: inout NES) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    let operand = data &+ nes.cpu.X.u16 & 0xFFFF
    nes.cpu.PC &+= 2
    nes.cpu.tick()
    return operand
}

@inline(__always)
func absoluteXWithPenalty(from nes: inout NES) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    let operand = data &+ nes.cpu.X.u16 & 0xFFFF
    nes.cpu.PC &+= 2

    if pageCrossed(value: data, operand: nes.cpu.X) {
        nes.cpu.tick()
    }
    return operand
}

@inline(__always)
func absoluteY(from nes: inout NES) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    let operand = data &+ nes.cpu.Y.u16 & 0xFFFF
    nes.cpu.PC &+= 2
    nes.cpu.tick()
    return operand
}

@inline(__always)
func absoluteYWithPenalty(from nes: inout NES) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    let operand = data &+ nes.cpu.Y.u16 & 0xFFFF
    nes.cpu.PC &+= 2

    if pageCrossed(value: data, operand: nes.cpu.Y) {
        nes.cpu.tick()
    }
    return operand
}

@inline(__always)
func relative(from nes: inout NES) -> UInt16 {
    let operand = readCPU(at: nes.cpu.PC, from: &nes).u16
    nes.cpu.PC &+= 1
    return operand
}

@inline(__always)
func indirect(from nes: inout NES) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    let operand = readOnIndirect(operand: data) { op in readCPU(at: op, from: &nes) }
    nes.cpu.PC &+= 2
    return operand
}

@inline(__always)
func indexedIndirect(from nes: inout NES) -> UInt16 {
    let data = readCPU(at: nes.cpu.PC, from: &nes)
    let operand = readOnIndirect(operand: (data &+ nes.cpu.X).u16 & 0xFF) { op in readCPU(at: op, from: &nes) }
    nes.cpu.PC &+= 1

    nes.cpu.tick()

    return operand
}

@inline(__always)
func indirectIndexed(from nes: inout NES) -> UInt16 {
    let data = readCPU(at: nes.cpu.PC, from: &nes).u16
    let operand = readOnIndirect(operand: data) { op in readCPU(at: op, from: &nes) } &+ nes.cpu.Y.u16
    nes.cpu.PC &+= 1

    if pageCrossed(value: operand &- nes.cpu.Y.u16, operand: nes.cpu.Y) {
        nes.cpu.tick()
    }
    return operand
}
