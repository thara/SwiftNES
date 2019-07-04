protocol PPU {

    // MARK: - Registers

    /// PPUCTRL
    var controller: UInt8 { get set }
    /// PPUMASK
    var mask: UInt8 { get set }
    /// PPUSTATUS
    var status: PPUStatus { get }
    /// OAMADDR
    var objectAttributeMemoryAddress: UInt8 { get set }
    /// OAMDATA
    var objectAttributeMemoryData: UInt8 { get set }
    /// PPUSCROLL
    var scroll: UInt8 { get set }
    /// PPUADDR
    var address: UInt8 { get set }
    /// PPUDATA
    var data: UInt8 { get set }
    /// OAMDMA
    var objectAttributeMemoryDMA: UInt8 { get set }

    var latch: Bool { get set }

    func run(cycle: Int)

    func render()
}

extension PPU {

    func run(cycle: Int) {
        //TODO
    }

    func render() {
        //TODO
    }
}

class PPUEmulator {
    var registers: PPURegisters

    var latch: Bool = false
    var memory: Memory

    var currentAddress: UInt16 = 0x00
    var scrollPosition: ScrollPosition = ScrollPosition(x: 0x00, y: 0x00)

    init(memory: Memory) {
        registers = PPURegisters(
            controller: [],
            mask: [],
            status: [],
            objectAttributeMemoryAddress: 0x00,
            objectAttributeMemoryData: 0x00,
            scroll: 0x00,
            address: 0x00,
            data: 0x00,
            objectAttributeMemoryDMA: 0x00
        )
        self.memory = memory
    }
}

// MARK: - Delegate to PPURegisters
extension PPUEmulator: PPU {

    var controller: UInt8 {
        get { return registers.controller.rawValue }
        set { registers.controller = PPUController(rawValue: newValue) }
    }

    var mask: UInt8 {
        get { return registers.mask.rawValue }
        set { registers.mask = PPUMask(rawValue: newValue) }
    }

    var status: PPUStatus {
        registers.status.remove(.vblank)
        latch = false
        return registers.status
    }

    var objectAttributeMemoryAddress: UInt8 {
        get { return registers.objectAttributeMemoryAddress }
        set { registers.objectAttributeMemoryAddress = newValue }
    }

    var objectAttributeMemoryData: UInt8 {
        get { return registers.objectAttributeMemoryData }
        set { registers.objectAttributeMemoryData = newValue }
    }

    var scroll: UInt8 {
        get { return registers.scroll }
        set {
            registers.scroll = newValue
            if !latch {
                scrollPosition.x = newValue
            } else {
                scrollPosition.y = newValue
            }
            latch = !latch
        }
    }

    var address: UInt8 {
        get { return registers.address }
        set {
            registers.address = newValue
            if !latch {
                currentAddress = (currentAddress & 0xFF00) | newValue.u16
            } else {
                currentAddress = newValue.u16 << 8 | (currentAddress & 0x00FF)
            }
            latch = !latch
        }
    }
    var data: UInt8 {
        get { return registers.data }
        set {
            registers.data = newValue
            memory.write(addr: currentAddress, data: newValue)
        }
    }
    var objectAttributeMemoryDMA: UInt8 {
        get { return registers.objectAttributeMemoryDMA }
        set { registers.objectAttributeMemoryDMA = newValue }
    }
}

struct ScrollPosition {
    var x: UInt8
    var y: UInt8

    mutating func reset() {
        x = 0x00
        y = 0x00
    }
}
