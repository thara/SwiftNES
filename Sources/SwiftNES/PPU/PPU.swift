private let maxDot: UInt16 = 341
private let maxLine: UInt16 = 261

final class PPU {
    var registers: PPURegisters
    var memory: Memory

    var background: Background
    var spriteOAM: SpriteOAM

    private(set) var frames: UInt = 0

    private let interruptLine: InterruptLine

    var scan: Scan

    var lineBuffer: [UInt32]
    let renderer: Renderer

    init(memory: Memory, interruptLine: InterruptLine, renderer: Renderer) {
        self.registers = PPURegisters()
        self.memory = memory
        self.background = Background()

        self.spriteOAM = SpriteOAM()

        self.scan = Scan()
        self.lineBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)

        self.interruptLine = interruptLine
        self.renderer = renderer
    }

    var renderingEnabled: Bool {
        return registers.mask.contains(.sprite) || registers.mask.contains(.background)
    }

    func step() {
        process()

        switch scan.nextDot() {
        case .line(let last):
            renderer.newLine(number: last, pixels: lineBuffer)
        case .frame(let last):
            renderer.newLine(number: last, pixels: lineBuffer)
            frames += 1
        default:
            break
        }
    }

    func reset() {
        registers.clear()
        memory.clear()
        scan.clear()
        lineBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)
        frames = 0
    }
}

// MARK: - process implementation
extension PPU {

    func process() {
        var preRendering = false

        switch scan.line {
        case 261:
            // Pre Render
            preRendering = true
            fallthrough
        case 0...239:
            // Visible
            updateSprites(preRendering: preRendering)
            updateBackground(preRendering: preRendering)
        case 240:
            // Post Render
            break
        case 241:
            // begin VBLANK
            if scan.dot == 1 {
                registers.status.formUnion(.vblank)
                if registers.controller.contains(.nmi) {
                    interruptLine.send(.NMI)
                }
            }
        default:
            break
        }
    }

    func updateSprites(preRendering: Bool) {
        switch scan.dot {
        case 1:
            if preRendering {
                registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
            }
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

    // swiftlint:disable cyclomatic_complexity
    func updateBackground(preRendering: Bool = false) {
        switch scan.dot {
        case 1:
            background.addressNameTableEntry(using: registers.v)
        case 321:
            // No reload shift
            background.addressNameTableEntry(using: registers.v)
        case 2...255, 322...336:
            updatePixel()

            switch scan.dot % 8 {
            // name table
            case 1:
                background.addressNameTableEntry(using: registers.v)
                background.reloadShift()
            case 2:
                background.fetchNameTableEntry(from: memory)
            // attribute table
            case 3:
                background.addressAttrTableEntry(using: registers.v)
            case 4:
                background.fetchAttrTableEntry(from: memory, v: registers.v)

            // tile bitmap low
            case 5:
                background.addressTileBitmapLow(using: registers.v, controller: registers.controller)
            case 6:
                background.fetchTileBitmapLow(from: memory)
            // tile bitmap high
            case 7:
                background.addressTileBitmapHigh()
            case 0:
                background.fetchTileBitmapHigh(from: memory)
                if renderingEnabled {
                    registers.incrCoarseX()
                }
            default:
                break
            }
        case 256:
            updatePixel()
            background.fetchTileBitmapHigh(from: memory)
            if renderingEnabled {
                registers.incrY()
            }
        case 257:
            updatePixel()
            background.reloadShift()
            if renderingEnabled {
                registers.copyX()
            }
        case 280...304:
            if preRendering && renderingEnabled {
                registers.copyY()
            }
        // Unused name table fetches
        case 337:
            updatePixel()
            background.addressNameTableEntry(using: registers.v)
        case 338:
            background.fetchNameTableEntry(from: memory)
        case 339:
            background.addressNameTableEntry(using: registers.v)
        case 340:
            background.fetchNameTableEntry(from: memory)
            if preRendering && renderingEnabled && frames.isOdd {
                // Skip 0 cycle on visible frame
                scan.skip()
            }
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func updatePixel() {
        defer {
            background.shift()
        }

        let x = scan.dot &- 2

        guard scan.line < NES.height && 0 <= x && x < NES.width else {
            return
        }

        let bg = registers.isEnabledBackground(at: x)
            ? background.getPaletteIndex(fineX: registers.fineX)
            : 0

        let (sprite, spriteAttr, spriteZeroHit) = registers.isEnabledSprite(at: x)
            ? getSprite(x: x, y: scan.line)
            : (0, [], false)

        let idx: Int
        if renderingEnabled {
            switch getPriority(bg: bg, sprite: sprite, spriteAttr: spriteAttr) {
            case .background:
                idx = bg
            case .sprite:
                idx = sprite
                if spriteZeroHit && 0 < bg && x == 0 /* && 0 < sprite && !(0 <= x && x <= 7) && x != 255 && !registers.status.contains(.spriteZeroHit)*/ {
                    registers.status.formUnion(.spriteZeroHit)
                }
            }
        } else {
            idx = 0
        }

        let palleteNo = memory.read(at: UInt16(0x3F00 + idx))
        lineBuffer[x] = palletes[Int(palleteNo)]
    }

    func getPriority(bg: Int, sprite: Int, spriteAttr: SpriteAttribute) -> PixelPriority {
        switch (bg, sprite, spriteAttr.contains(.behindBackground)) {
        case (0, 0, _):
            return .background
        case (0, let p, _) where 0 < p:
            return .sprite
        case (let p, 0, _) where 0 < p:
            return .background
        case (_, _, false):
            return .sprite
        case (_, _, true):
            return .background
        }
    }
}

enum PixelPriority {
    case background, sprite
}

private extension BinaryInteger {
    @inline(__always)
    var isOdd: Bool { return self.magnitude % 2 != 0 }
}
