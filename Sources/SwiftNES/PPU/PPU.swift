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
    let lineBuffer: LineBuffer

    init(memory: Memory, interruptLine: InterruptLine, renderer: Renderer) {
        self.registers = PPURegisters()
        self.memory = memory
        self.background = Background()

        self.spriteOAM = SpriteOAM()

        self.scan = Scan()
        self.lineBuffer = LineBuffer(renderer: renderer)

        self.interruptLine = interruptLine
    }

    var renderingEnabled: Bool {
        return registers.mask.contains(.sprite) || registers.mask.contains(.background)
    }

    func step() {
        ppuLogger.trace("Dot \(scan) \(registers)")

        process()

        switch scan.nextDot() {
        case .line(let last):
            lineBuffer.flush(lineNumber: last)
        case .frame(let last):
            lineBuffer.flush(lineNumber: last)
            frames += 1
        default:
            break
        }
    }

    func reset() {
        registers.clear()
        memory.clear()
        scan.clear()
        lineBuffer.clear()
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
                ppuLogger.trace("Name table: address v=\(registers.v.nameTableIdx.radix16) t=\(registers.t.nameTableIdx.radix16)")
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
                ppuLogger.trace("VRAM[\(registers.v.radix16)] tile bitmap low: \(scan)")
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
            ? getSpritePalleteIndex(x: x)
            : (0, [])

        var idx = 0
        if renderingEnabled {
            let priority = getRenderingPriority(bg: bg, sprite: sprite, spriteAttr: spriteAttr)

            switch priority {
            case .background:
                idx = bg
            case .sprite:
                idx = sprite
            }
        }
        ppuLogger.trace("updatePixel: \(idx) \(scan)")

        let palleteNo = memory.read(at: UInt16(0x3F00 + idx))
        lineBuffer.write(pixel: palletes[Int(palleteNo)], at: x)
    }

    func getSpritePalleteIndex(x: Int) -> (Int, SpriteAttribute) {

        let baseSpriteTableAddr = registers.controller.baseSpriteTableAddr

        for sprite in spriteOAM.sprites {
            guard sprite.valid else {
                break
            }
            guard x &- 7 <= sprite.x && sprite.x <= x else {
                continue
            }

            let row = sprite.row(lineNumber: scan.line)
            let col = sprite.col(x: x)

            let tileAddr = baseSpriteTableAddr &+ sprite.tileIdx.u16 &* 16 &+ row
            let low = memory.read(at: tileAddr)
            let high = memory.read(at: tileAddr + 8)

            let pixel = low[col] &+ (high[col] &<< 1)

            if pixel == 0 {
                // transparent
                continue
            }

            return (Int(pixel + 0x10), sprite.attr)   // from 0x3F10
        }

        return (0, [])
    }

    func getRenderingPriority(bg: Int, sprite: Int, spriteAttr: SpriteAttribute) -> RenderingPriority {
        switch (bg, sprite, spriteAttr.contains(.behindBackground)) {
        case (1...3, 1...3, true):
            return .background
        case (1...3, 1...3, false):
            return .sprite
        case (1...3, _, _):
            return .background
        case (_, 1...3, _):
            return .background
        default:
            return .background
        }
    }
}

private extension BinaryInteger {
    @inline(__always)
    var isOdd: Bool { return self.magnitude % 2 != 0 }
}

enum RenderingPriority {
    case background, sprite
}
