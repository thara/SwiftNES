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

class RAM: Memory {
    private var data: NSMutableArray

    init(memory: NSMutableArray) {
        self.data = memory
    }

    func read(addr: UInt16) -> UInt8 {
        return data[Int(addr)] as! UInt8 // swiftlint:disable:this force_cast
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
        return data[Int(addr)] as! UInt8 // swiftlint:disable:this force_cast
    }

    func write(addr: UInt16, data: UInt8) {
        print("DEBUG: Unexpected Write to ROM region: addr=\(addr), data=\(data)\n")
    }
}

class DummyMemory: Memory {

    func read(addr: UInt16) -> UInt8 {
        return 0
    }

    func write(addr: UInt16, data: UInt8) {}
}
