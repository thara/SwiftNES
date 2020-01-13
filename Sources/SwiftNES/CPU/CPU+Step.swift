extension CPU {
    mutating func step(interruptLine: InterruptLine) -> UInt {
        let before = cycles

        switch interruptLine.get() {
        case .RESET:
            reset()
            interruptLine.clear(.RESET)
        case .NMI:
            handleNMI()
            interruptLine.clear(.NMI)
        case .IRQ:
            if P.contains(.I) {
                handleIRQ()
                interruptLine.clear(.IRQ)
            }
        case .BRK:
            if P.contains(.I) {
                handleBRK()
                interruptLine.clear(.BRK)
            }
        default:
            let opcode = fetchOperand()
            excuteInstruction(opcode: opcode)
        }

        if before <= cycles {
            return cycles &- before
        } else {
            return UInt.max &- before &+ cycles
        }
    }
}
