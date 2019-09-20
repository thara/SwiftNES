struct Sprite {
    /// Y position of top
    let y: UInt8
    /// Tile index number
    let tileIdx: UInt8
    /// Attributes
    let attr: SpriteAttribute
    /// X position of left
    let x: UInt8

    let zero: Bool

    var valid: Bool {
        return y != 0xFF && tileIdx != 0xFF && x != 0xFF
    }

    func row(lineNumber: Int) -> UInt16 {
        var row = UInt16(lineNumber) &- y.u16 &- 1
        if attr.contains(.flipVertically) {
            row = 8 &- 1 &- row
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
        self.sprites = [Sprite](repeating: Sprite(y: 0x00, tileIdx: 0x00, attr: [], x: 0x00, zero: false), count: spriteLimit)
    }

    mutating func clearSecondaryOAM() {
        for i in 0..<oamSize {
            secondary[i] = 0xFF
        }
    }

    /// the sprite evaluation phase
    mutating func evalSprites(line: Int, registers: inout PPURegisters) -> Bool {
        let spriteSize = registers.spriteSize

        var found = 0
        for i in 0..<spriteCount {
            let y = i &* 4
            secondary[y] = primary[y]

            let row = line &- Int(primary[y])
            guard 0 <= row && row < spriteSize else {
                continue
            }

            found &+= 1

            if found <= spriteLimit {
                secondary[y &+ 1] = primary[y &+ 1]
                secondary[y &+ 2] = primary[y &+ 2]
                secondary[y &+ 3] = primary[y &+ 3]
            }
        }

        return spriteLimit < found
    }

    /// the sprite fetch phase
    mutating func fetchSprites() {
        for i in 0..<spriteLimit {
            let n = i &* 4
            sprites[i] = Sprite(
                y: secondary[n],
                tileIdx: secondary[n &+ 1],
                attr: SpriteAttribute(rawValue: secondary[n &+ 2]),
                x: secondary[n &+ 3],
                zero: i == 0
            )
        }
    }
}

protocol SpriteRenderer: class {
    var registers: PPURegisters { get set }
    var memory: Memory { get }

    var spriteOAM: SpriteOAM { get set }

    var scan: Scan { get }

    func fetchSpritePixel()
    func getSpritePixel(x: Int) -> (palleteIndex: UInt16, attribute: SpriteAttribute, spriteZero: Bool)
}

extension SpriteRenderer {

    func fetchSpritePixel() {
        switch scan.dot {
        case 1:
            spriteOAM.clearSecondaryOAM()
        case 257:
            if spriteOAM.evalSprites(line: scan.line, registers: &registers) {
                registers.status.formUnion(.spriteOverflow)
            }
        case 321:
            spriteOAM.fetchSprites()
        default:
            break
        }
    }

    func getSpritePixel(x: Int) -> (palleteIndex: UInt16, attribute: SpriteAttribute, spriteZero: Bool) {
        let y = scan.line

        guard registers.isEnabledSprite(at: x) else {
            return (0, [], false)
        }

        let base = registers.controller.baseSpriteTableAddr

        for sprite in spriteOAM.sprites {
            guard sprite.valid else {
                break
            }
            guard x &- 7 <= sprite.x && sprite.x <= x else {
                continue
            }

            let row = sprite.row(lineNumber: y)
            let col = sprite.col(x: UInt16(x))

            let tileAddr = base &+ sprite.tileIdx.u16 &* 16 &+ row
            let low = memory.read(at: tileAddr)
            let high = memory.read(at: tileAddr &+ 8)

            let pixel = low[col] &+ (high[col] &<< 1)

            if pixel == 0 {
                // transparent
                continue
            }

            return (UInt16(pixel &+ 0x10), sprite.attr, sprite.zero)   // from 0x3F10
        }

        return (0, [], false)
    }
}
