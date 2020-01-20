func step(cpu: inout CPU, interruptLine: InterruptLine) -> UInt {
    let before = cpu.cycles

    switch interruptLine.get() {
    case .RESET:
        cpu.reset()
        interruptLine.clear(.RESET)
    case .NMI:
        cpu.handleNMI()
        interruptLine.clear(.NMI)
    case .IRQ:
        if cpu.P.contains(.I) {
            cpu.handleIRQ()
            interruptLine.clear(.IRQ)
        }
    case .BRK:
        if cpu.P.contains(.I) {
            cpu.handleBRK()
            interruptLine.clear(.BRK)
        }
    default:
        let opcode = cpu.fetchOperand()
        cpu.excuteInstruction(opcode: opcode)
    }

    if before <= cpu.cycles {
        return cpu.cycles &- before
    } else {
        return UInt.max &- before &+ cpu.cycles
    }
}
