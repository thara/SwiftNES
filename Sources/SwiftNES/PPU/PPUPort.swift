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
        registers.writeToggle = false
        return s
    }

    /// OAMADDR
    var objectAttributeMemoryAddress: UInt8 {
        get { return registers.objectAttributeMemoryAddress }
        set { registers.objectAttributeMemoryAddress = newValue }
    }

    /// OAMDATA
    var objectAttributeMemoryData: UInt8 {
        get { return oam[Int(registers.objectAttributeMemoryAddress)] }
        set { oam[Int(registers.objectAttributeMemoryAddress.u16)] = newValue }
    }

    /// PPUSCROLL
    var scroll: UInt8 {
        get { return registers.scroll }
        set {
            registers.scroll = newValue
            if !registers.writeToggle {
                scrollPosition.x = newValue
            } else {
                scrollPosition.y = newValue
            }
            registers.writeToggle = !registers.writeToggle
        }
    }

    /// PPUADDR
    var address: UInt8 {
        get { return registers.address }
        set {
            registers.address = newValue
            if !registers.writeToggle {
                registers.vramAddr = newValue.u16 << 8 | (registers.vramAddr & 0x00FF)
            } else {
                registers.vramAddr = (registers.vramAddr & 0xFF00) | newValue.u16
            }
            registers.writeToggle = !registers.writeToggle
        }
    }

    /// PPUDATA
    var data: UInt8 {
        get { return memory.read(addr: registers.vramAddr) }
        set {
            memory.write(addr: registers.vramAddr, data: newValue)
        }
    }
}
