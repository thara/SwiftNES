typealias OpCode = UInt8

protocol CPU: class {
    var registers: Registers { get set }
    var memory: Memory { get set }
    var interruptLine: InterruptLine { get }

    func fetch() -> OpCode
    func decode(_ opcode: OpCode) -> Instruction
    func execute(_ instraction: Instruction) -> UInt

    func run() -> UInt
    func step() -> UInt
}

extension CPU {

    func run() -> UInt {
        let opcode = fetch()
        let instruction = decode(opcode)
        let cycle = execute(instruction)
        return cycle
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

private func ~= (pattern: Interrupt, line: Interrupt) -> Bool {
    return line.contains(pattern)
}
