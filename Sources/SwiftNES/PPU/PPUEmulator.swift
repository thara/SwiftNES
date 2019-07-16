private let maxDot: UInt16 = 341
private let maxLine: UInt16 = 261

typealias SendNMI = (() -> Void)

class PPUEmulator: PPU {

    var registers: PPURegisters
    var memory: Memory
    var background: Background
    var spriteOAM: SpriteOAM

    // MARK: - Rendering counters
    var dot: UInt16 = 0
    var lineNumber: UInt16 = 0

    var frames: UInt = 0

    let sendNMI: SendNMI

    var lineBuffer: [UInt8]

    init(sendNMI: @escaping SendNMI) {
        self.registers = PPURegisters()
        self.memory = PPUAddressSpace()
        self.background = Background()

        self.spriteOAM = SpriteOAM()

        self.lineBuffer = [UInt8](repeating: 0x00, count: Int(maxDot))

        self.sendNMI = sendNMI
    }
}

// MARK: - step implementation
extension PPUEmulator {

    enum Scanline {
        case preRender
        case visible
        case postRender
        case verticalBlanking

        init?(lineNumber: UInt16) {
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
        guard let scanline = Scanline(lineNumber: lineNumber) else {
            fatalError("Unexpected lineNumber")
        }
        process(scanline: scanline)

        dot += 1
        if maxDot <= dot {
            dot %= 341
            lineNumber += 1
            if maxLine < lineNumber {
                lineNumber = 0
                frames &+= 1
            }
        }
    }
}

// MARK: - process implementation
extension PPUEmulator {

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
            if dot == 1 {
                registers.status.formUnion(.vblank)
                if registers.controller.contains(.nmi) {
                    sendNMI()
                }
            }
        }
    }

    func updateSprites(preRendering: Bool) {
        switch dot {
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
        switch dot {
        case 1:
            background.addressNameTableEntry(using: registers.v)
            if preRendering {
                registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
            }
        case 321:
            // No reload shift
            background.addressNameTableEntry(using: registers.v)
        case 2...255, 322...336:
            switch dot % 8 {
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
                dot += 1
            }
        default:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func updateLineBuffer() {
        // let bgPixel: UInt8 = 0
        // if registers.mask.contains(.background) {

        // }
        // let paletteIdx = 
        // let color = memory.read(addr: 0x3F00 + paletteIdx)
        // lineBuffer[dot] = pallete[Int(color)]
    }

    func getRenderingPriority(bgPixel: UInt8, spritePixel: UInt8, sprite: Sprite) -> RenderingPriority {
        switch (1 <= bgPixel && bgPixel <= 3, 1 <= spritePixel && spritePixel <= 3, sprite.attr.contains(.behindBackground)) {
        case (false, false, _):
            return .background
        case (false, true, _):
            return .sprite
        case (true, false, _):
            return .background
        case (true, true, false):
            return .sprite
        case (true, true, true):
            return .background
        }
    }
}

enum RenderingPriority {
    case background, sprite
}
