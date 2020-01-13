import Logging

struct CPU {
    /// Accumulator
    var A: UInt8 = 0x00 {
        didSet {
            P.setZN(A)
        }
    }
    /// Index register
    var X: UInt8 = 0x00 {
        didSet {
            P.setZN(X)
        }
    }
    /// Index register
    var Y: UInt8 = 0x00 {
        didSet {
            P.setZN(Y)
        }
    }
    /// Stack pointer
    var S: UInt8 = 0xFF
    /// Status register
    var P: Status = []
    /// Program Counter
    var PC: UInt16 = 0x00

    private(set) var cycles: UInt = 0

    @inline(__always)
    mutating func tick() {
        cycles &+= 1
    }

    @inline(__always)
    mutating func tick(count: UInt) {
        cycles &+= count
    }

    mutating func powerOn() {
        A = 0
        X = 0
        Y = 0
        S = 0xFD
#if nestest
        // https://wiki.nesdev.com/w/index.php/CPU_power_up_state#cite_ref-1
        P = Status(rawValue: 0x24)
#else
        P = Status(rawValue: 0x34)
#endif
    }
}

func step(cpu: inout CPU, memory: inout Memory, interruptLine: InterruptLine) -> UInt {
    let before = cpu.cycles

    if !interrupt(cpu: &cpu, memory: &memory, from: interruptLine) {
        let opcode = fetch(cpu: &cpu, memory: &memory)
        excuteInstruction(opcode: opcode, cpu: &cpu, memory: &memory)
    }

    if before <= cpu.cycles {
        return cpu.cycles &- before
    } else {
        return UInt.max &- before &+ cpu.cycles
    }
}

func fetch(cpu: inout CPU, memory: inout Memory) -> OpCode {
    let opcode = cpu.read(at: cpu.PC, from: &memory)
    cpu.PC &+= 1
    return opcode
}
