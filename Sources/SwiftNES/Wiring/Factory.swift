public func makeNES(_ lineBufferFactory: LineBufferFactory) -> NES {
    let interruptLine = InterruptLine()

    let cpuBus = CPUBus()
    let cpu = CPU(memory: cpuBus, interruptLine: interruptLine)

    let ppuBus = PPUBus()
    let ppu = PPU(memory: ppuBus, interruptLine: interruptLine, lineBufferFactory: lineBufferFactory)

    cpuBus.ppuPort = ppu.port

    let cartridgeDrive = BusConnectedCartridgeDrive(cpuBus: cpuBus, ppuBus: ppuBus)

    return NES(cpu: cpu, ppu: ppu, cartridgeDrive: cartridgeDrive)
}

struct BusConnectedCartridgeDrive: CartridgeDrive {

    let cpuBus: CPUBus
    let ppuBus: PPUBus

    func insert(_ cartridge: Cartridge) {
        cpuBus.cartridge = cartridge
        ppuBus.cartridge = cartridge
    }
}
