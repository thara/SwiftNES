struct PPURegisters {
    /// PPUCTRL
    var controller: PPUController
    /// PPUMASK
    var mask: PPUMask
    /// PPUSTATUS
    var status: PPUStatus
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

struct PPUController: OptionSet {
    let rawValue: UInt8

    /// NMI
    static let nmi = PPUStatus(rawValue: 1 << 7)
    /// PPU master/slave (0: master, 1: slave)
    static let slave = PPUStatus(rawValue: 1 << 6)
    /// Sprite size
    static let spriteSize = PPUStatus(rawValue: 1 << 5)
    /// Background pattern table address
    static let bgTableAddr = PPUStatus(rawValue: 1 << 4)
    /// Sprite pattern table address for 8x8 sprites
    static let spriteTableAddr = PPUStatus(rawValue: 1 << 3)
    /// VRAM address increment
    static let vramAddrIncr = PPUStatus(rawValue: 1 << 2)
    /// Base nametable address
    static let nameTableAddrHigh = PPUStatus(rawValue: 1 << 1)
    static let nameTableAddrLow = PPUStatus(rawValue: 1)

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
    static let blue = PPUStatus(rawValue: 1 << 7)
    /// Emphasize green
    static let green = PPUStatus(rawValue: 1 << 6)
    /// Emphasize red
    static let red = PPUStatus(rawValue: 1 << 5)
    /// Show sprite
    static let sprite = PPUStatus(rawValue: 1 << 4)
    /// Show background
    static let background = PPUStatus(rawValue: 1 << 3)
    /// Show sprite in leftmost 8 pixels
    static let spriteLeft = PPUStatus(rawValue: 1 << 2)
    /// Show background in leftmost 8 pixels
    static let backgroundLeft = PPUStatus(rawValue: 1 << 1)
    /// Greyscale
    static let greyscale = PPUStatus(rawValue: 1)
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
