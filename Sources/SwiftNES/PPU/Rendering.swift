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
