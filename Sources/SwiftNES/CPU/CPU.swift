import Logging

final class CPU {

    var registers: CPURegisters

    init() {
        self.registers = CPURegisters()
    }

    func powerOn() {
        registers.powerOn()
    }

}

func step(cpu: CPU, memory: inout Memory, interruptLine: InterruptLine) -> UInt {
    let before = cpu.registers.cycles

    if !interrupt(registers: &cpu.registers, memory: &memory, from: interruptLine) {
        let opcode = fetch(cpu: cpu, memory: &memory)
        excuteInstruction(opcode: opcode, cpu: cpu, memory: &memory)
    }

    if before <= cpu.registers.cycles {
        return cpu.registers.cycles &- before
    } else {
        return UInt.max &- before &+ cpu.registers.cycles
    }
}

func fetch(cpu: CPU, memory: inout Memory) -> OpCode {
    let opcode = cpu.registers.read(at: cpu.registers.PC, from: &memory)
    cpu.registers.PC &+= 1
    return opcode
}
