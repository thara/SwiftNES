enum OpCode {
    case byte(data: UInt8)
    case word(data: UInt16)
}

protocol CPU {
    func fetch() -> OpCode
    func decode(_ opcode: OpCode) -> Instruction
    func execute(_ instraction: Instruction)

    /// Reset registers & memory state
    func reset()
}

extension CPU {
    func run() {
        let opcode = fetch()
        let instruction = decode(opcode)
        execute(instruction)
    }
}

class CPUEmulator : CPU {

    var registers: Registers
    var memory: AddressSpace

    init() {
        registers = Registers(
            A: 0x00,
            X: 0x00,
            Y: 0x00,
            S: 0x00,
            P: [Status.R, Status.B, Status.I],
            PC: 0x00
        )
        memory = AddressSpace()
    }

    func fetch() -> OpCode {
        //FIXME Not implemented
        return .byte(data: 0x0000)
    }

    func decode(_ opcode: OpCode) -> Instruction {
        //FIXME Not implemented
        return Instruction(operation: .LDA, addressingMode: .immediate)
    }

    func execute(_ instraction: Instruction) {
        //FIXME Not implemented
    }

    func reset() {
        registers.A = 0x00
        registers.X = 0x00
        registers.Y = 0x00
        registers.S = 0xff
        registers.PC = memory.readWord(addr: 0xFFFC)
    }
}
