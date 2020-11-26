struct NES {
    var cpu = CPU()

    let interruptLine = InterruptLine()
}

// MARK: - Memory
protocol Memory: class {
    /// Read a byte at the given `address` on CPU memory
    func readCPU(at: UInt16) -> UInt8
    /// Write the given `value` at the `address` into CPU memory
    func writeCPU(_ value: UInt8, at: UInt16)

    /// Read a byte at the given `address` on PPU memory
    func readPPU(at: UInt16) -> UInt8
    /// Write the given `value` at the `address` into PPU memory
    func writePPU(_ value: UInt8, at: UInt16)
}

extension Memory {
    /* func readCPU(at address: UInt16) -> UInt16 { */
    /*     return readCPU(at: address).u16 | (readCPU(at: address + 1).u16 << 8) */
    /* } */

    /* func readPPU(at address: UInt16) -> UInt16 { */
    /*     return readPPU(at: address).u16 | (readPPU(at: address + 1).u16 << 8) */
    /* } */
}

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
