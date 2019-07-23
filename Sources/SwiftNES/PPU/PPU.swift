private let maxDot: UInt16 = 341
private let maxLine: UInt16 = 261

class PPU {
    var registers: PPURegisters
    var memory: Memory
    var background: Background
    var spriteOAM: SpriteOAM

    var frames: UInt = 0

    var interruptLine: InterruptLine

    let lineBuffer: LineBuffer

    init(memory: Memory, interruptLine: InterruptLine, lineBufferFactory: LineBufferFactory) {
        self.registers = PPURegisters()
        self.memory = memory
        self.background = Background()

        self.spriteOAM = SpriteOAM()

        self.lineBuffer = lineBufferFactory.make(pixels: maxDot, lines: maxLine)

        self.interruptLine = interruptLine
    }

    var renderingEnabled: Bool {
        return registers.mask.contains(.sprite) || registers.mask.contains(.background)
    }

    func reset() {
        registers.clear()
        memory.clear()
        lineBuffer.clear()
        frames = 0
    }
}

// MARK: - step implementation
extension PPU {

    enum Scanline {
        case preRender
        case visible
        case postRender
        case verticalBlanking

        init?(lineNumber: Int) {
            switch lineNumber {
            case 261:
                self = .preRender
            case 0...239:
                self = .visible
            case 240:
                self = .postRender
            case 241...260:
                self = .verticalBlanking
            default:
                return nil
            }
        }
    }

    func step() {
        ppuLogger.debug("\(lineBuffer.dot) in line \(lineBuffer.lineNumber)")

        guard let scanline = Scanline(lineNumber: lineBuffer.lineNumber) else {
            fatalError("Unexpected lineNumber")
        }
        process(scanline: scanline)

        lineBuffer.nextDot()
    }
}

// MARK: - process implementation
extension PPU {

    func process(scanline: Scanline) {
        switch scanline {
        case .preRender, .visible:
            let preRendering = scanline == .preRender

            updateSprites(preRendering: preRendering)
            updateBackground(preRendering: preRendering)

            updateLineBuffer()
        case .postRender:
            // Idling
            break
        case .verticalBlanking:
            // VBLANK
            if lineBuffer.dot == 1 {
                registers.status.formUnion(.vblank)
                if registers.controller.contains(.nmi) {
                    interruptLine.send(.NMI)
                }
            }
        }
    }

    func updateSprites(preRendering: Bool) {
        switch lineBuffer.dot {
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
            spriteOAM.loadSprites()
        default:
            break
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func updateBackground(preRendering: Bool = false) {
        switch lineBuffer.dot {
        case 1:
            background.addressNameTableEntry(using: registers.v)
            if preRendering {
                registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
            }
        case 321:
            // No reload shift
            background.addressNameTableEntry(using: registers.v)
        case 2...255, 322...336:
            switch lineBuffer.dot % 8 {
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
                incrCoarseX()
            default:
                break
            }
        case 256:
            background.fetchTileBitmapHigh(from: memory)
            incrY()
        case 257:
            updateHorizontalPosition()
            background.reloadShift()
        case 280...304:
            if preRendering {
                updateVerticalPosition()
            }
        // Unused name table fetches
        case 337:
            background.addressNameTableEntry(using: registers.v)
        case 338:
            background.fetchNameTableEntry(from: memory)
        case 339:
            background.addressNameTableEntry(using: registers.v)
        case 340:
            background.fetchNameTableEntry(from: memory)
            if preRendering && renderingEnabled && frames.isOdd {
                // Skip 0 cycle on visible frame
                lineBuffer.skip()
            }
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func updateLineBuffer() {
        var bg = 0
        if registers.mask.contains(.background) {
            bg = background.getPaletteIndex(fineX: registers.fineX)
        }

        // FIXME set sprite
        let sprite = 0

        var idx = 0

        if renderingEnabled {
            let priority = getRenderingPriority(bg: bg, sprite: sprite, spriteAttr: [])

            switch priority {
            case .background:
                idx = bg
            case .sprite:
                idx = 0
            }
        }

        let palleteNo = memory.read(at: UInt16(0x3F00 + idx))
        lineBuffer.write(pixel: palletes[Int(palleteNo)])
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
