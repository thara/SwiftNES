struct Sprite {
    /// Y position of top
    let y: UInt8
    /// Tile index number
    let tileIdx: UInt8
    /// Attributes
    let attr: SpriteAttribute
    /// X position of left
    let x: UInt8

    var valid: Bool {
        return y != 0xFF && tileIdx != 0xFF && attr != [] && x != 0xFF
    }

    func row(lineNumber: Int) -> UInt16 {
        var row = lineNumber - Int(y) - 1
        if attr.contains(.flipVertically) {
            row = 8 - 1 - row
        }
        return UInt16(row)
    }

    func col(x: Int) -> UInt8 {
        var col = 7 - (x &- Int(self.x))
        if attr.contains(.flipHorizontally) {
            col = 8 - 1 - col
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

let spriteSize: Int = 4
let spriteCount: Int = 64
let spriteLimit: Int = 8
let oamSize = spriteSize * spriteCount

struct SpriteOAM {
    var primary: [UInt8]
    var secondary: [UInt8]
    var sprites: [Sprite]

    init() {
        self.primary = [UInt8](repeating: 0x00, count: oamSize)
        self.secondary = [UInt8](repeating: 0x00, count: oamSize)
        self.sprites = [Sprite](repeating: Sprite(y: 0x00, tileIdx: 0x00, attr: [], x: 0x00), count: spriteLimit)
    }

    mutating func clearSecondaryOAM() {
        for i in 0..<oamSize {
            secondary[i] = 0xFF
        }
    }

    /// the sprite evaluation phase
    mutating func evalSprites() -> Bool {
        var n = 0
        for i in 0..<spriteCount {
            let s = i &* spriteSize

            let y = primary[s]
            if 0 <= y && y < 8 {
                secondary[s..<(s &+ spriteSize)] = primary[s..<(s &+ spriteSize)]
                n &+= 1

                if spriteLimit < n {
                    return true
                }
            }
        }
        return false
    }

    /// the sprite fetch phase
    mutating func fetchSprites() {
        for i in 0..<spriteLimit {
            let n = i &* spriteSize
            sprites[i] = Sprite(
                y: secondary[n],
                tileIdx: secondary[n + 1],
                attr: SpriteAttribute(rawValue: secondary[n + 2]),
                x: secondary[n + 3]
            )
        }
    }
}
