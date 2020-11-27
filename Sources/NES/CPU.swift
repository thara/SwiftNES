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
    var P: CPUStatus = []
    /// Program Counter
    var PC: UInt16 = 0x00

    var readCPU: (UInt16) -> UInt8 = { _ in return 0x00 }
    var writeCPU: (UInt8, UInt16) -> () = { _, _ in }

    var interruptLine: InterruptLine

    private(set) var cycles: UInt = 0
}

extension CPU {
    @inline(__always)
    mutating func tick(count: UInt = 1) {
        cycles &+= count
    }

    mutating func step() -> UInt {
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

        let after = cycles
        if before <= after {
            return after &- before
        } else {
            return UInt.max &- before &+ after
        }
    }

    /// Reset registers & memory state
    mutating func reset() {
        tick(count: 5)
        PC = readWord(at: 0xFFFC)
        P.formUnion(.I)
        S -= 3
    }

    mutating func handleNMI() {
        tick(count: 2)

        pushStack(word: PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | CPUStatus.interruptedB.rawValue)
        P.formUnion(.I)
        PC = readWord(at: 0xFFFA)
    }

    mutating func handleIRQ() {
        tick(count: 2)

        pushStack(word: PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | CPUStatus.interruptedB.rawValue)
        P.formUnion(.I)
        PC = readWord(at: 0xFFFE)
    }

    mutating func handleBRK() {
        tick(count: 2)

        PC &+= 1
        pushStack(word: PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(P.rawValue | CPUStatus.interruptedB.rawValue)
        P.formUnion(.I)
        PC = readWord(at: 0xFFFE)
    }
}

struct CPUStatus: OptionSet {
    let rawValue: UInt8
    /// Negative
    static let N = CPUStatus(rawValue: 1 << 7)
    /// Overflow
    static let V = CPUStatus(rawValue: 1 << 6)
    static let R = CPUStatus(rawValue: 1 << 5)
    static let B = CPUStatus(rawValue: 1 << 4)
    /// Decimal mode
    static let D = CPUStatus(rawValue: 1 << 3)
    /// IRQ prevention
    static let I = CPUStatus(rawValue: 1 << 2)
    /// Zero
    static let Z = CPUStatus(rawValue: 1 << 1)
    /// Carry
    static let C = CPUStatus(rawValue: 1 << 0)
    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    static let operatedB = CPUStatus(rawValue: 0b110000)
    static let interruptedB = CPUStatus(rawValue: 0b100000)

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

// MARK: Memory access
extension CPU {

    mutating func read(at address: UInt16) -> UInt8 {
        tick()
        return readCPU(address)
    }

    mutating func readWord(at address: UInt16) -> UInt16 {
        return read(at: address).u16 | (read(at: address + 1).u16 << 8)
    }

    mutating func write(_ value: UInt8, at address: UInt16) {
        if address == 0x4014 {  // OAMDMA
            writeOAM(value)
            return
        }
        tick()

        writeCPU(value, address)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
    mutating func writeOAM(_ value: UInt8) {
        let start = value.u16 &* 0x100
        for address in start...(start &+ 0xFF) {
            let data = readCPU(address)
            writeCPU(data, 0x2004)
            tick(count: 2)
        }

        // dummy cycles
        tick()
        if cycles % 2 == 1 {
            tick()
        }
    }
}

// MARK: - Stack
extension CPU {
    @inline(__always)
    mutating func pushStack(_ value: UInt8) {
        write(value, at: S.u16 &+ 0x100)
        S &-= 1
    }

    @inline(__always)
    mutating func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    @inline(__always)
    mutating func pullStack() -> UInt8 {
        S &+= 1
        return read(at: S.u16 &+ 0x100)
    }

    @inline(__always)
    mutating func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 &<< 8 | lo.u16
    }
}
