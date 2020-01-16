protocol Memory {
    /// Read a byte at the given `address` on this memory
    func read(at address: UInt16) -> UInt8
    /// Write the given `value` at the `address` into this memory
    mutating func write(_ value: UInt8, at address: UInt16)

    /// Read a word at the given `address` on this memory
    func readWord(at address: UInt16) -> UInt16

    mutating func clear()
}

@inline(__always)
func readWord(at address: UInt16, read: (UInt16) -> UInt8) -> UInt16 {
    return read(address).u16 | (read(address + 1).u16 << 8)
}

extension Memory {
    func readWord(at address: UInt16) -> UInt16 {
        return SwiftNES.readWord(at: address, read: read)
    }
}

extension Array: Memory where Element == UInt8 {

    @inline(__always)
    func read(at address: UInt16) -> UInt8 {
        return self[Int(address)]
    }

    @inline(__always)
    mutating func write(_ value: UInt8, at address: UInt16) {
        self[Int(address)] = value
    }

    @inline(__always)
    mutating func clear() {
        self = [UInt8](repeating: 0x00, count: self.count)
    }

    @inline(__always)
    mutating func fill(_ value: UInt8) {
        self = [UInt8](repeating: value, count: self.count)
    }
}
