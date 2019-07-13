protocol PPU {
    func step()
}

private let maxDot: UInt16 = 341
private let maxLine: UInt16 = 261

typealias SendNMI = (() -> Void)

class PPUEmulator {
    var registers: PPURegisters

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

    var frames: UInt = 0

    let sendNMI: SendNMI

    var lineBuffer: [UInt8]

    init(sendNMI: @escaping SendNMI) {
        self.registers = PPURegisters()
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
                frames &+= 1
            }
        }
    }
}
