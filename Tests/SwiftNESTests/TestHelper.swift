@testable import SwiftNES

func vramAddress(fineYScroll: UInt16 = 0, nameTableNo: UInt16, coarseYScroll: UInt16, coarseXScroll: UInt16) -> UInt16 {
    return (fineYScroll << 12) | (nameTableNo << 10) | (coarseYScroll << 5) | coarseXScroll
}

class DummyRenderer: Renderer {
    func newLine(number: Int, pixels: [UInt32]) {}
}

extension CPU {
    convenience init() {
        self.init(memory: [UInt8](repeating: 0x00, count: 65536), interruptLine: InterruptLine())
    }
}

extension PPU {
    convenience init() {
        self.init(memory: [UInt8](repeating: 0x00, count: 65534), interruptLine: InterruptLine())
    }

    convenience init(memory: Memory) {
        self.init(memory: memory, interruptLine: InterruptLine())
    }
}

extension Cartridge {
    convenience init(rawData: [UInt8]) {
        self.init(mapper: DummyMapper(rawData: rawData))
    }
}

class DummyMapper: Mapper {

    var ram: [UInt8]
    var program: [UInt8] = []
    var characterData: [UInt8] = []

    var mirroring: Mirroring = .vertical

    init(rawData: [UInt8]) {
        ram = rawData
    }

    func read(at address: UInt16) -> UInt8 {
        return ram.read(at: address)
    }

    func write(_ value: UInt8, at address: UInt16) {
        ram.write(value, at: address)
    }
}
