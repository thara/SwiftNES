import Logging

final class CPU {

    var registers: CPURegisters
    var memory: Memory

    let interruptLine: InterruptLine

    private var instructions: [Instruction?]

    // TODO Cycle-accurate
    private var cycles: UInt = 0

    init(memory: Memory, interruptLine: InterruptLine) {
        self.registers = CPURegisters()
        self.memory = memory
        self.interruptLine = interruptLine

        self.instructions = []  // Need all properties are initialized because 'self' is used in 'buildInstructionTable'
        self.instructions = buildInstructionTable()
    }

    func powerOn() {
        registers.powerOn()
        clear()

        interruptLine.clear([.NMI, .IRQ])
        interruptLine.send(.RESET)
    }

    func step() -> UInt {
        let before = cycles

        if !interrupt() {
            let opcode = fetch()
            let instruction = decode(opcode)
            execute(instruction)
        }

        if before <= cycles {
            return cycles &- before
        } else {
            return UInt.max &- before &+ cycles
        }
    }

    @inline(__always)
    func tick() {
        cycles &+= 1
    }

    @inline(__always)
    func tick(count: UInt) {
        cycles &+= count
    }
}

// MARK: - CPU.run implementation
extension CPU {

    func fetch() -> OpCode {
        let opcode = read(at: registers.PC)
        registers.PC &+= 1
        return opcode
    }

    func decode(_ opcode: OpCode) -> Instruction {
        return instructions[Int(opcode)]!
    }

    func execute(_ instruction: Instruction) {
        let operand = instruction.fetchOperand()
        registers.PC = instruction.exec(operand)
    }
}

// MARK: - Memory
extension CPU: Memory {

    @inline(__always)
    func read(at address: UInt16) -> UInt8 {
        tick()
        return memory.read(at: address)
    }

    @inline(__always)
    func write(_ value: UInt8, at address: UInt16) {
        if address == 0x4014 { // OAMDMA
            writeOAM(value)
        } else {
            tick()
            memory.write(value, at: address)
        }
    }

    @inline(__always)
    func clear() {
        memory.clear()
    }

    // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
    func writeOAM(_ value: UInt8) {
        let start = value.u16 &* 0x100
        for address in start...(start &+ 0xFF) {
            let data = read(at: address)
            write(data, at: 0x2004)
        }

        // dummy cycles
        tick()
        if cycles % 2 == 1 {
            tick()
        }
        eventLogger.info("OAM DMA 0x\(start.radix16) to 0x\((start &+ 0xFF).radix16)")
    }
}

// MARK: - Stack
extension CPU {
    func pushStack(_ value: UInt8) {
        write(value, at: registers.S.u16 &+ 0x100)
        registers.S &-= 1
    }

    func pushStack(word: UInt16) {
        pushStack(UInt8(word >> 8))
        pushStack(UInt8(word & 0xFF))
    }

    func pullStack() -> UInt8 {
        registers.S &+= 1
        return read(at: registers.S.u16 &+ 0x100)
    }

    func pullStack() -> UInt16 {
        let lo: UInt8 = pullStack()
        let ho: UInt8 = pullStack()
        return ho.u16 &<< 8 | lo.u16
    }
}

// MARK: - Interrupt
extension CPU {

    var interrupted: Bool {
        return !interruptLine.get().isEmpty
    }

    func interrupt() -> Bool {
        switch interruptLine.get() {
        case .RESET:
            reset()
        case .NMI:
            handleNMI()
        case .IRQ:
            if registers.P.contains(.I) {
                handleIRQ()
            }
        case .BRK:
            if registers.P.contains(.I) {
                handleBRK()
            }
        default:
            return false
        }

        return true
    }

    /// Reset registers & memory state
    func reset() {
        tick(count: 5)
#if nestest
        registers.PC = 0xC000
        interruptLine.clear(.RESET)
        tick(count: 2)
#else
        registers.PC = readWord(at: 0xFFFC)
        registers.P.formUnion(.I)
        registers.S -= 3

        interruptLine.clear(.RESET)
#endif
    }

    func handleNMI() {
        tick(count: 2)

        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.P.formUnion(.I)
        registers.PC = readWord(at: 0xFFFA)

        interruptLine.clear(.NMI)
    }

    func handleIRQ() {
        tick(count: 2)

        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.P.formUnion(.I)
        registers.PC = readWord(at: 0xFFFE)

        interruptLine.clear(.IRQ)
    }

    func handleBRK() {
        tick(count: 2)

        registers.PC &+= 1
        pushStack(word: registers.PC)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        // http://visual6502.org/wiki/index.php?title=6502_BRK_and_B_bit
        pushStack(registers.P.rawValue | Status.interruptedB.rawValue)
        registers.P.formUnion(.I)
        registers.PC = readWord(at: 0xFFFE)

        interruptLine.clear(.BRK)
    }
}
