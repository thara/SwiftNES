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
            defer {
                if scan.dot == 1 {
                    registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
                }
                if scan.dot == 341 && renderingEnabled && frames.isOdd {
                    // Skip 0 cycle on visible frame
                    scan.skip()
                }
            }

            fallthrough
        case 0...239:
            // Visible
            renderPixel()
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

    func renderPixel() {
        let x = scan.dot &- 2

        let bg = getBackgroundPixel(x: x)
        let (sprite, spriteAttr, spriteZeroHit) = getSpritePixel(x: x)

        fetchBackgroundPixel()
        fetchSpritePixel()

        guard scan.line < NES.height && 0 <= x && x < NES.width else {
            return
        }

        let idx = renderingEnabled
            ? selectPalleteIndex(bg: bg, sprite: sprite, spriteAttr: spriteAttr)
            : 0

        if spriteZeroHit && 0 < bg && renderingEnabled {
            registers.status.formUnion(.spriteZeroHit)
        }

        let palleteNo = memory.read(at: UInt16(0x3F00) &+ idx)
        lineBuffer[x] = palletes[Int(palleteNo)]

        background.shift()
    }

    func selectPalleteIndex(bg: UInt16, sprite: UInt16, spriteAttr: SpriteAttribute) -> UInt16 {
        switch (bg, sprite, spriteAttr.contains(.behindBackground)) {
        case (0, 0, _):
            return bg
        case (0, let p, _) where 0 < p:
            return sprite
        case (let p, 0, _) where 0 < p:
            return bg
        case (_, _, false):
            return sprite
        case (_, _, true):
            return bg
        }
    }
}

private extension BinaryInteger {
    @inline(__always)
    var isOdd: Bool { return self.magnitude % 2 != 0 }
}
