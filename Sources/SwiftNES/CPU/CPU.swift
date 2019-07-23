typealias OpCode = UInt8

class CPU {
    var registers: Registers
    var memory: Memory
    let interruptLine: InterruptLine

    var instructions: [Instruction?]

    init(memory: Memory, interruptLine: InterruptLine) {
        self.registers = Registers(
            A: 0x00,
            X: 0x00,
            Y: 0x00,
            S: 0xFF,
            P: [Status.R, Status.B, Status.I],
            PC: 0x00
        )
        self.memory = memory
        self.interruptLine = interruptLine

        self.instructions = []  // Need all properties are initialized because 'self' is used in 'buildInstructionTable'
        self.instructions = buildInstructionTable()
    }

    func step() -> UInt {
        switch interruptLine.get() {
        case .RESET:
            return reset()
        case .NMI:
            return handleNMI()
        case .IRQ:
            return handleIRQ() ?? run()
        case .BRK:
            return handleBRK() ?? run()
        default:
            return run()
        }
    }

}

// MARK: - CPU.run implementation
extension CPU {
    func run() -> UInt {
        let opcode = fetch()
        let instruction = decode(opcode)
        let cycle = execute(instruction)
        return cycle
    }

    func fetch() -> OpCode {
        let opcode = memory.read(at: registers.PC)
        registers.PC += 1
        return opcode
    }

    func decode(_ opcode: OpCode) -> Instruction {
        if let ins = instructions[Int(opcode)] {
            return ins
        }
        return Instruction.NOP
    }

    func execute(_ instruction: Instruction) -> UInt {
        let (operand, pc) = fetchOperand(in: instruction.addressingMode)

        registers.PC += pc
        switch instruction.exec(operand) {
        case .jump(let addr):
            registers.PC = addr
        case .branch(let offset):
            registers.PC &+= offset
            return instruction.cycle + 1
        case .next:
            break // NOP
        }

        return instruction.cycle
    }
}

// MARK: - Stack
extension CPU {
    func pushStack(_ value: UInt8) {
        memory.write(value, at: registers.S.u16 + 0x100)
        registers.S -= 1
    }

    func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    func pullStack() -> UInt8 {
        registers.S += 1
        return memory.read(at: registers.S.u16 + 0x100)
    }

    func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 << 8 | lo.u16
    }
}

// Test subset of interrupt for switch-case
private func ~= (pattern: Interrupt, line: Interrupt) -> Bool {
    return line.contains(pattern)
}
