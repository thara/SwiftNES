class Cartridge {
    private var rom = [UInt8](repeating: 0x00, count: 32767)

    func read(addr: UInt16) -> UInt8 {
        return rom[Int(addr - 0x4020)]
    }

    func write(addr: UInt16, data: UInt8) {
        rom[Int(addr - 0x4020)] = data
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
