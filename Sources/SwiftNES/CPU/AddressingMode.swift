// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes

struct AddressingMode {
    typealias FetchOperand = (CPU) -> UInt16

    let id: Int
    let fetchOperand: FetchOperand

    init(id: Int = #line, fetchOperand: @escaping FetchOperand) {
        self.id = id
        self.fetchOperand = fetchOperand
    }

    static let implicit = AddressingMode { cpu in
        return 0x00
    }

    static let accumulator = AddressingMode { cpu in
        return cpu.registers.A.u16
    }

    static let immediate = AddressingMode { cpu in
        let operand = cpu.registers.PC
        cpu.registers.PC &+= 1
        return operand
    }

    static let zeroPage = AddressingMode { cpu in
        let operand = cpu.read(at: cpu.registers.PC).u16 & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static let zeroPageX = AddressingMode { cpu in
        cpu.tick()

        let operand = (cpu.read(at: cpu.registers.PC).u16 &+ cpu.registers.X.u16) & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static let zeroPageY = AddressingMode { cpu in
        cpu.tick()

        let operand = (cpu.read(at: cpu.registers.PC).u16 &+ cpu.registers.Y.u16) & 0xFF
        cpu.registers.PC &+= 1
        return operand
    }

    static let absolute = AddressingMode { cpu in
        let operand = cpu.readWord(at: cpu.registers.PC)
        cpu.registers.PC &+= 2
        return operand
    }

    static let absoluteX = AddressingMode { cpu in
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.X.u16 & 0xFFFF
        cpu.registers.PC &+= 2
        cpu.tick()
        return operand
    }

    static let absoluteXWithPenalty = AddressingMode { cpu in
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.X.u16 & 0xFFFF
        cpu.registers.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.registers.X) {
            cpu.tick()
        }
        return operand
    }

    static let absoluteY = AddressingMode { cpu in
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.Y.u16 & 0xFFFF
        cpu.registers.PC &+= 2
        cpu.tick()
        return operand
    }

    static let absoluteYWithPenalty = AddressingMode { cpu in
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = data &+ cpu.registers.Y.u16 & 0xFFFF
        cpu.registers.PC &+= 2

        if CPU.pageCrossed(value: data, operand: cpu.registers.Y) {
            cpu.tick()
        }
        return operand
    }

    static let relative = AddressingMode { cpu in
        let operand = cpu.read(at: cpu.registers.PC).u16
        cpu.registers.PC &+= 1
        return operand
    }

    static let indirect = AddressingMode { cpu in
        let data = cpu.readWord(at: cpu.registers.PC)
        let operand = cpu.readOnIndirect(operand: data)
        cpu.registers.PC &+= 2
        return operand
    }

    static let indexedIndirect = AddressingMode { cpu in
        let data = cpu.read(at: cpu.registers.PC)
        let operand = cpu.readOnIndirect(operand: (data &+ cpu.registers.X).u16 & 0xFF)
        cpu.registers.PC &+= 1

        cpu.tick()

        return operand
    }

    static let indirectIndexed = AddressingMode { cpu in
        let data = cpu.read(at: cpu.registers.PC).u16
        let operand = cpu.readOnIndirect(operand: data) &+ cpu.registers.Y.u16
        cpu.registers.PC &+= 1

        if CPU.pageCrossed(value: operand &- cpu.registers.Y.u16, operand: cpu.registers.Y) {
            cpu.tick()
        }
        return operand
    }
}

func ~=(a: AddressingMode, b: AddressingMode) -> Bool {
  return a.id == b.id
}
