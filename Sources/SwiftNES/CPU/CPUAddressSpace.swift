import Foundation

class CPUAddressSpace: Memory {
    private var memory: NSMutableArray
    private var wram: RAM
    private var programROM: ROM

    init() {
        memory = NSMutableArray(array: Array(repeating: 0, count: 65536))
        wram = RAM(memory: memory)
        programROM = ROM(memory: memory)
    }

    init(initial: [UInt8]) {
        memory = NSMutableArray(array: initial)
        wram = RAM(memory: memory)
        programROM = ROM(memory: memory)
    }

    private func selectRegion(_ addr: UInt16) -> Memory {
        if addr <= 0x07ff {
            return wram
        } else if 0x8000 <= addr && addr <= 0xbfff {
            return programROM
        } else if addr <= 0xffff {
            return programROM
        }
        // TODO Support other memory regions
        return DummyMemory()
    }

    func read(addr: UInt16) -> UInt8 {
        return selectRegion(addr).read(addr: addr)
    }

    func write(addr: UInt16, data: UInt8) {
        selectRegion(addr).write(addr: addr, data: data)
    }

    func loadProgram(index: Int, data: [UInt8]) {
        for (i, b) in data.enumerated() {
            memory[0x8000 + index * 0x4000 + i] = b
        }
    }
}
