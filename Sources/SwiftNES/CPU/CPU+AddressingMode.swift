// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
extension CPU {

    @inline(__always)
    mutating func implicit() -> UInt16 {
        return 0x00
    }

    @inline(__always)
    mutating func accumulator() -> UInt16 {
        return A.u16
    }

    @inline(__always)
    mutating func immediate() -> UInt16 {
        let operand = PC
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPage() -> UInt16 {
        let operand = read(at: PC).u16 & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageX() -> UInt16 {
        tick()

        let operand = (read(at: PC).u16 &+ X.u16) & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageY() -> UInt16 {
        tick()

        let operand = (read(at: PC).u16 &+ Y.u16) & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func absolute() -> UInt16 {
        let operand = readWord(at: PC)
        PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func absoluteX() -> UInt16 {
        let data = readWord(at: PC)
        let operand = data &+ X.u16 & 0xFFFF
        PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteXWithPenalty() -> UInt16 {
        let data = readWord(at: PC)
        let operand = data &+ X.u16 & 0xFFFF
        PC &+= 2

        if pageCrossed(value: data, operand: X) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func absoluteY() -> UInt16 {
        let data = readWord(at: PC)
        let operand = data &+ Y.u16 & 0xFFFF
        PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteYWithPenalty() -> UInt16 {
        let data = readWord(at: PC)
        let operand = data &+ Y.u16 & 0xFFFF
        PC &+= 2

        if pageCrossed(value: data, operand: Y) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func relative() -> UInt16 {
        let operand = read(at: PC).u16
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func indirect() -> UInt16 {
        let data = readWord(at: PC)
        let operand = readOnIndirect(operand: data)
        PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func indexedIndirect() -> UInt16 {
        let data = read(at: PC)
        let operand = readOnIndirect(operand: (data &+ X).u16 & 0xFF)
        PC &+= 1

        tick()

        return operand
    }

    @inline(__always)
    mutating func indirectIndexed() -> UInt16 {
        let data = read(at: PC).u16
        let operand = readOnIndirect(operand: data) &+ Y.u16
        PC &+= 1

        if pageCrossed(value: operand &- Y.u16, operand: Y) {
            tick()
        }
        return operand
    }
}
