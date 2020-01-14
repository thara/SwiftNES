import Logging

func step(cpu: inout CPU, memory: inout Memory, interruptLine: InterruptLine) -> UInt {
    let before = cpu.cycles

    if !interrupt(cpu: &cpu, memory: &memory, from: interruptLine) {
        let opcode = cpu.fetchOpCode(from: &memory)
        cpu.excuteInstruction(opcode: opcode, memory: &memory)
    }

    if before <= cpu.cycles {
        return cpu.cycles &- before
    } else {
        return UInt.max &- before &+ cpu.cycles
    }
}

func interrupt(cpu: inout CPU, memory: inout Memory, from interruptLine: InterruptLine) -> Bool {
    switch interruptLine.get() {
    case .RESET:
        cpu.reset(memory: &memory)
        interruptLine.clear(.RESET)
    case .NMI:
        cpu.handleNMI(memory: &memory)
        interruptLine.clear(.NMI)
    case .IRQ:
        if cpu.P.contains(.I) {
            cpu.handleIRQ(memory: &memory)
            interruptLine.clear(.IRQ)
        }
    case .BRK:
        if cpu.P.contains(.I) {
            cpu.handleBRK(memory: &memory)
            interruptLine.clear(.BRK)
        }
    default:
        return false
    }

    return true
}
