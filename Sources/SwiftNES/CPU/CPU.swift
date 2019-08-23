import Logging

typealias OpCode = UInt8

final class CPU {
    var registers: Registers
    var memory: Memory

    let interruptLine: InterruptLine

    private var instructions: [Instruction?]

    var nestestLog: NESTestLogEntry = NESTestLogEntry()

    // TODO Cycle-accurate
    private static var cycles: UInt = 0

    init(memory: Memory, interruptLine: InterruptLine) {
        self.registers = Registers()
        self.memory = memory
        self.interruptLine = interruptLine

        self.instructions = []  // Need all properties are initialized because 'self' is used in 'buildInstructionTable'
        self.instructions = buildInstructionTable()
    }

    func powerOn() {
        registers.powerOn()
        memory.clear()

        interruptLine.clear([.NMI, .IRQ])

        interruptLine.send(.RESET)
    }

    func step() -> UInt {
        // let before = CPU.cycles

        if let cycles = interrupt() {
            return cycles
        }

        let opcode = fetch()
        let instruction = decode(opcode)
        return execute(instruction)

        // print("\(before) \(CPU.cycles)")
        // if before <= CPU.cycles {
        //     return CPU.cycles &- before
        // } else {
        //     return UInt.max &- before &+ CPU.cycles
        // }
    }

    @inline(__always)
    static func tick(function: String = #function) {
        cycles += 1
    }

    @inline(__always)
    static func tick(count: UInt) {
        cycles += count
    }
}

// MARK: - CPU.run implementation
extension CPU {

    func fetch() -> OpCode {
        nestestLog.pc = registers.PC

        let opcode = memory.read(at: registers.PC)
        registers.PC &+= 1
        return opcode
    }

    func decode(_ opcode: OpCode) -> Instruction {
        return instructions[Int(opcode)]!
    }

    func execute(_ instruction: Instruction) -> UInt {
        let operand = instruction.addressingMode()
#if nestest
        logNestest(operand, instruction)
#endif
        let result = instruction.exec(operand)

        switch result {
        case .jump(let addr):
            registers.PC = addr
        case .branch(let offset):
            registers.PC = UInt16(Int(registers.PC) &+ Int(offset))
            return instruction.cycle &+ 1
        case .next:
            break // NOP
        }

        return instruction.cycle
    }
}

// MARK: - Stack
extension CPU {
    func pushStack(_ value: UInt8) {
        memory.write(value, at: registers.S.u16 &+ 0x100)
        registers.S &-= 1
    }

    func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    func pullStack() -> UInt8 {
        registers.S &+= 1
        return memory.read(at: registers.S.u16 &+ 0x100)
    }

    func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 &<< 8 | lo.u16
    }
}

// Test subset of interrupt for switch-case
private func ~= (pattern: Interrupt, line: Interrupt) -> Bool {
    return line.contains(pattern)
}
