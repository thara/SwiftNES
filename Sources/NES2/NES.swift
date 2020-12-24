class NES {
    var cpuCycles: UInt = 0

    var cpuRegister = CPURegister()
    var ppuRegister = PPURegister()
    var ppuMemory = PPUMemory()

    var interrupt: Interrupt = []
}

extension NES: CPU {
    typealias Bus = CPUInterconnect

    @discardableResult
    func cpuTick() -> UInt {
        cpuCycles += 1
        return cpuCycles
    }

    @discardableResult
    func cpuTick(count: UInt) -> UInt {
        cpuCycles += count
        return cpuCycles
    }
}

final class CPUInterconnect: CPUBus {
    private var wram: [UInt8]

    var nes: NES

    var ppuInterconnect: PPUInterconnect

    init(nes: NES, ppuInterconnect: PPUInterconnect) {
        self.wram = [UInt8](repeating: 0x00, count: 32767)
        self.nes = nes
        self.ppuInterconnect = ppuInterconnect
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return wram.read(at: address)
        case 0x2000...0x3FFF:
            return nes.ppuRegister.readPPURegister(from: ppuAddress(address), by: self)
        /* case 0x4000...0x4013, 0x4015: */
        /*     return apu.read(from: address) ?? 0x00 */
        /* case 0x4016, 0x4017: */
        /*     return controllers.read(at: address) */
        /* case 0x4020...0xFFFF: */
        /*     return mapper.read(at: address) ?? 0x00 */
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x07FF:
            wram.write(value, at: address)
        /* case 0x2000...0x3FFF: */
        /*     ppuPort?.write(value, to: ppuAddress(address)) */
        /* case 0x4000...0x4013, 0x4015: */
        /*     apuPort?.write(value, to: address) */
        /* case 0x4016: */
        /*     controllerPort?.write(value) */
        /* case 0x4017: */
        /*     controllerPort?.write(value) */
        /*     apuPort?.write(value, to: address) */
        /* case 0x4020...0xFFFF: */
        /*     cartridge?.write(value, at: address) */
        default:
            break
        }
    }
}

extension PPURegister {
    mutating func readPPURegister<M: PPUBus>(from address: UInt16, ppu: inout PPU, memory: inout PPUMemory, bus: inout M) -> UInt8 {
        var result: UInt8

        switch address {
        case 0x2002:
            result = readStatus() | (memory.internalDataBus & 0b11111)
            // Race Condition
            if ppu.scan.line == startVerticalBlank && ppu.scan.dot < 2 {
                result &= ~0x80
            }
        case 0x2004:
            // https://wiki.nesdev.com/w/index.php/PPU_sprite_evaluation
            if ppu.scan.line < 240 && 1 <= ppu.scan.dot && ppu.scan.dot <= 64 {
                // during sprite evaluation
                result = 0xFF
            } else {
                result = memory.primaryOAM[Int(objectAttributeMemoryAddress)]
            }
        case 0x2007:
            if v <= 0x3EFF {
                result = data
                data = bus.read(at: v)
            } else {
                result = bus.read(at: v)
            }
            incrV()
        default:
            result = 0x00
        }

        memory.internalDataBus = result
        return result
    }

    mutating func writePPURegister<B: PPUBus>(_ value: UInt8, to address: UInt16, memory: inout PPUMemory, bus: inout B) {
        switch address {
        case 0x2000:
            writeController(value)
        case 0x2001:
            mask = PPUMask(rawValue: value)
        case 0x2003:
            objectAttributeMemoryAddress = value
        case 0x2004:
            memory.primaryOAM[Int(objectAttributeMemoryAddress)] = value
            objectAttributeMemoryAddress &+= 1
        case 0x2005:
            writeScroll(position: value)
        case 0x2006:
            writeVRAMAddress(addr: value)
        case 0x2007:
            bus.write(value, at: v)
            incrV()
        default:
            break
        // NOP
        }
    }
}

struct PPUInterconnect: PPUBus {

    var memory: PPUMemory

    func read(at address: UInt16) -> UInt8 {
        switch address {
        /* case 0x0000...0x1FFF: */
        /*     return nes.mapper?.read(at: address) ?? 0x00 */
        /* case 0x2000...0x2FFF: */
        /*     return ppu.nameTable.read(at: toNameTableAddress(address, mirroring: mapper?.mirroring)) */
        /* case 0x3000...0x3EFF: */
        /*     return ppu.nameTable.read(at: toNameTableAddress(address &- 0x1000, mirroring: nes.mapper?.mirroring)) */
        case 0x3F00...0x3FFF:
            return memory.paletteRAMIndexes.read(at: toPalleteAddress(address))
        default:
            return 0x00
        }
    }

    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        /* case 0x0000...0x1FFF: */
        /*     mapper?.write(value, at: address) */
        /* case 0x2000...0x2FFF: */
        /*     ppu.nameTable.write(value, at: toNameTableAddress(address, mirroring: nes.mapper?.mirroring)) */
        /* case 0x3000...0x3EFF: */
        /*     ppu.nameTable.write(value, at: toNameTableAddress(address &- 0x1000, mirroring: nes.mapper?.mirroring)) */
        case 0x3F00...0x3FFF:
            memory.paletteRAMIndexes.write(value, at: toPalleteAddress(address))
        default:
            break  // NOP
        }
    }
}

/* func toNameTableAddress(_ baseAddress: UInt16, mirroring: Mirroring?) -> UInt16 { */
/*     switch mirroring { */
/*     case .vertical?: */
/*         return baseAddress % 0x0800 */
/*     case .horizontal?: */
/*         if 0x2800 <= baseAddress { */
/*             return 0x0800 &+ baseAddress % 0x0400 */
/*         } else { */
/*             return baseAddress % 0x0400 */
/*         } */
/*     default: */
/*         return baseAddress &- 0x2000 */
/*     } */
/* } */

func toPalleteAddress(_ baseAddress: UInt16) -> UInt16 {
    // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
    let addr = baseAddress % 32

    if addr % 4 == 0 {
        return (addr | 0x10)
    } else {
        return addr
    }
}

private func ppuAddress(_ address: UInt16) -> UInt16 {
    // repears every 8 bytes
    return 0x2000 &+ address % 8
}
