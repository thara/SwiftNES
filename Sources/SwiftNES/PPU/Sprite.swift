let spriteCount: Int = 64
let spriteLimit: Int = 8
let oamSize = 4 * spriteCount

struct Sprite {
    /// Y position of top
    let y: UInt8
    /// Tile index number
    let tileIndex: UInt8
    /// Attributes
    let attr: SpriteAttribute
    /// X position of left
    let x: UInt8

    static let defaultValue = Sprite(y: 0x00, tileIndex: 0x00, attr: [], x: 0x00)

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

    static let flipVertically = SpriteAttribute(rawValue: 1 << 7)
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
