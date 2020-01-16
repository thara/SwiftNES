extension CPU {
    mutating func read(at address: UInt16, from memory: inout Memory) -> UInt8 {
        tick()
        return memory.read(at: address)
    }

    mutating func write(_ value: UInt8, at address: UInt16, to memory: inout Memory) {
        if address == 0x4014 { // OAMDMA
            writeOAM(value, to: &memory)
            return
        }
        tick()

        memory.write(value, at: address)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
    mutating func writeOAM(_ value: UInt8, to memory: inout Memory) {
        let start = value.u16 &* 0x100
        for address in start...(start &+ 0xFF) {
            let data = memory.read(at: address)
            memory.write(data, at: 0x2004)
            tick(count: 2)
        }

        // dummy cycles
        tick()
        if cycles % 2 == 1 {
            tick()
        }
    }

    mutating func readWord(at address: UInt16, from memory: inout Memory) -> UInt16 {
        return SwiftNES.readWord(at: address) { op in read(at: op, from: &memory) }
    }

    mutating func readOnIndirect(operand: UInt16, from memory: inout Memory) -> UInt16 {
        return SwiftNES.readOnIndirect(operand: operand) { op in read(at: op, from: &memory) }
    }
}

func readOnIndirect(operand: UInt16, read: (UInt16) -> UInt8) -> UInt16 {
    let low = read(operand).u16
    let high = read(operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8
    return low | high
}
