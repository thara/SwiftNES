protocol CPUInterrupt: CPUStack {
    static func reset(on cpu: inout CPU, with: inout Self)
    static func handleNMI(on cpu: inout CPU, with: inout Self)
    static func handleIRQ(on cpu: inout CPU, with: inout Self)
    static func handleBRK(on cpu: inout CPU, with: inout Self)
}

extension CPUInterrupt {
    /// Reset registers & memory state
    static func reset(on cpu: inout CPU, with memory: inout Self) {
        cpu.tick(count: 5)
    #if nestest
        cpu.PC = 0xC000
        cpu.tick(count: 2)
    #else
        cpu.PC = Self.readWord(at: 0xFFFC, from: &memory)
        cpu.P.formUnion(.I)
        cpu.S -= 3
    #endif
    }

    static func handleNMI(on cpu: inout CPU, with memory: inout Self) {
        cpu.tick(count: 2)

        pushStack(word: cpu.PC, to: &memory, on: &cpu)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue, to: &memory, on: &cpu)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFA, from: &memory)
    }

    static func handleIRQ(on cpu: inout CPU, with memory: inout Self) {
        cpu.tick(count: 2)

        pushStack(word: cpu.PC, to: &memory, on: &cpu)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue, to: &memory, on: &cpu)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFE, from: &memory)
    }

    static func handleBRK(on cpu: inout CPU, with memory: inout Self) {
        cpu.tick(count: 2)

        cpu.PC &+= 1
        pushStack(word: cpu.PC, to: &memory, on: &cpu)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue, to: &memory, on: &cpu)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFE, from: &memory)
    }
}
