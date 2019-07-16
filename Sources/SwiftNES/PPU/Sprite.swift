struct Sprite {
    /// Y position of top
    var y: UInt8
    /// Tile index number
    var tileIdx: UInt8
    /// Attributes
    var attr: SpriteAttribute
    /// X position of left
    var x: UInt8
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

let spriteSize: Int = 4
let spriteCount: Int = 64
let spriteLimit: Int = 8

struct SpriteOAM {
    var primary: [UInt8]
    var secondary: [UInt8]
    var sprites: [Sprite]

    init() {
        self.primary = [UInt8](repeating: 0x00, count: spriteSize * spriteCount)
        self.secondary = [UInt8](repeating: 0x00, count: spriteSize * spriteCount)
        self.sprites = [Sprite](repeating: Sprite(y: 0x00, tileIdx: 0x00, attr: [], x: 0x00), count: spriteLimit)
    }

    mutating func clearSecondaryOAM() {
        for i in 0..<secondary.count {
            secondary[i] = 0xFF
        }
    }

    /// the sprite evaluation phase
    mutating func evalSprites() -> Bool {
        var found = 0
        for i in 0..<spriteCount {
            secondary[i] = primary[i]
            found += 1
            if spriteLimit < found {
                return true
            }
        }
        return false
    }

    /// the sprite loading phase
    mutating func loadSprites() {
        for i in stride(from: 0, to: spriteCount, by: spriteSize) {
            sprites[i] = Sprite(
                y: secondary[i],
                tileIdx: secondary[i + 1],
                attr: SpriteAttribute(rawValue: secondary[i + 2]),
                x: secondary[i + 3]
            )
        }
    }
}
