import Logging

typealias OpCode = UInt8

final class CPU {

    struct Step {
        var pc: UInt16?
        var addressingMode: AddressingMode?
    }

    var registers: Registers
    var memory: Memory

    let interruptLine: InterruptLine

    private var instructions: [Instruction?]

    var currentStep: Step = Step()

    // TODO Cycle-accurate
    private var cycles: UInt = 0

    init(memory: Memory, interruptLine: InterruptLine) {
        self.registers = Registers()
        self.memory = memory
        self.interruptLine = interruptLine

        self.instructions = []  // Need all properties are initialized because 'self' is used in 'buildInstructionTable'
        self.instructions = buildInstructionTable()
    }

    func powerOn() {
        registers.powerOn()
        clear()

        interruptLine.clear([.NMI, .IRQ])
        interruptLine.send(.RESET)
    }

    func step() -> UInt {
        let before = cycles

        if let cycles = interrupt() {
            return cycles
        }

        let opcode = fetch()
        let instruction = decode(opcode)
        execute(instruction)

        if before <= cycles {
            return cycles &- before
        } else {
            return UInt.max &- before &+ cycles
        }
    }

    @inline(__always)
    func tick() {
        cycles &+= 1
    }

    @inline(__always)
    func tick(count: UInt) {
        cycles &+= count
    }
}

// MARK: - CPU.run implementation
extension CPU {

    func fetch() -> OpCode {
        currentStep.pc = registers.PC

        let opcode = read(at: registers.PC)
        registers.PC &+= 1
        return opcode
    }

    func decode(_ opcode: OpCode) -> Instruction {
        return instructions[Int(opcode)]!
    }

    func execute(_ instruction: Instruction) {
        let operand = instruction.addressingMode()
#if nestest
        logNestest(operand, instruction)
#endif
        registers.PC = instruction.exec(operand)
    }
}

// MARK: - Memory
extension CPU: Memory {

    @inline(__always)
    func read(at address: UInt16) -> UInt8 {
        tick()
        return memory.read(at: address)
    }

    @inline(__always)
    func write(_ value: UInt8, at address: UInt16) {
        tick()
        memory.write(value, at: address)
    }

    @inline(__always)
    func clear() {
        memory.clear()
    }
}

// MARK: - Stack
extension CPU {
    func pushStack(_ value: UInt8) {
        write(value, at: registers.S.u16 &+ 0x100)
        registers.S &-= 1
    }

    func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    func pullStack() -> UInt8 {
        registers.S &+= 1
        return read(at: registers.S.u16 &+ 0x100)
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
