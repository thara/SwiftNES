extension PPUEmulator: IOPort {

    var port: IOPort {
        return self
    }

    func read(addr: UInt16) -> UInt8 {
        switch addr {
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

    func write(addr: UInt16, data: UInt8) {
        switch addr {
        case 0x2000:
            registers.controller = PPUController(rawValue: data)
        case 0x2001:
            registers.mask = PPUMask(rawValue: data)
        case 0x2003:
             registers.objectAttributeMemoryAddress = data
        case 0x2004:
             spriteOAM.primary[Int(registers.objectAttributeMemoryAddress.u16)] = data
        case 0x2005:
            registers.writeScroll(position: data)
        case 0x2006:
            registers.writeVRAMAddress(addr: data)
        case 0x2007:
            memory.write(data, at: registers.v)
        default:
            break
            // NOP
        }
    }
}
