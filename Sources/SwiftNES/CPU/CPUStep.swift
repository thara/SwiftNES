func cpuStep(nes: inout NES) -> UInt {
    let before = nes.cpu.cycles

    if !interrupt(on: &nes) {
        let opcode = fetchOpCode(from: &nes)
        excuteInstruction(opcode: opcode, on: &nes)
    }

    if before <= nes.cpu.cycles {
        return nes.cpu.cycles &- before
    } else {
        return UInt.max &- before &+ nes.cpu.cycles
    }
}

func interrupt(on nes: inout NES) -> Bool {
    switch nes.interruptLine.get() {
    case .RESET:
        reset(on: &nes)
        nes.interruptLine.clear(.RESET)
    case .NMI:
        handleNMI(on: &nes)
        nes.interruptLine.clear(.NMI)
    case .IRQ:
        if nes.cpu.P.contains(.I) {
            handleIRQ(on: &nes)
            nes.interruptLine.clear(.IRQ)
        }
    case .BRK:
        if nes.cpu.P.contains(.I) {
            handleBRK(on: &nes)
            nes.interruptLine.clear(.BRK)
        }
    default:
        return false
    }

    return true
}
