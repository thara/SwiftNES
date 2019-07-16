class CPUEmulator: CPU {
    var registers: Registers
    var memory: CPUAddressSpace
    var interrupt: Interrupt?

    var instructions: [Instruction?]

    init() {
        registers = Registers(
            A: 0x00,
            X: 0x00,
            Y: 0x00,
            S: 0x00,
            P: [Status.R, Status.B, Status.I],
            PC: 0x00
        )
        memory = CPUAddressSpace()
        instructions = []  // Need all properties are initialized because 'self' is used in 'buildInstructionTable'
        instructions = buildInstructionTable()
    }

    func fetch() -> OpCode {
        let opcode = memory.read(addr: registers.PC)
        registers.PC += 1
        return opcode
    }

    func decode(_ opcode: OpCode) -> Instruction {
        if let ins = instructions[Int(opcode)] {
            return ins
        }
        return Instruction.NOP
    }

    func execute(_ inst: Instruction) -> UInt {
        let (operand, pc) = fetchOperand(addressingMode: inst.addressing)

        registers.PC += pc
        switch inst.exec(operand) {
        case .jump(let addr):
            registers.PC = addr
        case .branch(let offset):
            registers.PC &+= offset
            return inst.cycle + 1
        case .next:
            break // NOP
        }

        return inst.cycle
    }
}