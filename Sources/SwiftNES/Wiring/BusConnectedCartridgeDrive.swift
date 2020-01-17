struct BusConnectedCartridgeDrive: CartridgeDrive {

    let ppuMemoryMap: PPUMemoryMap

    func insert(_ cartridge: Cartridge) {
        ppuMemoryMap.cartridge = cartridge
    }
}
