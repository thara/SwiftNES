@testable import SwiftNES

func vramAddress(fineYScroll: UInt16 = 0, nameTableNo: UInt16, coarseYScroll: UInt16, coarseXScroll: UInt16) -> UInt16 {
    return (fineYScroll << 12) | (nameTableNo << 10) | (coarseYScroll << 5) | coarseXScroll
}

class DummyRenderer: Renderer {
    func renderLine(number: Int, pixels: [UInt32]) {}
}

extension CPUEmulator {
    convenience init() {
        self.init(memory: RAM(data: 0x00, count: 65536))
    }
}

extension PPUEmulator {
    convenience init() {
        self.init(memory: RAM(data: 0x00, count: 65534), renderer: DummyRenderer(), sendNMI: {})
    }

    convenience init(sendNMI: @escaping SendNMI) {
        self.init(memory: RAM(data: 0x00, count: 65534), renderer: DummyRenderer(), sendNMI: sendNMI)
    }

    convenience init(memory: Memory) {
        self.init(memory: memory, renderer: DummyRenderer(), sendNMI: {})
    }
}

extension Cartridge {
    convenience init(rawData: [UInt8]) {
        self.init()
        self.load(rawData: rawData)
    }
}
