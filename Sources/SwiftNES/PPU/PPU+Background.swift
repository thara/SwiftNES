let nameTableFirst: UInt16 = 0x2000
let attributeTableFirst: UInt16 = 0x23C0
let tileHeight: UInt16 = 8

extension PPU {

    struct BackgroundPixel {
        var enabled: Bool
        var color: Int

        static let zero = BackgroundPixel(enabled: false, color: 0x00)
    }

    // swiftlint:disable cyclomatic_complexity
    func fetchBackgroundPixel() {
        switch scan.dot {
        case 321:
            // No reload shift
            bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
        case 1...255, 322...336:
            switch scan.dot % 8 {
            case 1:
                // Fetch nametable byte : step 1
                bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
                tile.reload(for: nextPattern, with: attrTableEntry)
            case 2:
                // Fetch nametable byte : step 2
                nameTableEntry = bus.read(at: bgTempAddr)
            case 3:
                // Fetch attribute table byte : step 1
                bgTempAddr = attributeTableFirst | registers.v.attributeAddressIndex
            case 4:
                // Fetch attribute table byte : step 2
                attrTableEntry = bus.read(at: bgTempAddr)
                // select area
                if registers.v.coarseXScroll[1] == 1 {
                    attrTableEntry &>>= 2
                }
                if registers.v.coarseYScroll[1] == 1 {
                    attrTableEntry &>>= 4
                }
            case 5:
                // Fetch tile bitmap low byte : step 1
                let base: UInt16 = registers.controller.contains(.bgTableAddr) ? 0x1000 : 0x0000
                let index = nameTableEntry.u16 &* tileHeight &* 2
                bgTempAddr = base &+ index &+ registers.v.fineYScroll.u16
            case 6:
                // Fetch tile bitmap low byte : step 2
                nextPattern.low = bus.read(at: bgTempAddr).u16
            case 7:
                // Fetch tile bitmap high byte : step 1
                bgTempAddr &+= tileHeight
            case 0:
                // Fetch tile bitmap high byte : step 2
                nextPattern.high = bus.read(at: bgTempAddr).u16
                if registers.renderingEnabled {
                    registers.incrCoarseX()
                }
            default:
                break
            }
        case 256:
            nextPattern.high = bus.read(at: bgTempAddr).u16
            if registers.renderingEnabled {
                registers.incrY()
            }
        case 257:
            tile.reload(for: nextPattern, with: attrTableEntry)
            if registers.renderingEnabled {
                registers.copyX()
            }
        case 280...304:
            if scan.line == 261 && registers.renderingEnabled {
                registers.copyY()
            }
        // Unused name table fetches
        case 337, 339:
            bgTempAddr = nameTableFirst | registers.v.nameTableAddressIndex
        case 338, 340:
            nameTableEntry = bus.read(at: bgTempAddr)
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    /// Returns pallete index for fine X
    func getBackgroundPixel(x: Int) -> BackgroundPixel {
        let (pixel, pallete) = tile[registers.fineX]

        if (1 <= scan.dot && scan.dot <= 256) || (321 <= scan.dot && scan.dot <= 336) {
            tile.shift()
        }

        guard registers.isEnabledBackground(at: x) else {
            return .zero
        }
        return BackgroundPixel(
            enabled: pixel != 0,
            color: Int(bus.read(at: 0x3F00 &+ pallete &* 4 &+ pixel)))
    }
}

struct Tile {
    struct Pattern {
        var low: UInt16 = 0x00
        var high: UInt16 = 000

        @inline(__always)
        subscript(n: UInt8) -> UInt16 {
            return (high[n] &<< 1) | low[n]
        }
    }

    struct Attribute {
        var low: UInt8 = 0x00
        var high: UInt8 = 0x00

        /// 1 quadrant of attrTableEntry
        var lowLatch: Bool = false
        var highLatch: Bool = false

        @inline(__always)
        subscript(n: UInt8) -> UInt8 {
            return (high[n] &<< 1) | low[n]
        }
    }

    var currentPattern = Pattern()
    var currentAttribute = Attribute()

    @inline(__always)
    subscript(x: UInt8) -> (pattern: UInt16, pallete: UInt16) {
        // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
        let patternX = 15 &- x
        let pixel = (currentPattern.high[patternX] &<< 1) | currentPattern.low[patternX]

        let attributeX = 7 &- x
        let attr = (currentAttribute.high[attributeX] &<< 1) | currentAttribute.low[attributeX]

        return (pixel, attr.u16)
    }

    @inline(__always)
    mutating func shift() {
        currentPattern.low &<<= 1
        currentPattern.high &<<= 1

        currentAttribute.low = (currentAttribute.low &<< 1) | unsafeBitCast(currentAttribute.lowLatch, to: UInt8.self)
        currentAttribute.high =
            (currentAttribute.high &<< 1) | unsafeBitCast(currentAttribute.highLatch, to: UInt8.self)
    }

    @inline(__always)
    mutating func reload(for next: Pattern, with nextAttribute: UInt8) {
        currentPattern.low = (currentPattern.low & 0xFF00) | next.low
        currentPattern.high = (currentPattern.high & 0xFF00) | next.high
        currentAttribute.lowLatch = nextAttribute[0] == 1
        currentAttribute.highLatch = nextAttribute[1] == 1
    }
}
