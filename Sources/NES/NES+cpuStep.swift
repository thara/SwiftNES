extension NES {

    mutating func cpuStep<M: Memory>(with mem: M) -> UInt {
        let before = cpu.cycles

        switch interruptLine.get() {
        case .RESET:
            cpuReset(with: mem)
            interruptLine.clear(.RESET)
        case .NMI:
            handleNMI(with: mem)
            interruptLine.clear(.NMI)
        case .IRQ:
            if cpu.P.contains(.I) {
                handleIRQ(with: mem)
                interruptLine.clear(.IRQ)
            }
        case .BRK:
            if cpu.P.contains(.I) {
                handleBRK(with: mem)
                interruptLine.clear(.BRK)
            }
        default:
            cpu.step(with: mem)
        }

        let after = cpu.cycles
        if before <= after {
            return after &- before
        } else {
            return UInt.max &- before &+ after
        }
    }

    /// Reset registers & memory state
    mutating func cpuReset<M: Memory>(with mem: M) {
        cpu.tick(count: 5)
        cpu.PC = cpu.readWord(at: 0xFFFC, with: mem)
        cpu.P.formUnion(.I)
        cpu.S -= 3
    }

    mutating func handleNMI<M: Memory>(with mem: M) {
        cpu.tick(count: 2)

        cpu.pushStack(word: cpu.PC, with: mem)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue, with: mem)
        cpu.P.formUnion(.I)
        cpu.PC = cpu.readWord(at: 0xFFFA, with: mem)
    }

    mutating func handleIRQ<M: Memory>(with mem: M) {
        cpu.tick(count: 2)

        cpu.pushStack(word: cpu.PC, with: mem)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue, with: mem)
        cpu.P.formUnion(.I)
        cpu.PC = cpu.readWord(at: 0xFFFE, with: mem)
    }

    mutating func handleBRK<M: Memory>(with mem: M) {
        cpu.tick(count: 2)

        cpu.PC &+= 1
        cpu.pushStack(word: cpu.PC, with: mem)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        cpu.pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue, with: mem)
        cpu.P.formUnion(.I)
        cpu.PC = cpu.readWord(at: 0xFFFE, with: mem)
    }
}

