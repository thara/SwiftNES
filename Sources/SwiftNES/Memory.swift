protocol Memory {
    /// Read a byte at the given `address` on this memory
    func read(at address: UInt16) -> UInt8
    /// Write the given `value` at the `address` into this memory
    func write(_ value: UInt8, at address: UInt16)

    /// Read a word at the given `address` on this memory
    func readWord(at address: UInt16) -> UInt16
}

extension Memory {
    func readWord(at address: UInt16) -> UInt16 {
        return read(at: address).u16 | (read(at: address + 1).u16 << 8)
    }
}

class RAM: Memory {
    private var rawData: [UInt8]

    init(rawData: [UInt8]) {
        self.rawData = rawData
    }

    convenience init(data: UInt8, count: Int) {
        self.init(rawData: [UInt8](repeating: data, count: count))
    }

    func read(at address: UInt16) -> UInt8 {
        return rawData[Int(address)]
    }

    func write(_ value: UInt8, at address: UInt16) {
        rawData[Int(address)] = value
    }
}
