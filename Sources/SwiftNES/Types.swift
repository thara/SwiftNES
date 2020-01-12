struct NESState {
    var cpu = CPUState()
    var wram = [UInt8](repeating: 0x00, count: 32767)

    var ppu = PPUState()
}

struct CPUState {
    /// Accumulator
    var A: UInt8 = 0x00
    /// Index register
    var X: UInt8 = 0x00
    /// Index register
    var Y: UInt8 = 0x00
    /// Stack pointer
    var S: UInt8 = 0xFF
    /// Status register
    var P: UInt8 = 0
    /// Program Counter
    var PC: UInt16 = 0x00

    var clocks: UInt = 0

    mutating func tick() {
        clocks += 1
    }
}

protocol CPUMemory {
    subscript(address: UInt16) -> UInt8 { get set }
}

extension CPUMemory {
    func readWord(at address: UInt16) -> UInt16 {
        return self[address].u16 | (self[address + 1].u16 << 8)
    }
}

struct PPUState {
    var PPUCTRL: PPUController = []
    var PPUMASK: PPUMask = []
    var PPUSTATUS: PPUStatus = []
    var PPUDATA: UInt8 = 0x00
    var OAMADDR: UInt8 = 0x00

    // http://wiki.nesdev.com/w/index.php/PPU_registers#Ports
    var internalDataBus: UInt8 = 0x00

    /// current VRAM address
    var v: UInt16 = 0x00
    /// temporary VRAM address
    var t: UInt16 = 0x00
    /// Fine X scroll
    var fineX: UInt8 = 0x00

    var writeToggle: Bool = false

    var bg = PPUBackground()
    var sprite = PPUSprite()

    var frames: UInt = 0
    var scan = Scan()

    // http://wiki.nesdev.com/w/index.php/PPU_scrolling#.242002_read
    mutating func readStatus() -> UInt8 {
        let s = PPUSTATUS
        PPUSTATUS.remove(.vblank)
        writeToggle = false
        return s.rawValue
    }
}

struct PPUBackground {
    // Background registers
    var nameTableEntry: UInt8 = 0x00
    var attrTableEntry: UInt8 = 0x00
    var bgTempAddr: UInt16 = 0x00

    /// Background tiles
    var tile = Tile()
    var nextPattern = BackgroundTileShiftRegisters()
}

struct PPUSprite {
    var primaryOAM = [UInt8](repeating: 0x00, count: oamSize)
    var secondaryOAM = [UInt8](repeating: 0x00, count: 32)
    var sprites = [Sprite](repeating: .defaultValue, count: spriteLimit)

    var spriteZeroOnLine = false
}
