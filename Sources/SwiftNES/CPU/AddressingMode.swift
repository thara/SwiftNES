// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
protocol AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand
}

struct Implicit: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        return 0x00
    }
}

struct Accumulator: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        return cpu.A.u16
    }
}

struct Immediate: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let operand = cpu.PC
        cpu.PC &+= 1
        return operand
    }
}

struct ZeroPage: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let operand = cpu.read(at: cpu.PC).u16 & 0xFF
        cpu.PC &+= 1
        return operand
    }
}

enum ZeroPageX: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        cpu.tick()

        let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.X.u16) & 0xFF
        cpu.PC &+= 1
        return operand
    }
}

enum ZeroPageY: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        cpu.tick()

        let operand = (cpu.read(at: cpu.PC).u16 &+ cpu.Y.u16) & 0xFF
        cpu.PC &+= 1
        return operand
    }
}

enum Absolute: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let operand = cpu.readWord(at: cpu.PC)
        cpu.PC &+= 2
        return operand
    }
}

enum AbsoluteX: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.X.u16 & 0xFFFF
        cpu.PC &+= 2
        cpu.tick()
        return operand
    }
}

enum AbsoluteXWithPenalty: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.X.u16 & 0xFFFF
        cpu.PC &+= 2

        if pageCrossed(value: data, operand: cpu.X) {
            cpu.tick()
        }
        return operand
    }
}

enum AbsoluteY: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.Y.u16 & 0xFFFF
        cpu.PC &+= 2
        cpu.tick()
        return operand
    }
}

enum AbsoluteYWithPenalty: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let data = cpu.readWord(at: cpu.PC)
        let operand = data &+ cpu.Y.u16 & 0xFFFF
        cpu.PC &+= 2

        if pageCrossed(value: data, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }
}

enum Relative: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let operand = cpu.read(at: cpu.PC).u16
        cpu.PC &+= 1
        return operand
    }
}

enum Indirect: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let data = cpu.readWord(at: cpu.PC)
        let operand = cpu.readOnIndirect(operand: data)
        cpu.PC &+= 2
        return operand
    }
}

enum IndexedIndirect: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let data = cpu.read(at: cpu.PC)
        let operand = cpu.readOnIndirect(operand: (data &+ cpu.X).u16 & 0xFF)
        cpu.PC &+= 1

        cpu.tick()

        return operand
    }
}

enum IndirectIndexed: AddressingMode {
    static func getOperand(cpu: inout CPU) -> Operand {
        let data = cpu.read(at: cpu.PC).u16
        let operand = cpu.readOnIndirect(operand: data) &+ cpu.Y.u16
        cpu.PC &+= 1

        if pageCrossed(value: operand &- cpu.Y.u16, operand: cpu.Y) {
            cpu.tick()
        }
        return operand
    }
}
