func readCPU(at address: UInt16, from nes: inout NES) -> UInt8 {
    nes.cpu.tick()
    return read(at: address, from: &nes)
}

func writeCPU(_ value: UInt8, at address: UInt16, to nes: inout NES) {
    if address == 0x4014 { // OAMDMA
        writeOAM(value, to: &nes)
        return
    }
    nes.cpu.tick()

    write(value, at: address, to: &nes)
}

func read(at address: UInt16, from nes: inout NES) -> UInt8 {
    switch address {
    case 0x0000...0x1FFF:
        return nes.wram.read(at: address)
    case 0x2000...0x3FFF:
        return nes.ppu.read(from: ppuAddress(address))
    case 0x4004, 0x4005, 0x4006, 0x4007, 0x4015:
        return 0xFF
    case 0x4016, 0x4017:
        return nes.controllerPort.read(at: address)
    case 0x4020...0xFFFF:
        return nes.cartridge?.read(at: address) ?? 0x00
    default:
        return 0x00
    }
}

func write(_ value: UInt8, at address: UInt16, to nes: inout NES) {
    switch address {
    case 0x0000...0x07FF:
        nes.wram.write(value, at: address)
    case 0x2000...0x3FFF:
        nes.ppu.write(value, to: ppuAddress(address))
    case 0x4016, 0x4017:
        nes.controllerPort.write(value)
    case 0x4020...0xFFFF:
        nes.cartridge?.write(value, at: address)
    default:
        break
    }
}

private func ppuAddress(_ address: UInt16) -> UInt16 {
    // repears every 8 bytes
    return 0x2000 &+ address % 8
}

@inline(__always)
func readWord(at address: UInt16, from nes: inout NES) -> UInt16 {
    return readCPU(at: address, from: &nes).u16 | (readCPU(at: address + 1, from: &nes).u16 << 8)
}

// http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
func writeOAM(_ value: UInt8, to nes: inout NES) {
    let start = value.u16 &* 0x100
    for address in start...(start &+ 0xFF) {
        let data = readCPU(at: address, from: &nes)
        writeCPU(data, at: 0x2004, to: &nes)
    }

    // dummy cycles
    nes.cpu.tick()
    if nes.cpu.cycles % 2 == 1 {
        nes.cpu.tick()
    }
}

func readOnIndirect(operand: UInt16, read: (UInt16) -> UInt8) -> UInt16 {
    let low = read(operand).u16
    let high = read(operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8
    return low | high
}
