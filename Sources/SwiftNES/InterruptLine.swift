struct Interrupt: OptionSet, CustomDebugStringConvertible {

    let rawValue: UInt8

    static let RESET = Interrupt(rawValue: 1 << 3)
    static let NMI = Interrupt(rawValue: 1 << 2)
    static let IRQ = Interrupt(rawValue: 1 << 1)
    static let BRK = Interrupt(rawValue: 1 << 0)

    var debugDescription: String {
        var s: [String] = []
        if contains(.RESET) {
            s.append("RESET")
        }
        if contains(.NMI) {
            s.append("NMI")
        }
        if contains(.IRQ) {
            s.append("IRQ")
        }
        if contains(.BRK) {
            s.append("BRK")
        }
        return s.joined(separator: ",")
    }
}

final class InterruptLine {
    private var current: Interrupt = []

    func send(_ interrupt: Interrupt) {
        current.formUnion(interrupt)
    }

    func get() -> Interrupt {
        return current
    }

    func clear(_ interrupt: Interrupt) {
        current.remove(interrupt)
    }

    var interrupted: Bool {
        return !current.isEmpty
    }
}
