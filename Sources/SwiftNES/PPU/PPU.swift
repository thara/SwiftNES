protocol PPU {
    func step()
}

private let maxDot: UInt16 = 341
private let maxLine: UInt16 = 261

typealias SendNMI = (() -> Void)

class PPUEmulator {
    var registers: PPURegisters

    var latch: Bool = false
    var memory: Memory
    let oam: Memory

    var currentAddress: UInt16 = 0x00
    var scrollPosition: ScrollPosition = ScrollPosition(x: 0x00, y: 0x00)

    // MARK: - Rendering counters
    var dot: UInt16 = 0
    var lineNumber: UInt16 = 0

    let sendNMI: SendNMI

    init(memory: Memory, sendNMI: @escaping SendNMI) {
        registers = PPURegisters(
            controller: [],
            mask: [],
            status: [],
            objectAttributeMemoryAddress: 0x00,
            scroll: 0x00,
            address: 0x00
        )
        self.memory = memory
        self.oam = RAM(data: 0x00, count: 4 * 64)
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
