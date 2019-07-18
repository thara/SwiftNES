protocol IOPort: class {
    func read(addr: UInt16) -> UInt8
    func write(addr: UInt16, data: UInt8)
}
