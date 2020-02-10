// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
typealias FetchOperand<T: AddressingMode> = (T) -> UInt16

protocol AddressingMode: ReadWrite {
    static func implicit(on: Self) -> UInt16
    static func accumulator(on: Self) -> UInt16
    static func immediate(on: Self) -> UInt16
    static func zeroPage(on: Self) -> UInt16
    static func zeroPageX(on: Self) -> UInt16
    static func zeroPageY(on: Self) -> UInt16
    static func absolute(on: Self) -> UInt16
    static func absoluteX(on: Self) -> UInt16
    static func absoluteXWithPenalty(on: Self) -> UInt16
    static func absoluteY(on: Self) -> UInt16
    static func absoluteYWithPenalty(on: Self) -> UInt16
    static func relative(on: Self) -> UInt16
    static func indirect(on: Self) -> UInt16
    static func indexedIndirect(on: Self) -> UInt16
    static func indirectIndexed(on: Self) -> UInt16
}

extension NES: AddressingMode {

    @inline(__always)
    static func implicit(on nes: NES) -> UInt16 {
        return 0x00
    }

    @inline(__always)
    static func accumulator(on nes: NES) -> UInt16 {
        return nes.cpu.A.u16
    }

    @inline(__always)
    static func immediate(on nes: NES) -> UInt16 {
        let operand = nes.cpu.PC
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func zeroPage(on nes: NES) -> UInt16 {
        let operand = read(at: nes.cpu.PC, from: nes).u16 & 0xFF
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func zeroPageX(on nes: NES) -> UInt16 {
        nes.cpu.tick()

        let operand = (read(at: nes.cpu.PC, from: nes).u16 &+ nes.cpu.X.u16) & 0xFF
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func zeroPageY(on nes: NES) -> UInt16 {
        nes.cpu.tick()

        let operand = (read(at: nes.cpu.PC, from: nes).u16 &+ nes.cpu.Y.u16) & 0xFF
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func absolute(on nes: NES) -> UInt16 {
        let operand = readWord(at: nes.cpu.PC, from: nes)
        nes.cpu.PC &+= 2
        return operand
    }

    @inline(__always)
    static func absoluteX(on nes: NES) -> UInt16 {
        let data = readWord(at: nes.cpu.PC, from: nes)
        let operand = data &+ nes.cpu.X.u16 & 0xFFFF
        nes.cpu.PC &+= 2
        nes.cpu.tick()
        return operand
    }

    @inline(__always)
    static func absoluteXWithPenalty(on nes: NES) -> UInt16 {
        let data = readWord(at: nes.cpu.PC, from: nes)
        let operand = data &+ nes.cpu.X.u16 & 0xFFFF
        nes.cpu.PC &+= 2

        if pageCrossed(value: data, operand: nes.cpu.X) {
            nes.cpu.tick()
        }
        return operand
    }

    @inline(__always)
    static func absoluteY(on nes: NES) -> UInt16 {
        let data = readWord(at: nes.cpu.PC, from: nes)
        let operand = data &+ nes.cpu.Y.u16 & 0xFFFF
        nes.cpu.PC &+= 2
        nes.cpu.tick()
        return operand
    }

    @inline(__always)
    static func absoluteYWithPenalty(on nes: NES) -> UInt16 {
        let data = readWord(at: nes.cpu.PC, from: nes)
        let operand = data &+ nes.cpu.Y.u16 & 0xFFFF
        nes.cpu.PC &+= 2

        if pageCrossed(value: data, operand: nes.cpu.Y) {
            nes.cpu.tick()
        }
        return operand
    }

    @inline(__always)
    static func relative(on nes: NES) -> UInt16 {
        let operand = read(at: nes.cpu.PC, from: nes).u16
        nes.cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func indirect(on nes: NES) -> UInt16 {
        let data = readWord(at: nes.cpu.PC, from: nes)
        let operand = readOnIndirect(operand: data, from: nes)
        nes.cpu.PC &+= 2
        return operand
    }

    @inline(__always)
    static func indexedIndirect(on nes: NES) -> UInt16 {
        let data = read(at: nes.cpu.PC, from: nes)
        let operand = readOnIndirect(operand: (data &+ nes.cpu.X).u16 & 0xFF, from: nes)
        nes.cpu.PC &+= 1

        nes.cpu.tick()

        return operand
    }

    @inline(__always)
    static func indirectIndexed(on nes: NES) -> UInt16 {
        let data = read(at: nes.cpu.PC, from: nes).u16
        let operand = readOnIndirect(operand: data, from: nes) &+ nes.cpu.Y.u16
        nes.cpu.PC &+= 1

        if pageCrossed(value: operand &- nes.cpu.Y.u16, operand: nes.cpu.Y) {
            nes.cpu.tick()
        }
        return operand
    }
}
