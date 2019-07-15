class CPUAddressSpace: Memory {
    private var memory: RAM

    init() {
        memory = RAM(data: 0x00, count: 65536)
    }

    init(initial: [UInt8]) {
        self.memory = RAM(rawData: initial)
    }

    func read(addr: UInt16) -> UInt8 {
        switch addr {
        case 0x0000...0x07FF:
            return memory.read(addr: addr)
        case 0x0000...0xFFFF:
            return memory.read(addr: addr)
        default:
            return 0x00
        }
    }

    func write(addr: UInt16, data: UInt8) {
        switch addr {
        case 0x0000...0x07FF:
            memory.write(addr: addr, data: data)
        case 0x0000...0xFFFF:
            print("DEBUG: Unexpected Write to ROM region: addr=\(addr), data=\(data)\n")
        default:
            break
        }
    }

    func loadProgram(index: Int, data: [UInt8]) {
        for (i, b) in data.enumerated() {
            memory.write(addr: UInt16(0x8000 + index * 0x4000 + i), data: b)
        }
    }
}
