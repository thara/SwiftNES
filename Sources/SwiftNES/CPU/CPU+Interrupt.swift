protocol CPUInterrupt: CPUStack {
    static func reset(on: Self)
    static func handleNMI(on: Self)
    static func handleIRQ(on: Self)
    static func handleBRK(on: Self)
}

extension NES: CPUInterrupt {
    /// Reset registers & memory state
    static func reset(on nes: NES) {
        nes.cpu.tick(count: 5)
    #if nestest
        nes.cpu.PC = 0xC000
        nes.cpu.tick(count: 2)
    #else
        nes.cpu.PC = readWord(at: 0xFFFC, from: nes)
        nes.cpu.P.formUnion(.I)
        nes.cpu.S -= 3
    #endif
    }

    static func handleNMI(on nes: NES) {
        nes.cpu.tick(count: 2)

        pushStack(word: nes.cpu.PC, to: nes)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPU.Status.interruptedB.rawValue, to: nes)
        nes.cpu.P.formUnion(.I)
        nes.cpu.PC = readWord(at: 0xFFFA, from: nes)
    }

    static func handleIRQ(on nes: NES) {
        nes.cpu.tick(count: 2)

        pushStack(word: nes.cpu.PC, to: nes)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPU.Status.interruptedB.rawValue, to: nes)
        nes.cpu.P.formUnion(.I)
        nes.cpu.PC = readWord(at: 0xFFFE, from: nes)
    }

    static func handleBRK(on nes: NES) {
        nes.cpu.tick(count: 2)

        nes.cpu.PC &+= 1
        pushStack(word: nes.cpu.PC, to: nes)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(nes.cpu.P.rawValue | CPU.Status.interruptedB.rawValue, to: nes)
        nes.cpu.P.formUnion(.I)
        nes.cpu.PC = readWord(at: 0xFFFE, from: nes)
    }
}
