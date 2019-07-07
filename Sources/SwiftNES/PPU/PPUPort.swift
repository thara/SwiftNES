protocol PPUPort: class {
    func read(addr: UInt16) -> UInt8
    func write(addr: UInt16, data: UInt8)
}

extension PPUEmulator: PPUPort {

    func read(addr: UInt16) -> UInt8 {
        switch addr {
        case 0x2002:
            return status.rawValue
        case 0x2004:
            return objectAttributeMemoryData
        case 0x2007:
            return data
        default:
            return 0x00
        }
    }

    func write(addr: UInt16, data: UInt8) {
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
        default:
            break
            // NOP
        }
    }
}

extension PPUEmulator: PPU {

    /// PPUCTRL
    var controller: UInt8 {
        get { return registers.controller.rawValue }
        set { registers.controller = PPUController(rawValue: newValue) }
    }

    /// PPUMASK
    var mask: UInt8 {
        get { return registers.mask.rawValue }
        set { registers.mask = PPUMask(rawValue: newValue) }
    }

    /// PPUSTATUS
    var status: PPUStatus {
        let s = registers.status
        registers.status.remove(.vblank)
        latch = false
        return s
    }

    /// OAMADDR
    var objectAttributeMemoryAddress: UInt8 {
        get { return registers.objectAttributeMemoryAddress }
        set { registers.objectAttributeMemoryAddress = newValue }
    }

    /// OAMDATA
    var objectAttributeMemoryData: UInt8 {
        get { return oam.read(addr: registers.objectAttributeMemoryAddress.u16) }
        set { oam.write(addr: registers.objectAttributeMemoryAddress.u16, data: newValue) }
    }

    /// PPUSCROLL
    var scroll: UInt8 {
        get { return registers.scroll }
        set {
            registers.scroll = newValue
            if !latch {
                scrollPosition.x = newValue
            } else {
                scrollPosition.y = newValue
            }
            latch = !latch
        }
    }

    /// PPUADDR
    var address: UInt8 {
        get { return registers.address }
        set {
            registers.address = newValue
            if !latch {
                currentAddress = newValue.u16 << 8 | (currentAddress & 0x00FF)
            } else {
                currentAddress = (currentAddress & 0xFF00) | newValue.u16
            }
            latch = !latch
        }
    }

    /// PPUDATA
    var data: UInt8 {
        get { return memory.read(addr: currentAddress) }
        set {
            memory.write(addr: currentAddress, data: newValue)
        }
    }
}
