extension CPU {
    mutating func read(at address: UInt16) -> UInt8 {
        tick()
        return memory.read(at: address)
    }

    mutating func write(_ value: UInt8, at address: UInt16) {
        if address == 0x4014 { // OAMDMA
            writeOAM(value)
            return
        }
        tick()

        memory.write(value, at: address)
    }

    // http://wiki.nesdev.com/w/index.php/PPU_registers#OAM_DMA_.28.244014.29_.3E_write
    mutating func writeOAM(_ value: UInt8) {
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

    mutating func readWord(at address: UInt16) -> UInt16 {
        return read(at: address).u16 | (read(at: address + 1).u16 << 8)
    }

    mutating func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}

extension Memory {
    func readOnIndirect(operand: UInt16) -> UInt16 {
        let low = read(at: operand).u16
        let high = read(at: operand & 0xFF00 | ((operand &+ 1) & 0x00FF)).u16 &<< 8   // Reproduce 6502 bug; http://nesdev.com/6502bugs.txt
        return low | high
    }
}
