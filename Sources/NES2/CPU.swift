struct CPURegister {
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
}

protocol CPU {
    typealias OpCode = UInt8
    typealias Operand = UInt16
    typealias Register = CPURegister
    typealias Status = CPURegister.Status

    associatedtype Bus: NES2.CPUBus

    mutating func cpuStep(register: inout Register, with bus: inout Bus)

    mutating func fetchOpcode(register: inout Register, from bus: inout Bus) -> CPU.OpCode
    mutating func executeInstruction(opcode: OpCode, register: inout Register, with: inout Bus)

    @discardableResult
    mutating func cpuTick() -> UInt

    @discardableResult
    mutating func cpuTick(count: UInt) -> UInt
}

extension CPU {
    mutating func cpuStep(register: inout Register, with bus: inout Bus) {
        let opcode = fetchOpcode(register: &register, from: &bus)
        executeInstruction(opcode: opcode, register: &register, with: &bus)
    }

    mutating func reset(register: inout Register, bus: inout Bus) {
        register.PC = cpuReadWord(at: 0xFFFC, from: &bus)
        register.P.formUnion(.I)
        register.S -= 3
    }
}

extension CPU {
    mutating func fetchOpcode(register: inout Register, from bus: inout Bus) -> CPU.OpCode {
        let opcode = cpuRead(at: register.PC, from: &bus)
        register.PC &+= 1
        return opcode
    }
}

protocol CPUBus {
    func read(at address: UInt16) -> UInt8
    mutating func write(_: UInt8, at address: UInt16)
}

// Memory Access
extension CPU {
    mutating func cpuRead(at addr: UInt16, from bus: inout Bus) -> UInt8 {
        cpuTick()
        return bus.read(at: addr)
    }

    mutating func cpuReadWord(at addr: UInt16, from bus: inout Bus) -> UInt16 {
        return cpuRead(at: addr, from: &bus).u16 | (cpuRead(at: addr + 1, from: &bus).u16 << 8)
    }

    mutating func cpuWrite(_ val: UInt8, at addr: UInt16, to bus: inout Bus) {
        if addr == 0x4014 {  // OAMDMA
            // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
            let start = val.u16 &* 0x100
            for address in start...(start &+ 0xFF) {
                let data = bus.read(at: address)
                bus.write(data, at: 0x2004)
                cpuTick(count: 2)
            }

            // dummy cycles
            let cpuCycles = cpuTick()
            if cpuCycles % 2 == 1 {
                cpuTick()
            }
        } else {
            cpuTick()
            bus.write(val, at: addr)
        }
    }
}

extension CPURegister.Status {
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
