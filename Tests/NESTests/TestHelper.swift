@testable import NES

struct CPUStub: CPU {
    var cpu = NES.CPU()
    var cpuCycles: UInt = 0

    var wram: [UInt8] = [UInt8](repeating: 0x00, count: 65536)

    var interrupt: Interrupt = []
}

extension CPUStub: CPURegisters {
    var A: UInt8 {
        get { cpu.A }
        set { cpu.A = newValue }
    }
    var X: UInt8 {
        get { cpu.X }
        set { cpu.X = newValue }
    }
    var Y: UInt8 {
        get { cpu.Y }
        set { cpu.Y = newValue }
    }
    var S: UInt8 {
        get { cpu.S }
        set { cpu.S = newValue }
    }
    var P: CPUStatus {
        get { cpu.P }
        set { cpu.P = newValue }
    }
    var PC: UInt16 {
        get { cpu.PC }
        set { cpu.PC = newValue }
    }
}

extension CPUStub: CPUCycle {
    mutating func tick() {
        cpuCycles &+= 1
    }

    mutating func tick(count: UInt) {
        cpuCycles &+= count
    }
}

extension CPUStub: CPUMemory {
    mutating func cpuRead(at address: UInt16) -> UInt8 {
        return wram.read(at: address)
    }

    mutating func cpuWrite(_ value: UInt8, at address: UInt16) {
        wram.write(value, at: address)
    }
}

extension CPUStub: InterruptLine {

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
