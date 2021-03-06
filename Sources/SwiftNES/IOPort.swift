protocol IOPort {

    /// Read a byte from the port specified by given `address`
    mutating func read(from address: UInt16) -> UInt8

    /// Write a value to the port specified by given `address`
    mutating func write(_ value: UInt8, to address: UInt16)
}
