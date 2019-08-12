public func makeNES(renderer: Renderer) -> NES {
    let interruptLine = InterruptLine()

    let cpuBus = CPUBus()
    let cpu = CPU(memory: cpuBus, interruptLine: interruptLine)

    let ppuBus = PPUBus()
    let ppu = PPU(memory: ppuBus, interruptLine: interruptLine, renderer: renderer)

    cpuBus.ppuPort = ppu.port

    let controllerPort = ControllerPort(port1: nil, port2: nil)
    cpuBus.controllerPort = controllerPort

    let cartridgeDrive = BusConnectedCartridgeDrive(cpuBus: cpuBus, ppuBus: ppuBus)

    return NES(cpu: cpu, ppu: ppu, cartridgeDrive: cartridgeDrive, controllerPort: controllerPort)
}

struct BusConnectedCartridgeDrive: CartridgeDrive {

    let cpuBus: CPUBus
    let ppuBus: PPUBus

    func insert(_ cartridge: Cartridge) {
        cpuBus.cartridge = cartridge
        ppuBus.cartridge = cartridge

        cartridge.applyMirroring(to: ppuBus)
    }
}
