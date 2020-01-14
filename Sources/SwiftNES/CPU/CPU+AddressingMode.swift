// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
extension CPU {

    @inline(__always)
    mutating func implicit(from memory: inout Memory) -> UInt16 {
        return 0x00
    }

    @inline(__always)
    mutating func accumulator(from memory: inout Memory) -> UInt16 {
        return A.u16
    }

    @inline(__always)
    mutating func immediate(from memory: inout Memory) -> UInt16 {
        let operand = PC
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPage(from memory: inout Memory) -> UInt16 {
        let operand = read(at: PC, from: &memory).u16 & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageX(from memory: inout Memory) -> UInt16 {
        tick()

        let operand = (read(at: PC, from: &memory).u16 &+ X.u16) & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func zeroPageY(from memory: inout Memory) -> UInt16 {
        tick()

        let operand = (read(at: PC, from: &memory).u16 &+ Y.u16) & 0xFF
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func absolute(from memory: inout Memory) -> UInt16 {
        let operand = readWord(at: PC, from: &memory)
        PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func absoluteX(from memory: inout Memory) -> UInt16 {
        let data = readWord(at: PC, from: &memory)
        let operand = data &+ X.u16 & 0xFFFF
        PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteXWithPenalty(from memory: inout Memory) -> UInt16 {
        let data = readWord(at: PC, from: &memory)
        let operand = data &+ X.u16 & 0xFFFF
        PC &+= 2

        if pageCrossed(value: data, operand: X) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func absoluteY(from memory: inout Memory) -> UInt16 {
        let data = readWord(at: PC, from: &memory)
        let operand = data &+ Y.u16 & 0xFFFF
        PC &+= 2
        tick()
        return operand
    }

    @inline(__always)
    mutating func absoluteYWithPenalty(from memory: inout Memory) -> UInt16 {
        let data = readWord(at: PC, from: &memory)
        let operand = data &+ Y.u16 & 0xFFFF
        PC &+= 2

        if pageCrossed(value: data, operand: Y) {
            tick()
        }
        return operand
    }

    @inline(__always)
    mutating func relative(from memory: inout Memory) -> UInt16 {
        let operand = read(at: PC, from: &memory).u16
        PC &+= 1
        return operand
    }

    @inline(__always)
    mutating func indirect(from memory: inout Memory) -> UInt16 {
        let data = readWord(at: PC, from: &memory)
        let operand = readOnIndirect(operand: data, from: &memory)
        PC &+= 2
        return operand
    }

    @inline(__always)
    mutating func indexedIndirect(from memory: inout Memory) -> UInt16 {
        let data = read(at: PC, from: &memory)
        let operand = readOnIndirect(operand: (data &+ X).u16 & 0xFF, from: &memory)
        PC &+= 1

        tick()

        return operand
    }

    @inline(__always)
    mutating func indirectIndexed(from memory: inout Memory) -> UInt16 {
        let data = read(at: PC, from: &memory).u16
        let operand = readOnIndirect(operand: data, from: &memory) &+ Y.u16
        PC &+= 1

        if pageCrossed(value: operand &- Y.u16, operand: Y) {
            tick()
        }
        return operand
    }
}
