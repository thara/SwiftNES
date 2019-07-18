@testable import SwiftNES

func vramAddress(fineYScroll: UInt16 = 0, nameTableNo: UInt16, coarseYScroll: UInt16, coarseXScroll: UInt16) -> UInt16 {
    return (fineYScroll << 12) | (nameTableNo << 10) | (coarseYScroll << 5) | coarseXScroll
}

class DummyRenderer: Renderer {
    func render(line: [UInt8]) {}
}

extension CPUEmulator {
    convenience init() {
        self.init(bus: CPUBus())
    }
}

extension PPUEmulator {
    convenience init(sendNMI: @escaping SendNMI) {
        self.init(renderer: DummyRenderer(), sendNMI: sendNMI)
    }
}

extension Cartridge {
    convenience init(rawData: [UInt8]) {
        self.init()
        self.load(rawData: rawData)
    }
}
