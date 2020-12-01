enum NESMemoryMap: MemoryMap {
    case instance
}

extension NESMemoryMap {
    static func cpuRead(at address: UInt16, from nes: inout NES) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.cpu.wram.read(at: address)
        case 0x2000...0x3FFF:
            return nes.readPPURegister(from: ppuAddress(address), by: Self.instance)
        /* case 0x4000...0x4013, 0x4015: */
        /*     return apuPort?.read(from: address) ?? 0x00 */
        /* case 0x4016, 0x4017: */
        /*     return nes.controllers.read(at: address) */
        case 0x4020...0xFFFF:
            return nes.mapper?.read(at: address) ?? 0x00
        default:
            return 0x00
        }
    }

    static func cpuWrite(_ value: UInt8, at address: UInt16, to nes: inout NES) {
        switch address {
        case 0x0000...0x07FF:
            nes.cpu.wram.write(value, at: address)
        case 0x2000...0x3FFF:
            nes.writePPURegister(value, to: ppuAddress(address), by: Self.instance)
        /* case 0x4000...0x4013, 0x4015: */
        /*     apuPort?.write(value, to: address) */
        /* case 0x4016: */
        /*     nes.controllers.write(value) */
        /* case 0x4017: */
        /*     nes.controllers.write(value) */
        /* apuPort?.write(value, to: address) */
        case 0x4020...0xFFFF:
            nes.mapper?.write(value, at: address)
        default:
            break
        }
    }
}

private func ppuAddress(_ address: UInt16) -> UInt16 {
    // repears every 8 bytes
    return 0x2000 &+ address % 8
}

extension NESMemoryMap {
    static func ppuRead(at address: UInt16, from nes: inout NES) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.mapper?.read(at: address) ?? 0x00
        case 0x2000...0x2FFF:
            return nes.ppu.nameTable.read(at: toNameTableAddress(address, mirroring: nes.mapper?.mirroring))
        case 0x3000...0x3EFF:
            return nes.ppu.nameTable.read(at: toNameTableAddress(address &- 0x1000, mirroring: nes.mapper?.mirroring))
        case 0x3F00...0x3FFF:
            return nes.ppu.paletteRAMIndexes.read(at: toPalleteAddress(address))
        default:
            return 0x00
        }
    }

    static func ppuWrite(_ value: UInt8, at address: UInt16, to nes: inout NES) {
        switch address {
        case 0x0000...0x1FFF:
            nes.mapper?.write(value, at: address)
        case 0x2000...0x2FFF:
            nes.ppu.nameTable.write(value, at: toNameTableAddress(address, mirroring: nes.mapper?.mirroring))
        case 0x3000...0x3EFF:
            nes.ppu.nameTable.write(value, at: toNameTableAddress(address &- 0x1000, mirroring: nes.mapper?.mirroring))
        case 0x3F00...0x3FFF:
            nes.ppu.paletteRAMIndexes.write(value, at: toPalleteAddress(address))
        default:
            break  // NOP
        }
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
