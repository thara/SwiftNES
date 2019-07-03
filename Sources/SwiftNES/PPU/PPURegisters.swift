struct PPURegisters {
    /// PPUCTRL
    var controller: UInt8
    /// PPUMASK
    var mask: UInt8
    /// PPUSTATUS
    var status: UInt8
    /// OAMADDR
    var objectAttributeMemoryAddress: UInt8
    /// OAMDATA
    var objectAttributeMemoryData: UInt8
    /// PPUSCROLL
    var scroll: UInt8
    /// PPUADDR
    var address: UInt8
    /// PPUDATA
    var data: UInt8
    /// OAMDMA
    var objectAttributeMemoryDMA: UInt8
}

protocol PPUIORegister {
    func read(addr: UInt16) -> UInt8?
    mutating func write(addr: UInt16, data: UInt8)
}

extension PPURegisters: PPUIORegister {

    func read(addr: UInt16) -> UInt8? {
        switch addr {
        case 0x2002:
            // TODO clear bit 7 and also the address latch used by PPUSCROLL and PPUADDR
            return status
        case 0x2004:
            return objectAttributeMemoryData
        case 0x2007:
            return data
        default:
            return nil
        }
    }

    mutating func write(addr: UInt16, data: UInt8) {
        switch addr {
        case 0x2000:
            controller = data
        case 0x2001:
            mask = data
        case 0x2003:
            objectAttributeMemoryAddress = data
        case 0x2004:
            objectAttributeMemoryData = data
        case 0x2005:
            scroll = data
        case 0x2006:
            address = data
        case 0x2007:
            self.data = data
        case 0x4014:
            self.objectAttributeMemoryDMA = data
        default:
            break
            // NOP
        }
    }
}
