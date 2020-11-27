class NES {
    var cpu: CPU

    var wram: [UInt8]

    let interruptLine: InterruptLine

    init() {
        self.interruptLine = InterruptLine()

        self.cpu = CPU(interruptLine: interruptLine)
        self.wram = [UInt8](repeating: 0x00, count: 32767)
    }

    static func make() -> NES {
        let nes = NES()
        nes.cpu.readCPU = { NES.readCPU(at: $0, on: nes) }
        nes.cpu.writeCPU = { NES.writeCPU($0, at: $1, on: nes) }
        return nes
    }

    /// Read a byte at the given `address` on CPU memory
    static func readCPU(at address: UInt16, on nes: NES) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.wram[Int(address)]
        default:
            return 0;
        }
    }

    /// Write the given `value` at the `address` into CPU memory
    static func writeCPU(_ value: UInt8, at: UInt16, on nes: NES) {
    }
}

// MARK: - Memory
/* protocol Memory: class { */
/*     /// Read a byte at the given `address` on CPU memory */
/*     func readCPU(at: UInt16) -> UInt8 */
/*     /// Write the given `value` at the `address` into CPU memory */
/*     func writeCPU(_ value: UInt8, at: UInt16) */

/*     /// Read a byte at the given `address` on PPU memory */
/*     func readPPU(at: UInt16) -> UInt8 */
/*     /// Write the given `value` at the `address` into PPU memory */
/*     func writePPU(_ value: UInt8, at: UInt16) */
/* } */

/* extension Memory { */
    /* func readCPU(at address: UInt16) -> UInt16 { */
    /*     return readCPU(at: address).u16 | (readCPU(at: address + 1).u16 << 8) */
    /* } */

    /* func readPPU(at address: UInt16) -> UInt16 { */
    /*     return readPPU(at: address).u16 | (readPPU(at: address + 1).u16 << 8) */
    /* } */
/* } */

// MARK: - Interrupt
struct Interrupt: OptionSet {
    let rawValue: UInt8

    static let RESET = Interrupt(rawValue: 1 << 3)
    static let NMI = Interrupt(rawValue: 1 << 2)
    static let IRQ = Interrupt(rawValue: 1 << 1)
    static let BRK = Interrupt(rawValue: 1 << 0)
}

final class InterruptLine {
    private var current: Interrupt = []

    func send(_ interrupt: Interrupt) {
        current.formUnion(interrupt)
    }

    func get() -> Interrupt {
        return current
    }

    func clear(_ interrupt: Interrupt) {
        current.remove(interrupt)
    }

    var interrupted: Bool {
        return !current.isEmpty
    }
}
