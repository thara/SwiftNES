struct PPURegisters {
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
    var vramAddr: UInt16 = 0x00
    /// temporary VRAM address
    var tempAddr: UInt16 = 0x00
    /// Fine X scroll
    var fineX: UInt8 = 0x00

    var writeToggle: Bool = false

    mutating func readStatus() -> UInt8 {
        let s = status
        status.remove(.vblank)
        writeToggle = false
        return s.rawValue
    }

    mutating func writeScroll(position: UInt8) {
        if !writeToggle {
            tempAddr = (tempAddr & 0b111111111100000) | position.coarseX.u16
        } else {
            tempAddr = (tempAddr & 0b111110000011111) | (position.u16 << 5)
            fineX = position & 0b111
        }
        writeToggle = !writeToggle
    }

    mutating func writeVRAMAddress(addr: UInt8) {
        if !writeToggle {
            tempAddr = addr.u16 << 8 | (tempAddr & 0x00FF)
        } else {
            tempAddr = (tempAddr & 0xFF00) | addr.u16
            vramAddr = tempAddr
        }
        writeToggle = !writeToggle
    }
}

/// Extension for VRAM address
extension BinaryInteger {

    var nameTableIdx: UInt16 {
        return UInt16(self & Self(0b111111111111))
    }

    var coarseX: Self {
        return self & Self(0b11111)
    }

    var coarseXScroll: Self {
        return self & Self(0b11111)
    }

    /// Translate index of attribute table from name table
    var attrX: Self {
        return coarseX / 4
    }

    var coarseY: Self {
        return self & Self(0b1111100000)
    }

    var coarseYScroll: Self {
        return coarseY >> 5
    }

    /// Translate index of attribute table from name table
    var attrY: Self {
        return coarseYScroll / 4
    }

    var nameTableSelect: Self {
        return self & Self(0b110000000000)
    }

    var fineYScroll: UInt8 {
        return UInt8(self & Self(0b111000000000000) >> 12)
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
