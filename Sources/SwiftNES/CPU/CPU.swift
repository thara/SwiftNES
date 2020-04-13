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

    var memory: Memory

    private(set) var cycles: UInt = 0

    @inline(__always)
    mutating func tick(count: UInt = 1) {
        cycles &+= count
    }

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

// MARK: - Memory
extension CPU {
    mutating func read(at address: UInt16) -> UInt8 {
        tick()
        return memory.read(at: address)
    }

    mutating func write(_ value: UInt8, at address: UInt16) {
        if address == 0x4014 {  // OAMDMA
            writeOAM(value)
            return
        }
        tick()

        memory.write(value, at: address)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
    mutating func writeOAM(_ value: UInt8) {
        let start = value.u16 &* 0x100
        for address in start...(start &+ 0xFF) {
            let data = memory.read(at: address)
            memory.write(data, at: 0x2004)
            tick(count: 2)
        }

        // dummy cycles
        tick()
        if cycles % 2 == 1 {
            tick()
        }
    }
}

extension CPU.Status {
    mutating func setZN(_ value: UInt8) {
        if value == 0 {
            formUnion(.Z)
        } else {
            remove(.Z)
        }
        if value[7] == 1 {
            formUnion(.N)
        } else {
            remove(.N)
        }
    }

    mutating func setZN(_ value: Int16) {
        if value == 0 {
            formUnion(.Z)
        } else {
            remove(.Z)
        }
        if value[7] == 1 {
            formUnion(.N)
        } else {
            remove(.N)
        }
    }
}
