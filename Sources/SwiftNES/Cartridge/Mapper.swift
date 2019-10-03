protocol Mapper: class {

    var program: [UInt8] { get }
    var characterData: [UInt8] { get }

    /// Read a byte at the given `address`
    func read(at address: UInt16) -> UInt8
    /// Write the given `value` at the `address`
    func write(_ value: UInt8, at address: UInt16)

    var mirroring: Mirroring { get }
}
