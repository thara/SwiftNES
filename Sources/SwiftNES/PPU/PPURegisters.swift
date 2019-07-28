struct PPURegisters: CustomStringConvertible {
    /// PPUCTRL
    var controller: PPUController = []
    /// PPUMASK
    var mask: PPUMask = []
    /// PPUSTATUS
    var status: PPUStatus = []
    /// OAMADDR
    var objectAttributeMemoryAddress: UInt8 = 0x00

    /// PPUSCROLL
    var scroll: UInt8 = 0x00
    /// PPUADDR
    var address: UInt8 = 0x00

    /// current VRAM address
    var v: UInt16 = 0x00

    /// temporary VRAM address
    var t: UInt16 = 0x00

    /// Fine X scroll
    var fineX: UInt8 = 0x00

    var writeToggle: Bool = false

    var description: String {
        return """
            v:\(v.radix16) \
            t:\(t.radix16) \
            fineX:\(fineX.radix16) \
            w:\(writeToggle) \
            CTRL:\(controller.rawValue.radix2) \
            MASK:\(mask.rawValue.radix2) \
            STATUS:\(status.rawValue.radix2) \
            OAMADDR:\(objectAttributeMemoryAddress.radix16) \
            SCROLL:\(scroll.radix16) \
            ADDR:\(address.radix16)
            """
    }

    mutating func clear() {
        controller = []
        mask = []
        status = []
    }

    mutating func incrV() {
        v &+= controller.vramIncrement
    }

    mutating func writeController(_ value: UInt8) {
        controller = PPUController(rawValue: value)
        t = (t & 0b1111001111111111) | (controller.nameTableSelect << 10)
    }

    mutating func readStatus() -> UInt8 {
        let s = status
        status.remove(.vblank)
        writeToggle = false
        return s.rawValue
    }

    mutating func writeScroll(position: UInt8) {
        if !writeToggle {
            // first write
            t = (t & 0b111111111100000) | ((position & 0b11111000).u16 >> 3)
            fineX = position & 0b111
            writeToggle = true
        } else {
            // second write
            t = (t & 0b1000111111111111) | ((position & 0b111).u16 << 12) | ((position & 0b1111000).u16 << 2)
            writeToggle = false
        }
    }

    mutating func writeVRAMAddress(addr: UInt8) {
        if !writeToggle {
            // first write
            t = (t & 0b1100000011111111) | ((addr & 0b111111).u16 << 8)
            writeToggle = true
        } else {
            // second write
            t = (t & 0b1111111100000000) | addr.u16
            v = t
            writeToggle = false
        }
    }
}

struct PPUController: OptionSet {
    let rawValue: UInt8

    /// NMI
    static let nmi = PPUController(rawValue: 1 << 7)
    /// PPU master/slave (0: master, 1: slave)
    static let slave = PPUController(rawValue: 1 << 6)
    /// Sprite size
    static let spriteSize = PPUController(rawValue: 1 << 5)
    /// Background pattern table address
    static let bgTableAddr = PPUController(rawValue: 1 << 4)
    /// Sprite pattern table address for 8x8 sprites
    static let spriteTableAddr = PPUController(rawValue: 1 << 3)
    /// VRAM address increment
    static let vramAddrIncr = PPUController(rawValue: 1 << 2)
    /// Base nametable address
    static let nameTableAddrHigh = PPUController(rawValue: 1 << 1)
    static let nameTableAddrLow = PPUController(rawValue: 1)

    var nameTableSelect: UInt16 {
        return (rawValue & 0b11).u16
    }

    var bgPatternTableAddrBase: UInt16 {
        return contains(.bgTableAddr) ? 0x1000 : 0x0000
    }

    var baseNameTableAddr: UInt16 {
        let bits = rawValue & 0b0011
        switch bits {
        case 0:
            return 0x2000
        case 1:
            return 0x2400
        case 2:
            return 0x2800
        case 3:
            return 0x2C00
        default:
            fatalError("PPUController.baseNameTableAddr - unexpected bits: \(bits)")
        }
    }

    var baseSpriteTableAddr: UInt16 {
        return contains(.spriteTableAddr) ? 0x1000 : 0x0000
    }

    var vramIncrement: UInt16 {
        return contains(.vramAddrIncr) ? 32 : 1
    }
}

struct PPUMask: OptionSet {
    let rawValue: UInt8

    /// Emphasize blue
    static let blue = PPUMask(rawValue: 1 << 7)
    /// Emphasize green
    static let green = PPUMask(rawValue: 1 << 6)
    /// Emphasize red
    static let red = PPUMask(rawValue: 1 << 5)
    /// Show sprite
    static let sprite = PPUMask(rawValue: 1 << 4)
    /// Show background
    static let background = PPUMask(rawValue: 1 << 3)
    /// Show sprite in leftmost 8 pixels
    static let spriteLeft = PPUMask(rawValue: 1 << 2)
    /// Show background in leftmost 8 pixels
    static let backgroundLeft = PPUMask(rawValue: 1 << 1)
    /// Greyscale
    static let greyscale = PPUMask(rawValue: 1)
}

struct PPUStatus: OptionSet {
    let rawValue: UInt8

    /// In vblank?
    static let vblank = PPUStatus(rawValue: 1 << 7)
    /// Sprite 0 Hit
    static let spriteZeroHit = PPUStatus(rawValue: 1 << 6)
    /// Sprite overflow
    static let spriteOverflow = PPUStatus(rawValue: 1 << 5)
}
