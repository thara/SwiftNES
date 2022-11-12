import Foundation

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

// MARK: - interrupt handling
extension CPUEmulator {
    func reset() {
        tick(count: 5)
        #if nestest
            cpu.PC = 0xC000
            tick(count: 2)
        #else
            cpu.PC = readWord(at: 0xFFFC)
            cpu.P.formUnion(.I)
            cpu.S -= 3
        #endif
    }

    func handleNMI() {
        tick(count: 2)

        pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFA)
    }

    func handleIRQ() {
        tick(count: 2)

        pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFE)
    }

    func handleBRK() {
        tick(count: 2)

        cpu.PC &+= 1
        pushStack(word: cpu.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(cpu.P.rawValue | CPU.Status.interruptedB.rawValue)
        cpu.P.formUnion(.I)
        cpu.PC = readWord(at: 0xFFFE)
    }
}

func pageCrossed(value: UInt16, operand: UInt8) -> Bool {
    return pageCrossed(value: value, operand: operand.u16)
}

func pageCrossed(value: UInt16, operand: UInt16) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}

func pageCrossed(value: Int, operand: Int) -> Bool {
    return ((value &+ operand) & 0xFF00) != (value & 0xFF00)
}
