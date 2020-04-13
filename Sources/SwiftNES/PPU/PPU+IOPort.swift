extension PPU: IOPort {

    func read(from address: UInt16) -> UInt8 {
        var result: UInt8

        switch address {
        case 0x2002:
            result = registers.readStatus() | (internalDataBus & 0b11111)
            // Race Condition
            if scan.line == startVerticalBlank && scan.dot < 2 {
                result &= ~0x80
            }
        case 0x2004:
            // https://wiki.nesdev.com/w/index.php/PPU_sprite_evaluation
            if scan.line < 240 && 1 <= scan.dot && scan.dot <= 64 {
                // during sprite evaluation
                result = 0xFF
            } else {
                result = primaryOAM[Int(registers.objectAttributeMemoryAddress)]
            }
        case 0x2007:
            if registers.v <= 0x3EFF {
                result = registers.data
                registers.data = memory.read(at: registers.v)
            } else {
                result = memory.read(at: registers.v)
            }
            registers.incrV()
        default:
            result = 0x00
        }

        internalDataBus = result
        return result
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
            primaryOAM[Int(registers.objectAttributeMemoryAddress)] = value
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
