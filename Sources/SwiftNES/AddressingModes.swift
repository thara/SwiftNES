typealias AddressingModeFunc = (inout NESState) -> UInt16

func implicit(nes: inout NESState) -> UInt16 {
    return 0x00
}

func accumulator(nes: inout NESState) -> UInt16 {
    return nes.cpu.A.u16
}

func immediate(nes: inout NESState) -> UInt16 {
    return nes.cpu.PC
}

func zeroPage(nes: inout NESState) -> UInt16 {
    return read(at: nes.cpu.PC, from: &nes).u16 & 0xFF
}

func zeroPageX(nes: inout NESState) -> UInt16 {
    return (read(at: nes.cpu.PC, from: &nes).u16 &+ nes.cpu.X.u16) & 0xFF
}

func zeroPageY(nes: inout NESState) -> UInt16 {
    return (read(at: nes.cpu.PC, from: &nes).u16 &+ nes.cpu.Y.u16) & 0xFF
}

func absolute(nes: inout NESState) -> UInt16 {
    return readWord(at: nes.cpu.PC, from: &nes)
}

func absoluteX(nes: inout NESState) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    return data &+ nes.cpu.X.u16 & 0xFFFF
}

func absoluteXWithPenalty(nes: inout NESState) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    let operand = data &+ nes.cpu.X.u16 & 0xFFFF
    tickOnPageCrossed(value: data, operand: nes.cpu.X, nes: &nes)
    return operand
}

func absoluteY(nes: inout NESState) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    return data &+ nes.cpu.Y.u16 & 0xFFFF
}

func absoluteYWithPenalty(nes: inout NESState) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    let operand = data &+ nes.cpu.Y.u16 & 0xFFFF
    tickOnPageCrossed(value: data, operand: nes.cpu.Y, nes: &nes)
    return operand
}

func relative(nes: inout NESState) -> UInt16 {
    return read(at: nes.cpu.PC, from: &nes).u16
}

func indirect(nes: inout NESState) -> UInt16 {
    let data = readWord(at: nes.cpu.PC, from: &nes)
    return readOnIndirect(operand: data, from: &nes)
}

func indexedIndirect(nes: inout NESState) -> UInt16 {
    let data = read(at: nes.cpu.PC, from: &nes)
    return readOnIndirect(operand: (data &+ nes.cpu.X).u16 & 0xFF, from: &nes)
}

func indirectIndexed(nes: inout NESState) -> UInt16 {
    let data = read(at: nes.cpu.PC, from: &nes).u16
    let operand = readOnIndirect(operand: data, from: &nes) &+ nes.cpu.Y.u16
    tickOnPageCrossed(value: operand &- nes.cpu.Y.u16, operand: nes.cpu.Y, nes: &nes)
    return operand
}

func tickOnPageCrossed(value: UInt16, operand: UInt8, nes: inout NESState) {
    tickOnPageCrossed(value: value, operand: operand.u16, nes: &nes)
}

func tickOnPageCrossed(value: UInt16, operand: UInt16, nes: inout NESState) {
    if ((value &+ operand) & 0xFF00) != (value & 0xFF00) {
        nes.tick()
    }
}

func tickOnPageCrossed(value: Int, operand: Int, nes: inout NESState) {
    if ((value &+ operand) & 0xFF00) != (value & 0xFF00) {
        nes.tick()
    }
}

func readOnIndirect(operand: UInt16, from nes: inout NESState) -> UInt16 {
    let low = read(at: operand, from: &nes).u16
    let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF), from: &nes).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
    return low | high
}
