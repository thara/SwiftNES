struct PPURegisters {
    /// PPUCTRL
    var controller: PPUController = []
    /// PPUMASK
    var mask: PPUMask = []
    /// PPUSTATUS
    var status: PPUStatus = []
    /// PPUDATA
    var data: UInt8 = 0x00
    /// OAMADDR
    var objectAttributeMemoryAddress: UInt8 = 0x00

    /// current VRAM address
    var v: UInt16 = 0x00
    /// temporary VRAM address
    var t: UInt16 = 0x00
    /// Fine X scroll
    var fineX: UInt8 = 0x00
    var writeToggle: Bool = false

    mutating func clear() {
        controller = []
        mask = []
        status = []
        data = 0x00
    }

    var spriteSize: Int {
        return controller.contains(.spriteSize) ? 16 : 8
    }

    var renderingEnabled: Bool {
        return mask.contains(.sprite) || mask.contains(.background)
    }

    func isEnabledBackground(at x: Int) -> Bool {
        return mask.contains(.background) && !(x < 8 && !mask.contains(.backgroundLeft))
    }

    func isEnabledSprite(at x: Int) -> Bool {
        return mask.contains(.sprite) && !(x < 8 && !mask.contains(.spriteLeft))
    }

    mutating func incrV() {
        v &+= controller.vramIncrement
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242000_write
    mutating func writeController(_ d: UInt8) {
        controller = PPUController(rawValue: d)
        // t: ...BA.. ........ = d: ......BA
        t = (t & ~0b0001100_00000000) | (controller.nameTableSelect << 10)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242002_read
    mutating func readStatus() -> UInt8 {
        let s = status
        status.remove(.vblank)
        writeToggle = false
        return s.rawValue
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242005_first_write_.28w_is_0.29
    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242005_second_write_.28w_is_1.29
    mutating func writeScroll(position d: UInt8) {
        if !writeToggle {
            // first write
            // t: ....... ...HGFED = d: HGFED...
            // x:              CBA = d: .....CBA
            t = (t & ~0b0000000_00011111) | ((d & 0b11111000).u16 >> 3)
            fineX = d & 0b111
            writeToggle = true
        } else {
            // second write
            // t: CBA..HG FED..... = d: HGFEDCBA
            t = (t & ~0b1110011_11100000) | ((d & 0b111).u16 << 12) | ((d & 0b11111000).u16 << 2)
            writeToggle = false
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242006_first_write_.28w_is_0.29
    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242006_second_write_.28w_is_1.29
    mutating func writeVRAMAddress(addr d: UInt8) {
        if !writeToggle {
            // first write
            // t: .FEDCBA ........ = d: ..FEDCBA
            // t: X...... ........ = 0
            t = (t & ~0b0111111_00000000) | ((d & 0b111111).u16 << 8)
            writeToggle = true
        } else {
            // second write
            // t: ....... HGFEDCBA = d: HGFEDCBA
            // v                   = t
            t = (t & ~0b0000000_11111111) | d.u16
            v = t
            writeToggle = false
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#Coarse_X_increment
    mutating func incrCoarseX() {
        if v.coarseXScroll == 31 {
            v &= ~0b11111  // coarse X = 0
            v ^= 0x0400  // switch horizontal nametable
        } else {
            v &+= 1
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#Y_increment
    mutating func incrY() {
        if v.fineYScroll < 7 {
            v &+= 0x1000
        } else {
            v &= ~0x7000  // fine Y = 0

            var y = v.coarseYScroll
            if y == 29 {
                y = 0
                v ^= 0x0800  // switch vertical nametable
            } else if y == 31 {
                y = 0
            } else {
                y &+= 1
            }

            v = (v & ~0x03E0) | (y &<< 5)
        }
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#At_dot_257_of_each_scanline
    mutating func copyX() {
        // v: ....F.. ...EDCBA = t: ....F.. ...EDCBA
        v = (v & ~0b100_00011111) | (t & 0b100_00011111)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#During_dots_280_to_304_of_the_pre-render_scanline_.28end_of_vblank.29
    mutating func copyY() {
        // v: IHGF.ED CBA..... = t: IHGF.ED CBA.....
        v = (v & ~0b1111011_11100000) | (t & 0b1111011_11100000)
    }

    var backgroundPatternTableAddrBase: UInt16 {
        return controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
    }
}

struct PPUController: OptionSet {
    let rawValue: UInt8

    /// NMI
    static let nmi = PPUController(rawValue: 1 << 7)

    // swiftlint:disable inclusive_language
    /// PPU master/slave (0: master, 1: slave)
    static let slave = PPUController(rawValue: 1 << 6)
    // swiftlint:enable inclusive_language

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
        switch nameTableSelect {
        case 0:
            return 0x2000
        case 1:
            return 0x2400
        case 2:
            return 0x2800
        case 3:
            return 0x2C00
        default:
            fatalError("PPUController.baseNameTableAddr - unexpected bits: \(nameTableSelect)")
        }
    }

    var baseSpriteTableAddr: UInt16 {
        return contains(.spriteTableAddr) ? 0x1000 : 0x0000
    }

    var sprite8x16pixels: Bool {
        return contains(.spriteSize)
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
