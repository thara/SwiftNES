import Logging

final class CPU {

    var registers: CPURegisters
    let interruptLine: InterruptLine

    // var cycles: UInt = 0

    init(interruptLine: InterruptLine) {
        self.registers = CPURegisters()
        self.interruptLine = interruptLine
    }

    func powerOn() {
        registers.powerOn()

        interruptLine.clear([.NMI, .IRQ])
        interruptLine.send(.RESET)
    }

    static func step(cpu: CPU, memory: inout Memory) -> UInt {
        let before = cpu.registers.cycles

        if !cpu.interrupt(memory: &memory) {
            let opcode = fetch(cpu: cpu, memory: &memory)
            excuteInstruction(opcode: opcode, cpu: cpu, memory: &memory)
        }

        if before <= cpu.registers.cycles {
            return cpu.registers.cycles &- before
        } else {
            return UInt.max &- before &+ cpu.registers.cycles
        }
    }

    static func fetch(cpu: CPU, memory: inout Memory) -> OpCode {
        let opcode = cpu.registers.read(at: cpu.registers.PC, from: &memory)
        cpu.registers.PC &+= 1
        return opcode
    }
}

// MARK: - Interrupt
extension CPU {

    var interrupted: Bool {
        return !interruptLine.get().isEmpty
    }

    func interrupt(memory: inout Memory) -> Bool {
        switch interruptLine.get() {
        case .RESET:
            reset(memory: &memory)
        case .NMI:
            handleNMI(memory: &memory)
        case .IRQ:
            if registers.P.contains(.I) {
                handleIRQ(memory: &memory)
            }
        case .BRK:
            if registers.P.contains(.I) {
                handleBRK(memory: &memory)
            }
        default:
            return false
        }

        return true
    }

    /// Reset registers & memory state
    func reset(memory: inout Memory) {
        registers.tick(count: 5)
#if nestest
        registers.PC = 0xC000
        interruptLine.clear(.RESET)
        registers.tick(count: 2)
#else
        registers.PC = registers.readWord(at: 0xFFFC, from: &memory)
        registers.P.formUnion(.I)
        registers.S -= 3

        interruptLine.clear(.RESET)
#endif
    }

    func handleNMI(memory: inout Memory) {
        registers.tick(count: 2)

        pushStack(word: registers.PC, registers: &registers, memory: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue, registers: &registers, memory: &memory)
        registers.P.formUnion(.I)
        registers.PC = registers.readWord(at: 0xFFFA, from: &memory)

        interruptLine.clear(.NMI)
    }

    func handleIRQ(memory: inout Memory) {
        registers.tick(count: 2)

        pushStack(word: registers.PC, registers: &registers, memory: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue, registers: &registers, memory: &memory)
        registers.P.formUnion(.I)
        registers.PC = registers.readWord(at: 0xFFFE, from: &memory)

        interruptLine.clear(.IRQ)
    }

    func handleBRK(memory: inout Memory) {
        registers.tick(count: 2)

        registers.PC &+= 1
        pushStack(word: registers.PC, registers: &registers, memory: &memory)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue, registers: &registers, memory: &memory)
        registers.P.formUnion(.I)
        registers.PC = registers.readWord(at: 0xFFFE, from: &memory)

        interruptLine.clear(.BRK)
    }
}
