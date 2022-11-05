extension CPUEmulator {
    func reset() {
        tick(count: 5)
        #if nestest
            cpu.PC = 0xC000
            tick(count: 2)
        #else
            cpu.PC = readWord(at: 0xFFFC)
            cpu.P.formUnion(.I)
            cpu.S -= 3
        #endif
    }

    func handleNMI() {
        tick(count: 2)

        pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFA)
    }

    func handleIRQ() {
        tick(count: 2)

        pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFE)
    }

    func handleBRK() {
        tick(count: 2)

        cpu.PC &+= 1
        pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFE)
    }
}
