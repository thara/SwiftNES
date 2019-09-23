struct Sprite {
    /// Y position of top
    let y: UInt8
    /// Tile index number
    let tileIndex: UInt8
    /// Attributes
    let attr: SpriteAttribute
    /// X position of left
    let x: UInt8

    var valid: Bool {
        return x != 0xFF && y != 0xFF && tileIndex != 0xFF
    }

    func row(lineNumber: Int, spriteHeight: Int) -> UInt16 {
        var row = UInt16(lineNumber) &- y.u16 &- 1
        if attr.contains(.flipVertically) {
            row = UInt16(spriteHeight) &- 1 &- row
        }
        return row
    }

    func col(x: UInt16) -> UInt8 {
        var col = 7 &- (x &- self.x.u16)
        if attr.contains(.flipHorizontally) {
            col = 8 &- 1 &- col
        }
        return UInt8(col)
    }
}

struct SpriteAttribute: OptionSet {
    let rawValue: UInt8

    /// Flip sprite vertically
    static let flipVertically = SpriteAttribute(rawValue: 1 << 7)
    /// Flip sprite horizontally
    static let flipHorizontally = SpriteAttribute(rawValue: 1 << 6)
    /// Priority
    static let behindBackground = SpriteAttribute(rawValue: 1 << 5)

    /// Palette
    static let pallete2 = SpriteAttribute(rawValue: 1 << 1)
    static let pallete1 = SpriteAttribute(rawValue: 1)

    func pallete() -> UInt8 {
        return rawValue & 0b11
    }
}

let spriteCount: Int = 64
let spriteLimit: Int = 8
let oamSize = 4 * spriteCount

struct SpriteOAM {
    var primary: [UInt8]
    var secondary: [UInt8]
    var sprites: [Sprite]

    init() {
        self.primary = [UInt8](repeating: 0x00, count: oamSize)
        self.secondary = [UInt8](repeating: 0x00, count: oamSize)
        self.sprites = [Sprite](repeating: Sprite(y: 0x00, tileIndex: 0x00, attr: [], x: 0x00), count: spriteLimit)
    }
}

protocol SpriteRenderer: class {
    var registers: PPURegisters { get set }
    var memory: Memory { get }

    var oam: SpriteOAM { get set }

    var scan: Scan { get }

    func fetchSpritePixel()
    func getSpritePixel(x: Int) -> (palleteIndex: UInt16, attribute: SpriteAttribute, spriteZero: Bool)
}

extension SpriteRenderer {

    func fetchSpritePixel() {
        switch scan.dot {
        case 1:
            for i in 0..<oamSize {
                oam.secondary[i] = 0xFF
            }
        case 257:
            // the sprite evaluation phase
            let spriteSize = registers.spriteSize
            var n = 0

            for i in 0..<spriteCount {
                let first = i &* 4
                let y = oam.primary[first]
                oam.secondary[first] = y
                if n < spriteLimit {
                    let row = scan.line &- Int(oam.primary[first])
                    guard 0 <= row && row < spriteSize else {
                        continue
                    }
                    oam.secondary[first &+ 1] = oam.primary[first &+ 1]
                    oam.secondary[first &+ 2] = oam.primary[first &+ 2]
                    oam.secondary[first &+ 3] = oam.primary[first &+ 3]

                    n &+= 1
                }
            }

        case 257...320:
            let i = (scan.dot &- 257) / 8
            let n = i &* 4
            oam.sprites[i] = Sprite(
                y: oam.secondary[n],
                tileIndex: oam.secondary[n &+ 1],
                attr: SpriteAttribute(rawValue: oam.secondary[n &+ 2]),
                x: oam.secondary[n &+ 3]
            )
        default:
            break
        }
    }

    func getSpritePixel(x: Int) -> (palleteIndex: UInt16, attribute: SpriteAttribute, spriteZero: Bool) {
        let y = scan.line

        guard registers.isEnabledSprite(at: x) else {
            return (0, [], false)
        }

        for (i, sprite) in oam.sprites.enumerated() {
            guard sprite.valid else {
                break
            }
            guard x &- 7 <= sprite.x && sprite.x <= x else {
                continue
            }

            var row = sprite.row(lineNumber: y, spriteHeight: registers.spriteSize)
            let col = sprite.col(x: UInt16(x))
            var tileIndex = sprite.tileIndex.u16

            let base: UInt16
            if registers.controller.sprite8x16pixels {
                tileIndex &= 0xFE
                if 7 < row {
                    tileIndex += 1
                    row -= 8
                }
                base = tileIndex & 1
            } else {
                base = registers.controller.baseSpriteTableAddr
            }

            let tileAddr = base &+ tileIndex &* 16 &+ row
            let low = memory.read(at: tileAddr)
            let high = memory.read(at: tileAddr &+ 8)

            let pixel = low[col] &+ (high[col] &<< 1)

            if pixel == 0 {
                // transparent
                continue
            }

            return (UInt16(pixel &+ 0x10), sprite.attr, i == 0)   // from 0x3F10
        }

        return (0, [], false)
    }
}
