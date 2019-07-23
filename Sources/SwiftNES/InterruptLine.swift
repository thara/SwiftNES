struct Interrupt: OptionSet {

    let rawValue: UInt8

    static let RESET = Interrupt(rawValue: 1 << 3)
    static let NMI = Interrupt(rawValue: 1 << 2)
    static let IRQ = Interrupt(rawValue: 1 << 1)
    static let BRK = Interrupt(rawValue: 1 << 0)
}

class InterruptLine {
    var current: Interrupt = []

    func send(_ interrupt: Interrupt) {
        interruptLogger.debug("Send \(interrupt)")

        current.formUnion(interrupt)
    }

    func get() -> Interrupt {
        return current
    }

    func clear(_ interrupt: Interrupt) {
        interruptLogger.debug("Clear \(interrupt)")

        current.remove(interrupt)
    }
}
