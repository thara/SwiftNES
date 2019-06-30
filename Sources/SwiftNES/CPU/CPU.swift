typealias OpCode = UInt8

protocol CPU: class {
    var registers: Registers { get set }
    var memory: AddressSpace { get }

    func fetch() -> OpCode
    func decode(_ opcode: OpCode) -> Instruction
    func execute(_ instraction: Instruction) -> UInt
    func step() -> UInt

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
        memory.write(addr: registers.S.u16 + 0x100, data: data)
        registers.S -= 1
    }

    func pushStack(word: UInt16) {
        pushStack(data: UInt8(word >> 8))
        pushStack(data: UInt8(word & 0xFF))
    }

    func pullStack() -> UInt8 {
        registers.S += 1
        return memory.read(addr: registers.S.u16 + 0x100)
    }

    func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 << 8 | lo.u16
    }
}

class CPUEmulator: CPU {

    var registers: Registers
    var memory: AddressSpace
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

    func step() -> UInt {
        switch interrupt {
        case .RESET?:
            return reset()
        case .NMI?:
            return handleNMI()
        case .IRQ?:
            return handleIMQ() ?? run()
        case .BRK?:
            return handleBRQ() ?? run()
        default:
            return run()
        }
    }
}
