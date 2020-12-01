extension Emulator {

    mutating func sendInterrupt(_ interrupt: Interrupt) {
        nes.interrupt.formUnion(interrupt)
    }

    func receiveInterrupt() -> Interrupt {
        return nes.interrupt
    }

    mutating func clearInterrupt(_ interrupt: Interrupt) {
        nes.interrupt.remove(interrupt)
    }

    var interrupted: Bool {
        return !nes.interrupt.isEmpty
    }
}
