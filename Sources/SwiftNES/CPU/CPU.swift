typealias OpCode = UInt8

protocol CPU: class {
    var registers: Registers { get set }
    var memory: AddressSpace { get }

    func fetch() -> OpCode
    func decode(_ opcode: OpCode) -> Instruction
    func execute(_ instraction: Instruction) -> UInt

    /// Reset registers & memory state
    func reset()

    func pushStack(data: UInt8)
    func pushStack(word: UInt16)
    func pullStack() -> UInt8
    func pullStack() -> UInt16
}

extension CPU {
    func run() -> UInt {
        let opcode = fetch()
        let instruction = decode(opcode)
        let cycle = execute(instruction)
        return cycle
    }

    func pushStack(data: UInt8) {
        memory.write(addr: UInt16(registers.S) + 0x100, data: data)
        registers.S -= 1
    }

    func pushStack(word: UInt16) {
        pushStack(data: UInt8(word >> 8))
        pushStack(data: UInt8(word & 0xFF))
    }

    func pullStack() -> UInt8 {
        registers.S += 1
        return memory.read(addr: UInt16(registers.S) + 0x100)
    }

    func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return UInt16(ho) << 8 & UInt16(lo)
    }
}

class CPUEmulator: CPU {

    var registers: Registers
    var memory: AddressSpace

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
        memory = AddressSpace()
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
        let operand = fetchOperand(addressingMode: inst.addressing)
        registers.PC = inst.exec?(operand) ?? registers.PC + 1
        return inst.cycle
    }

    func reset() {
        registers.A = 0x00
        registers.X = 0x00
        registers.Y = 0x00
        registers.S = 0xff
        registers.PC = memory.readWord(addr: 0xFFFC)
    }
}
