import Foundation

protocol Memory {
    func read(addr: UInt16) -> UInt8
    func write(addr: UInt16, data: UInt8)

    func readWord(addr: UInt16) -> UInt16
}

extension Memory {
    func readWord(addr: UInt16) -> UInt16 {
        return UInt16(read(addr: addr)) | (UInt16(read(addr: addr + 1)) << 8)
    }
}

class AddressSpace: Memory {
    private var memory: NSMutableArray
    private var wram: WRAM

    init() {
        memory = NSMutableArray(array: Array(repeating: 0, count: 65535))
        wram = WRAM(memory: memory)
    }

    init(initial: [UInt8]) {
        memory = NSMutableArray(array: initial)
        wram = WRAM(memory: memory)
    }

    private func selectRegion(_ addr: UInt16) -> Memory {
        if addr <= 0x07ff {
            return wram
        }
        // TODO Support other memory regions
        return DummyRAM()
    }

    func read(addr: UInt16) -> UInt8 {
        return selectRegion(addr).read(addr: addr)
    }

    func write(addr: UInt16, data: UInt8) {
        selectRegion(addr).write(addr: addr, data: data)
    }
}

class WRAM: Memory {
    private var data: NSMutableArray

    init(memory: NSMutableArray) {
        self.data = memory
    }

    func read(addr: UInt16) -> UInt8 {
        return data[Int(addr)] as! UInt8
    }

    func write(addr: UInt16, data: UInt8) {
        self.data[Int(addr)] = data
    }
}

class DummyRAM: Memory {

    func read(addr: UInt16) -> UInt8 {
        return 0
    }

    func write(addr: UInt16, data: UInt8) {}
}
