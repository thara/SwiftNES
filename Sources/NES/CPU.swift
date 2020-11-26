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

    @inline(__always)
    mutating func step<M: Memory>(with mem: M) {
        let opcode = fetchOperand(from: mem)
        excuteInstruction(opcode: opcode, with: mem)
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

// MARK: Memory access
extension CPU {

    mutating func read<M: Memory>(at address: UInt16, with mem: M) -> UInt8 {
        tick()
        return mem.readCPU(at: address)
    }

    mutating func readWord<M: Memory>(at address: UInt16, with mem: M) -> UInt16 {
        return read(at: address, with: mem).u16 | (read(at: address + 1, with: mem).u16 << 8)
    }

    mutating func write<M: Memory>(_ value: UInt8, at address: UInt16, with mem: M) {
        if address == 0x4014 {  // OAMDMA
            writeOAM(value, with: mem)
            return
        }
        tick()

        mem.writeCPU(value, at: address)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
    mutating func writeOAM<M: Memory>(_ value: UInt8, with mem: M) {
        let start = value.u16 &* 0x100
        for address in start...(start &+ 0xFF) {
            let data = mem.readCPU(at: address)
            mem.writeCPU(data, at: 0x2004)
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
    mutating func pushStack<M: Memory>(_ value: UInt8, with mem: M) {
        write(value, at: S.u16 &+ 0x100, with: mem)
        S &-= 1
    }

    @inline(__always)
    mutating func pushStack<M: Memory>(word: UInt16, with mem: M) {
        pushStack(UInt8(word >> 8), with: mem)
        pushStack(UInt8(word & 0xFF), with: mem)
    }

    @inline(__always)
    mutating func pullStack<M: Memory>(with mem: M) -> UInt8 {
        S &+= 1
        return read(at: S.u16 &+ 0x100, with: mem)
    }

    @inline(__always)
    mutating func pullStack<M: Memory>(with mem: M) -> UInt16 {
        let lo: UInt8 = pullStack(with: mem)
        let ho: UInt8 = pullStack(with: mem)
        return ho.u16 &<< 8 | lo.u16
    }
}
