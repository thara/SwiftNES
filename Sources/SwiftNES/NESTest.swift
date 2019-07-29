public func nestest(romPath: String) throws {
    let rom = try NESFile(path: romPath)

    guard let cartridge = Cartridge(file: rom) else {
        fatalError("Unsupported mapper")
    }

    let nes = makeNES(renderer: DummyRenderer())
    nes.insert(cartridge: cartridge)

    nes.cpu.registers.PC = 0xC000

    nes.runFrame()
}

private class DummyRenderer: Renderer {
    func newLine(number: Int, pixels: [UInt32]) {}
}
