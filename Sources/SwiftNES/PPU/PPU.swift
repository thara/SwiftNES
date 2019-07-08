protocol PPU {
    func step()
}

private let maxDot: UInt16 = 341
private let maxLine: UInt16 = 261

typealias SendNMI = (() -> Void)

class PPUEmulator {
    var registers: PPURegisters

    var currentAddress: UInt16 = 0x00
    var scrollPosition: ScrollPosition = ScrollPosition(x: 0x00, y: 0x00)
    var latch: Bool = false

    var memory: Memory

    var background: Background

    /// Primary OAM
    var oam: [UInt8]
    /// Secondary OAM
    var secondaryOAM: [UInt8]
    /// Sprites
    var sprites: [Sprite]

    // MARK: - Rendering counters
    var dot: UInt16 = 0
    var lineNumber: UInt16 = 0

    let sendNMI: SendNMI

    var lineBuffer: [UInt8]

    init(sendNMI: @escaping SendNMI) {
        registers = PPURegisters(
            controller: [],
            mask: [],
            status: [],
            objectAttributeMemoryAddress: 0x00,
            scroll: 0x00,
            address: 0x00
        )
        self.memory = PPUAddressSpace()
        self.background = Background()

        self.oam = [UInt8](repeating: 0x00, count: spriteSize * spriteCount)
        self.secondaryOAM = [UInt8](repeating: 0x00, count: spriteSize * spriteCount)
        self.sprites = [Sprite](repeating: Sprite(y: 0x00, tileIdx: 0x00, attr: [], x: 0x00), count: spriteLimit)

        self.lineBuffer = [UInt8](repeating: 0x00, count: Int(maxDot))

        self.sendNMI = sendNMI
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
                //TODO frame odd
            }
        }
    }
}

struct ScrollPosition {
    var x: UInt8
    var y: UInt8

    mutating func reset() {
        x = 0x00
        y = 0x00
    }
}
