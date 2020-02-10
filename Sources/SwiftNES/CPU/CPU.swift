typealias CPUMemory = ReadWrite

struct CPU {
    /// Accumulator
    var A: UInt8 = 0x00 { didSet { P.setZN(A) } }
    /// Index register
    var X: UInt8 = 0x00 { didSet { P.setZN(X) } }
    /// Index register
    var Y: UInt8 = 0x00 { didSet { P.setZN(Y) } }
    /// Stack pointer
    var S: UInt8 = 0xFF
    /// Status register
    struct Status: OptionSet {
        let rawValue: UInt8
        /// Negative
        static let N = Status(rawValue: 1 << 7)
        /// Overflow
        static let V = Status(rawValue: 1 << 6)
        static let R = Status(rawValue: 1 << 5)
        static let B = Status(rawValue: 1 << 4)
        /// Decimal mode
        static let D = Status(rawValue: 1 << 3)
        /// IRQ prevention
        static let I = Status(rawValue: 1 << 2)
        /// Zero
        static let Z = Status(rawValue: 1 << 1)
        /// Carry
        static let C = Status(rawValue: 1 << 0)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        static let operatedB = Status(rawValue: 0b110000)
        static let interruptedB = Status(rawValue: 0b100000)
    }
    var P: Status = []
    /// Program Counter
    var PC: UInt16 = 0x00

    private(set) var cycles: UInt = 0

    @inline(__always)
    mutating func tick(count: UInt = 1) {
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

protocol CPUStep: CPUInstructions, CPUInterrupt {
    static func cpuStep(interruptLine: InterruptLine, on: Self) -> UInt
}

extension NES: CPUStep {

    static func cpuStep(interruptLine: InterruptLine, on nes: NES) -> UInt {
        let before = nes.cpu.cycles

        switch interruptLine.get() {
        case .RESET:
            reset(on: nes)
            interruptLine.clear(.RESET)
        case .NMI:
            handleNMI(on: nes)
            interruptLine.clear(.NMI)
        case .IRQ:
            if nes.cpu.P.contains(.I) {
                handleIRQ(on: nes)
                interruptLine.clear(.IRQ)
            }
        case .BRK:
            if nes.cpu.P.contains(.I) {
                handleBRK(on: nes)
                interruptLine.clear(.BRK)
            }
        default:
            let opcode = fetchOperand(from: nes)
            let (operation, fetchOperand) = decode(opcode)
            let operand = fetchOperand(nes)
            operation(operand, nes)
        }

        if before <= nes.cpu.cycles {
            return nes.cpu.cycles &- before
        } else {
            return UInt.max &- before &+ nes.cpu.cycles
        }
    }
}


extension CPU.Status {
    mutating func setZN(_ value: UInt8) {
        if value == 0 { formUnion(.Z) } else { remove(.Z) }
        if value[7] == 1 { formUnion(.N) } else { remove(.N) }
    }

    mutating func setZN(_ value: Int16) {
        if value == 0 { formUnion(.Z) } else { remove(.Z) }
        if value[7] == 1 { formUnion(.N) } else { remove(.N) }
    }
}
