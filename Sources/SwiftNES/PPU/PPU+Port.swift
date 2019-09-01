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
            defer { registers.incrV() }

            if registers.v <= 0x3EFF {
                let data = registers.data
                registers.data = memory.read(at: registers.v)
                return data
            } else {
                return memory.read(at: registers.v)
            }
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x2000:
            registers.writeController(value)
        case 0x2001:
            registers.mask = PPUMask(rawValue: value)
        case 0x2003:
            registers.objectAttributeMemoryAddress = value
        case 0x2004:
            spriteOAM.primary[Int(registers.objectAttributeMemoryAddress)] = value
            registers.objectAttributeMemoryAddress &+= 1
        case 0x2005:
            registers.writeScroll(position: value)
        case 0x2006:
            registers.writeVRAMAddress(addr: value)
        case 0x2007:
            memory.write(value, at: registers.v)
            registers.incrV()
        default:
            break
            // NOP
        }
    }
}
