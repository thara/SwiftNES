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
        case 241...260:
            // VBLANK
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
            spriteOAM.clearSecondaryOAM()
            if preRendering {
                registers.status.remove([.spriteOverflow, .spriteZeroHit])
            }
        case 257:
            if spriteOAM.evalSprites() {
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
            if preRendering {
                registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
            }
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

        let bg = registers.mask.contains(.background)
            ? background.getPaletteIndex(fineX: registers.fineX)
            : 0

        let (sprite, spriteAttr) = registers.mask.contains(.sprite)
            ? spriteOAM.getPalleteIndex(
                x: x, y: scan.line, baseAddr: registers.controller.baseSpriteTableAddr, memory: &memory)
            : (0, [])

        let idx = renderingEnabled
            ? selectPalleteIndex(bg: bg, sprite: sprite, spriteAttr: spriteAttr)
            : 0

        let palleteNo = memory.read(at: UInt16(0x3F00 + idx))
        lineBuffer[x] = palletes[Int(palleteNo)]
    }

    func selectPalleteIndex(bg: Int, sprite: Int, spriteAttr: SpriteAttribute) -> Int {
        switch (bg, sprite, spriteAttr.contains(.behindBackground)) {
        case (1...3, 1...3, true):
            return bg
        case (1...3, 1...3, false):
            return sprite
        case (1...3, _, _):
            return bg
        case (_, 1...3, _):
            return sprite
        default:
            return bg
        }
    }
}

private extension BinaryInteger {
    @inline(__always)
    var isOdd: Bool { return self.magnitude % 2 != 0 }
}
