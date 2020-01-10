func read(at address: UInt16, from nes: inout NESState) -> UInt8 {
    switch address {
    case 0x0000...0x1FFF:
        return nes.wram[Int(address)]

    // PPU
    case 0x2002:
        var result = nes.ppu.readStatus() | (nes.ppu.internalDataBus & 0b11111)
        // Race Condition
        if nes.ppu.scan.line == startVerticalBlank && nes.ppu.scan.dot < 2 {
            result &= ~0x80
        }
        nes.ppu.internalDataBus = result
        return result
    case 0x2004:
        // https://wiki.nesdev.com/w/index.php/PPU_sprite_evaluation
        var result: UInt8
        if nes.ppu.scan.line < 240 && 1 <= nes.ppu.scan.dot && nes.ppu.scan.dot <= 64 {
            // during sprite evaluation
            result = 0xFF
        } else {
            result = nes.ppu.sprite.primaryOAM[Int(nes.ppu.OAMADDR)]
        }
        nes.ppu.internalDataBus = result
        return result
    case 0x2000...0x3FFF:
        //return ppuPort?.read(from: ppuAddress(address)) ?? 0x00
        return 0x00
    case 0x4004, 0x4005, 0x4006, 0x4007, 0x4015:
        return 0xFF
    case 0x4016, 0x4017:
        //return controllerPort?.read(at: address) ?? 0x00
        return 0x00
    case 0x4020...0xFFFF:
        //return cartridge?.read(at: address) ?? 0x00
        return 0x00
    default:
        return 0x00
    }
}

func write(_ value: UInt8, at address: UInt16, to nes: inout NESState) {
    switch address {
    case 0x0000...0x07FF:
        nes.wram[Int(address)] = value
    case 0x2000...0x3FFF:
        //ppuPort?.write(value, to: ppuAddress(address))
        break
    case 0x4016, 0x4017:
        //controllerPort?.write(value)
        break
    case 0x4020...0xFFFF:
        //cartridge?.write(value, at: address)
        break
    default:
        break
    }
}

func readWord(at address: UInt16, from nes: inout NESState) -> UInt16 {
    return read(at: address, from: &nes).u16 | (read(at: address + 1, from: &nes).u16 << 8)
}
