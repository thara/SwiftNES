extension Array where Element == UInt8 {

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
