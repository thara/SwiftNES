import Foundation

protocol Memory {
    func read(addr: UInt16) -> UInt8
    func write(addr: UInt16, data: UInt8)

    func readWord(addr: UInt16) -> UInt16
}

extension Memory {
    func readWord(addr: UInt16) -> UInt16 {
        return read(addr: addr).u16 | (read(addr: addr + 1).u16 << 8)
    }
}

class AddressSpace: Memory {
    private var memory: NSMutableArray
    private var wram: WRAM
    private var programROM: ROM

    init() {
        memory = NSMutableArray(array: Array(repeating: 0, count: 65536))
        wram = WRAM(memory: memory)
        programROM = ROM(memory: memory)
    }

    init(initial: [UInt8]) {
        memory = NSMutableArray(array: initial)
        wram = WRAM(memory: memory)
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
        return DummyRAM()
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

class ROM: Memory {
    private var data: NSMutableArray

    init(memory: NSMutableArray) {
        self.data = memory
    }

    func read(addr: UInt16) -> UInt8 {
        return data[Int(addr)] as! UInt8
    }

    func write(addr: UInt16, data: UInt8) {
        print("DEBUG: Unexpected Write to ROM region: addr=\(addr), data=\(data)\n")
    }
}

class DummyRAM: Memory {

    func read(addr: UInt16) -> UInt8 {
        return 0
    }

    func write(addr: UInt16, data: UInt8) {}
}
