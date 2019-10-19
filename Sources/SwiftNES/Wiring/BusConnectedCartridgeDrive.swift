struct BusConnectedCartridgeDrive: CartridgeDrive {

    let cpuMemoryMap: CPUMemoryMap
    let ppuMemoryMap: PPUMemoryMap

    func insert(_ cartridge: Cartridge) {
        cpuMemoryMap.cartridge = cartridge
        ppuMemoryMap.cartridge = cartridge
    }
}
