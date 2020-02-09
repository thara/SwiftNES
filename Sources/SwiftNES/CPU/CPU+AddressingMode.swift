// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
typealias FetchOperand = (inout CPU) -> UInt16

extension CPU {

    @inline(__always)
    static func implicit(on cpu: inout CPU) -> UInt16 {
        return 0x00
    }

    @inline(__always)
    static func accumulator(on cpu: inout CPU) -> UInt16 {
        return cpu.A.u16
    }

    @inline(__always)
    static func immediate(on cpu: inout CPU) -> UInt16 {
        let operand = cpu.PC
        cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func zeroPage(on cpu: inout CPU) -> UInt16 {
        let operand = cpu.read(at: cpu.PC).u16 & 0xFF
        cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func zeroPageX(on cpu: inout CPU) -> UInt16 {
        cpu.tick()

        let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.X.u16) & 0xFF
        cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func zeroPageY(on cpu: inout CPU) -> UInt16 {
        cpu.tick()

        let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.Y.u16) & 0xFF
        cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func absolute(on cpu: inout CPU) -> UInt16 {
        let operand = cpu.readWord(at: cpu.PC)
        cpu.PC &+= 2
        return operand
    }

    @inline(__always)
    static func absoluteX(on cpu: inout CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.X.u16 & 0xFFFF
        cpu.PC &+= 2
        cpu.tick()
        return operand
    }

    @inline(__always)
    static func absoluteXWithPenalty(on cpu: inout CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.X.u16 & 0xFFFF
        cpu.PC &+= 2

        if pageCrossed(value: data, operand: cpu.X) {
            cpu.tick()
        }
        return operand
    }

    @inline(__always)
    static func absoluteY(on cpu: inout CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.Y.u16 & 0xFFFF
        cpu.PC &+= 2
        cpu.tick()
        return operand
    }

    @inline(__always)
    static func absoluteYWithPenalty(on cpu: inout CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.Y.u16 & 0xFFFF
        cpu.PC &+= 2

        if pageCrossed(value: data, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }

    @inline(__always)
    static func relative(on cpu: inout CPU) -> UInt16 {
        let operand = cpu.read(at: cpu.PC).u16
        cpu.PC &+= 1
        return operand
    }

    @inline(__always)
    static func indirect(on cpu: inout CPU) -> UInt16 {
        let data = cpu.readWord(at: cpu.PC)
        let operand = cpu.readOnIndirect(operand: data)
        cpu.PC &+= 2
        return operand
    }

    @inline(__always)
    static func indexedIndirect(on cpu: inout CPU) -> UInt16 {
        let data = cpu.read(at: cpu.PC)
        let operand = cpu.readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF)
        cpu.PC &+= 1

        cpu.tick()

        return operand
    }

    @inline(__always)
    static func indirectIndexed(on cpu: inout CPU) -> UInt16 {
        let data = cpu.read(at: cpu.PC).u16
        let operand = cpu.readOnIndirect(operand: data) &+ cpu.Y.u16
        cpu.PC &+= 1

        if pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }
}
