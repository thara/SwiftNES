class CPUEmulator: CPU {
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
