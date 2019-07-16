protocol PPU: class {
    var port: PPUPort { get }

    func step()
}

protocol PPUPort: class {
    func read(addr: UInt16) -> UInt8
    func write(addr: UInt16, data: UInt8)
}
