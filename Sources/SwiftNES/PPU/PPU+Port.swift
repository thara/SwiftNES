extension PPU: IOPort {

    var port: IOPort {
        return self
    }

    func read(from address: UInt16) -> UInt8 {
        switch address {
        case 0x2002:
            return registers.readStatus()
        case 0x2004:
            return spriteOAM.primary[Int(registers.objectAttributeMemoryAddress)]
        case 0x2007:
            return memory.read(at: registers.v)
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x2000:
            registers.controller = PPUController(rawValue: value)
        case 0x2001:
            registers.mask = PPUMask(rawValue: value)
        case 0x2003:
             registers.objectAttributeMemoryAddress = value
        case 0x2004:
             spriteOAM.primary[Int(registers.objectAttributeMemoryAddress.u16)] = value
        case 0x2005:
            registers.writeScroll(position: value)
        case 0x2006:
            registers.writeVRAMAddress(addr: value)
        case 0x2007:
            memory.write(value, at: registers.v)
        default:
            break
            // NOP
        }
    }
}
