class Cartridge {
    private var rom = [UInt8](repeating: 0x00, count: 32767)

    /// Read a byte at the given `address` on this cartridge
    func read(at address: UInt16) -> UInt8 {
        return rom[Int(address - 0x4020)]
    }

    /// Write the given `value` at the `address` into this cartridge
    func write(_ value: UInt8, at address: UInt16) {
        rom[Int(address - 0x4020)] = value
    }

    func readCharacter(addr: UInt16) -> UInt8 {
        return rom[Int(addr)]
    }

    func load(rawData: [UInt8]) {
        rom = rawData
    }

    func load(file: NESFile) {
        rom = file.program
    }
}
