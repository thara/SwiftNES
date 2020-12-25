let spriteCount: Int = 64
let spriteLimit: Int = 8
let oamSize = 4 * spriteCount

extension PPU {
    struct SpritePixel {
        var enabled: Bool
        var color: Int
        var priority: Bool

        static let zero = SpritePixel(enabled: false, color: 0x00, priority: true)
    }

    func fetchSpritePixel() {
        switch scan.dot {
        case 0:
            secondaryOAM.fill(0xFF)
            spriteZeroOnLine = false

            // the sprite evaluation phase
            let spriteSize = registers.controller.contains(.spriteSize) ? 16 : 8

            var n = 0
            secondaryOAM.withUnsafeMutableBufferPointer { b in
                var p = b.baseAddress!
                let last = p + b.count

                for i in 0..<spriteCount {
                    let first = i &* 4
                    let y = primaryOAM[first]

                    if last - p <= b.count {
                        let row = scan.line &- Int(primaryOAM[first])
                        guard 0 <= row && row < spriteSize else {
                            continue
                        }
                        if n == 0 {
                            spriteZeroOnLine = true
                        }

                        p.pointee = y
                        p += 1
                        p.pointee = primaryOAM[first &+ 1]
                        p += 1
                        p.pointee = primaryOAM[first &+ 2]
                        p += 1
                        p.pointee = primaryOAM[first &+ 3]
                        p += 1

                        n &+= 1
                    }
                }
            }
            if spriteLimit <= n && registers.renderingEnabled {
                registers.status.formUnion(.spriteOverflow)
            }
        case 257...320:
            // the sprite fetch phase
            let i = (scan.dot &- 257) / 8
            let n = i &* 4
            sprites[i] = Sprite(
                y: secondaryOAM[n],
                tileIndex: secondaryOAM[n &+ 1],
                attr: Sprite.Attribute(rawValue: secondaryOAM[n &+ 2]),
                x: secondaryOAM[n &+ 3]
            )
        default:
            break
        }
    }

    func getSpritePixel(x: Int, background bg: BackgroundPixel) -> SpritePixel {
        guard registers.isEnabledSprite(at: x) else {
            return .zero
        }

        let y = scan.line
        for (i, sprite) in sprites.enumerated() {
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
            if pixel == 0 {  // transparent
                continue
            }

            if i == 0
                && spriteZeroOnLine
                && registers.renderingEnabled
                && !registers.status.contains(.spriteZeroHit)
                && sprite.x != 0xFF && x < 0xFF
                && bg.enabled
            {
                registers.status.formUnion(.spriteZeroHit)
            }

            return SpritePixel(
                enabled: pixel != 0,
                color: Int(memory.read(at: 0x3F10 &+ sprite.attr.pallete.u16 &* 4 &+ pixel.u16)),
                priority: sprite.attr.contains(.behindBackground))
        }
        return .zero
    }
}

struct Sprite {
    struct Attribute: OptionSet {
        let rawValue: UInt8

        static let flipVertically = Attribute(rawValue: 1 << 7)
        static let flipHorizontally = Attribute(rawValue: 1 << 6)
        /// Priority
        static let behindBackground = Attribute(rawValue: 1 << 5)

        /// Palette
        static let pallete2 = Attribute(rawValue: 1 << 1)
        static let pallete1 = Attribute(rawValue: 1)

        var pallete: UInt8 {
            return rawValue & 0b11
        }
    }

    /// Y position of top
    let y: UInt8
    /// Tile index number
    let tileIndex: UInt8
    /// Attributes
    let attr: Attribute
    /// X position of left
    let x: UInt8

    static let defaultValue = Sprite(y: 0x00, tileIndex: 0x00, attr: [], x: 0x00)

    var valid: Bool {
        return !(x == 0xFF && y == 0xFF && tileIndex == 0xFF && attr.rawValue == 0xFF)
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
