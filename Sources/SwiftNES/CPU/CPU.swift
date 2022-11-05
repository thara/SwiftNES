import Foundation

typealias OpCode = UInt8

typealias Operand = UInt16

protocol CPUEmulator: AnyObject {
    var cpu: CPU { get set }

    /// Read a byte at the given `address` on this memory
    func cpuRead(at address: UInt16) -> UInt8
    /// Write the given `value` at the `address` into this memory
    func cpuWrite(_ value: UInt8, at address: UInt16)

    func cpuTick()
}

extension CPUEmulator {
    func cpuStep(interruptLine: InterruptLine) {
        switch interruptLine.get() {
        case .RESET:
            reset()
            interruptLine.clear(.RESET)
        case .NMI:
            handleNMI()
            interruptLine.clear(.NMI)
        case .IRQ:
            if cpu.P.contains(.I) {
                handleIRQ()
                interruptLine.clear(.IRQ)
            }
        case .BRK:
            if cpu.P.contains(.I) {
                handleBRK()
                interruptLine.clear(.BRK)
            }
        default:
            let opcode = fetchOpcode()
            let instruction = decode(opcode: opcode)
            execute(by: instruction)
        }
    }

    func tick(count: UInt = 1) {
        for _ in 0..<count {
            cpuTick()
        }
    }

    func read(at address: UInt16) -> UInt8 {
        tick()
        return cpuRead(at: address)
    }

    func write(_ value: UInt8, at address: UInt16) {
        if address == 0x4014 {  // OAMDMA
            writeOAM(value)
            return
        }
        tick()

        cpuWrite(value, at: address)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
    func writeOAM(_ value: UInt8) {
        let start = value.u16 &* 0x100
        for address in start...(start &+ 0xFF) {
            let data = cpuRead(at: address)
            cpuWrite(data, at: 0x2004)
            tick(count: 2)
        }

        // dummy cycles
        tick()
        if cpu.cycles % 2 == 1 {
            tick()
        }
    }

    func readWord(at address: UInt16) -> UInt16 {
        return read(at: address).u16 | (read(at: address + 1).u16 << 8)
    }

    @inline(__always)
    func pushStack(_ value: UInt8) {
        write(value, at: cpu.S.u16 &+ 0x100)
        cpu.S &-= 1
    }

    @inline(__always)
    func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    @inline(__always)
    func pullStack() -> UInt8 {
        cpu.S &+= 1
        return read(at: cpu.S.u16 &+ 0x100)
    }

    @inline(__always)
    func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 &<< 8 | lo.u16
    }

    func fetchOpcode() -> OpCode {
        let opcode = read(at: cpu.PC)
        cpu.PC &+= 1
        return opcode
    }

    func cpuPowerOn() {
        cpu.A = 0
        cpu.X = 0
        cpu.Y = 0
        cpu.S = 0xFD
        #if nestest
            // https://wiki.nesdev.com/w/index.php/CPU_power_up_state#cite_ref-1
            cpu.P = CPU.Status(rawValue: 0x24)
        #else
            cpu.P = CPU.Status(rawValue: 0x34)
        #endif
    }

    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8
        return low | high
    }
}

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

    var cycles: UInt = 0

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
