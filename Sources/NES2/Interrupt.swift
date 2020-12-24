struct Interrupt: OptionSet {
    let rawValue: UInt8

    static let RESET = Interrupt(rawValue: 1 << 3)
    static let NMI = Interrupt(rawValue: 1 << 2)
    static let IRQ = Interrupt(rawValue: 1 << 1)
    static let BRK = Interrupt(rawValue: 1 << 0)
}

extension NES {

    mutating func sendInterrupt(_ interrupt: Interrupt) {
        self.interrupt.formUnion(interrupt)
    }

    func receiveInterrupt() -> Interrupt {
        return self.interrupt
    }

    mutating func clearInterrupt(_ interrupt: Interrupt) {
        self.interrupt.remove(interrupt)
    }

    var interrupted: Bool {
        return !self.interrupt.isEmpty
    }
}

extension NES {

    mutating func handleNMI(register: inout CPURegister, with bus: inout Bus) {
        cpuTick(count: 2)

        pushStack(word: register.PC, register: &register, to: &bus)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(register.P.rawValue | CPU.Status.interruptedB.rawValue, register: &register, to: &bus)
        register.P.formUnion(.I)
        register.PC = cpuReadWord(at: 0xFFFA, from: &bus)
    }

    mutating func handleIRQ(register: inout CPURegister, with bus: inout Bus) {
        cpuTick(count: 2)

        pushStack(word: register.PC, register: &register, to: &bus)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(register.P.rawValue | CPU.Status.interruptedB.rawValue, register: &register, to: &bus)
        register.P.formUnion(.I)
        register.PC = cpuReadWord(at: 0xFFFE, from: &bus)
    }

    mutating func handleBRK(register: inout CPURegister, with bus: inout Bus) {
        cpuTick(count: 2)

        register.PC &+= 1
        pushStack(word: register.PC, register: &register, to: &bus)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(register.P.rawValue | CPU.Status.interruptedB.rawValue, register: &register, to: &bus)
        register.P.formUnion(.I)
        register.PC = cpuReadWord(at: 0xFFFE, from: &bus)
    }
}
