let startVerticalBlank = 241

final class PPU {
    var registers = PPURegisters()
    var bus: Memory

    // Background registers
    var nameTableEntry: UInt8 = 0x00
    var attrTableEntry: UInt8 = 0x00
    var bgTempAddr: UInt16 = 0x00

    /// Background tiles
    var tile = Tile()
    var nextPattern = Tile.Pattern()

    // Sprite OAM
    var primaryOAM = [UInt8](repeating: 0x00, count: oamSize)
    var secondaryOAM = [UInt8](repeating: 0x00, count: 32)
    var sprites = [Sprite](repeating: .defaultValue, count: spriteLimit)
    var spriteZeroOnLine = false

    var frames: UInt = 0
    var scan = Scan()

    // http://wiki.nesdev.com/w/index.php/PPU_registers#Ports
    var internalDataBus: UInt8 = 0x00

    init(bus: Memory) {
        self.bus = bus
    }

    var line: Int {
        return scan.line
    }

    func step(writeTo lineBuffer: inout LineBuffer, interruptLine: InterruptLine) {
        switch scan.line {
        case 261:
            // Pre Render
            defer {
                if scan.dot == 1 {
                    registers.status.remove([.vblank, .spriteZeroHit, .spriteOverflow])
                }
                if scan.dot == 341 && registers.renderingEnabled && frames.isOdd {
                    // Skip 0 cycle on visible frame
                    scan.skip()
                }
            }

            fallthrough
        case 0...239:
            // Visible
            renderPixel(to: &lineBuffer)
        case 240:
            // Post Render
            break
        case startVerticalBlank:
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

        switch scan.nextDot() {
        case .frame:
            frames += 1
        default:
            break
        }
    }

    func reset() {
        registers.clear()
        bus.clear()
        scan.clear()
        frames = 0
    }
}

// MARK: - Pixel Rendering
extension PPU {

    func renderPixel(to lineBuffer: inout LineBuffer) {
        let x = scan.dot &- 2

        let bg = getBackgroundPixel(x: x)
        let sprite = getSpritePixel(x: x, background: bg)

        if registers.renderingEnabled {
            fetchBackgroundPixel()
            fetchSpritePixel()
        }

        guard scan.line < NES.maxLine && 0 <= x && x < NES.width else {
            return
        }

        let pixel = registers.renderingEnabled ? selectPixel(bg: bg, sprite: sprite) : 0
        lineBuffer.write(pixel, bg.color, sprite.color, at: x)
    }

    func selectPixel(bg: BackgroundPixel, sprite: SpritePixel) -> Int {
        switch (bg.enabled, sprite.enabled) {
        case (false, false):
            return Int(bus.read(at: 0x3F00))
        case (false, true):
            return sprite.color
        case (true, false):
            return bg.color
        case (true, true):
            return sprite.priority ? bg.color : sprite.color
        }
    }
}

extension BinaryInteger {
    @inline(__always)
    fileprivate var isOdd: Bool { return self.magnitude % 2 != 0 }
}
