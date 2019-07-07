
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
        case .preRender:
            registers.status.remove(.vblank)
            // Prepare line 0 rendering
            fallthrough
        case .visible:
            // Sprites
            // Background
            break
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
}
