func readPPURegister(from address: UInt16, on nes: inout NES) -> UInt8 {
    var result: UInt8

    switch address {
    case 0x2002:
        result = nes.ppu.readStatus() | (nes.ppu.internalDataBus & 0b11111)
        // Race Condition
        if nes.ppu.scan.line == startVerticalBlank && nes.ppu.scan.dot < 2 {
            result &= ~0x80
        }
    case 0x2004:
        // https://wiki.nesdev.com/w/index.php/PPU_sprite_evaluation
        if nes.ppu.scan.line < 240 && 1 <= nes.ppu.scan.dot && nes.ppu.scan.dot <= 64 {
            // during sprite evaluation
            result = 0xFF
        } else {
            result = nes.ppu.primaryOAM[Int(nes.ppu.objectAttributeMemoryAddress)]
        }
    case 0x2007:
        if nes.ppu.v <= 0x3EFF {
            result = nes.ppu.data
            nes.ppu.data = readPPU(at: nes.ppu.v, from: &nes)
        } else {
            result = readPPU(at: nes.ppu.v, from: &nes)
        }
        nes.ppu.incrV()
    default:
        result = 0x00
    }

    nes.ppu.internalDataBus = result
    return result
}

func writePPURegister(_ value: UInt8, to address: UInt16, on nes: inout NES) {
    switch address {
    case 0x2000:
        nes.ppu.writeController(value)
    case 0x2001:
        nes.ppu.mask = PPUMask(rawValue: value)
    case 0x2003:
        nes.ppu.objectAttributeMemoryAddress = value
    case 0x2004:
        nes.ppu.primaryOAM[Int(nes.ppu.objectAttributeMemoryAddress)] = value
        nes.ppu.objectAttributeMemoryAddress &+= 1
    case 0x2005:
        nes.ppu.writeScroll(position: value)
    case 0x2006:
        nes.ppu.writeVRAMAddress(addr: value)
    case 0x2007:
        writePPU(value, at: nes.ppu.v, to: &nes)
        nes.ppu.incrV()
    default:
        break
        // NOP
    }
}

func readPPU(at address: UInt16, from nes: inout NES) -> UInt8 {
    switch address {
    case 0x0000...0x1FFF:
        return nes.cartridge?.read(at: address) ?? 0x00
    case 0x2000...0x2FFF:
        return nes.ppu.nameTable.read(at: toNameTableAddress(address, mirroring: nes.mirroring))
    case 0x3000...0x3EFF:
        return nes.ppu.nameTable.read(at: toNameTableAddress(address &- 0x1000, mirroring: nes.mirroring))
    case 0x3F00...0x3FFF:
        return nes.ppu.paletteRAMIndexes.read(at: toPalleteAddress(address))
    default:
        return 0x00
    }
}

func writePPU(_ value: UInt8, at address: UInt16, to nes: inout NES) {
    switch address {
    case 0x0000...0x1FFF:
        nes.cartridge?.write(value, at: address)
    case 0x2000...0x2FFF:
        nes.ppu.nameTable.write(value, at: toNameTableAddress(address, mirroring: nes.mirroring))
    case 0x3000...0x3EFF:
        nes.ppu.nameTable.write(value, at: toNameTableAddress(address &- 0x1000, mirroring: nes.mirroring))
    case 0x3F00...0x3FFF:
        nes.ppu.paletteRAMIndexes.write(value, at: toPalleteAddress(address))
    default:
        break // NOP
    }
}

func toNameTableAddress(_ baseAddress: UInt16, mirroring: Mirroring?) -> UInt16 {
    switch mirroring {
    case .vertical?:
        return baseAddress % 0x0800
    case .horizontal?:
        if 0x2800 <= baseAddress {
            return 0x0800 &+ baseAddress % 0x0400
        } else {
            return baseAddress % 0x0400
        }
    default:
        return baseAddress &- 0x2000
    }
}

func toPalleteAddress(_ baseAddress: UInt16) -> UInt16 {
    // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
    let addr = baseAddress % 32

    if addr % 4 == 0 {
        return (addr | 0x10)
    } else {
        return addr
    }
}
