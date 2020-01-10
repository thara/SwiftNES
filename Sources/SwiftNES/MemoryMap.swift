func read(at address: UInt16, from nes: inout NESState) -> UInt8 {
    return 0
}

func write(_ value: UInt8, at address: UInt16, to nes: inout NESState) {

}

func readWord(at address: UInt16, from nes: inout NESState) -> UInt16 {
    return read(at: address, from: &nes).u16 | (read(at: address + 1, from: &nes).u16 << 8)
}
