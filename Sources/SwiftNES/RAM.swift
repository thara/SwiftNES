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
    private var rawData: [UInt8]

    init(rawData: [UInt8]) {
        self.rawData = rawData
    }

    convenience init(data: UInt8, count: Int) {
        self.init(rawData: [UInt8](repeating: data, count: count))
    }

    func read(addr: UInt16) -> UInt8 {
        return rawData[Int(addr)]
    }

    func write(addr: UInt16, data: UInt8) {
        rawData[Int(addr)] = data
    }
}
