struct Interrupt: OptionSet {
    let rawValue: UInt8

    static let RESET = Interrupt(rawValue: 1 << 3)
    static let NMI = Interrupt(rawValue: 1 << 2)
    static let IRQ = Interrupt(rawValue: 1 << 1)
    static let BRK = Interrupt(rawValue: 1 << 0)
}

protocol InterruptLine {
    mutating func sendInterrupt(_: Interrupt)
    func receiveInterrupt() -> Interrupt
    mutating func clearInterrupt(_: Interrupt)
    var interrupted: Bool { get }
}
