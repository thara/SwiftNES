let spriteSize: Int = 4
let spriteCount: Int = 64
let spriteLimit: Int = 8

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

extension PPUEmulator {

    func clearSecondaryOAM() {
        for i in 0..<secondaryOAM.count {
            secondaryOAM[i] = 0xFF
        }
    }

    /// the sprite evaluation phase
    func evalSprites() {
        var found = 0
        for i in 0..<spriteCount {
            secondaryOAM[i] = oam[i]
            found += 1
            if spriteLimit < found {
                registers.status.formUnion(.spriteOverflow)
                break
            }
        }
    }

    /// the sprite loading phase
    func loadSprites() {
        for i in stride(from: 0, to: spriteCount, by: spriteSize) {
            sprites[i] = Sprite(
                y: secondaryOAM[i],
                tileIdx: secondaryOAM[i + 1],
                attr: SpriteAttribute(rawValue: secondaryOAM[i + 2]),
                x: secondaryOAM[i + 3]
            )
        }
    }
}
