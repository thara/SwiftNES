protocol PPUPort: class {
    func read(addr: UInt16) -> UInt8
    func write(addr: UInt16, data: UInt8)
}

extension PPUEmulator: PPUPort {

    func read(addr: UInt16) -> UInt8 {
        switch addr {
        case 0x2002:
            return registers.readStatus()
        case 0x2004:
            return oam[Int(registers.objectAttributeMemoryAddress)]
        case 0x2007:
            return memory.read(addr: registers.v)
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
             oam[Int(registers.objectAttributeMemoryAddress.u16)] = data
        case 0x2005:
            registers.writeScroll(position: data)
        case 0x2006:
            registers.writeVRAMAddress(addr: data)
        case 0x2007:
            memory.write(addr: registers.v, data: data)
        default:
            break
            // NOP
        }
    }
}
