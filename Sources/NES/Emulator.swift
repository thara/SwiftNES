public struct Emulator<L: LineRenderer> {
    private var nes: NES

    private(set) var cycles: UInt = 0

    private var frames: UInt = 0
    private var scan = Scan()

    private var lineBuffer = LineBuffer()

    private let lineRenderer: LineRenderer

    public init(lineRenderer: L) {
        self.nes = NES()
        self.lineRenderer = lineRenderer
    }

    public mutating func insert(cartridge rom: ROM) {
        nes.mapper = rom.mapper

        cpuPowerOn()
        clearInterrupt([.NMI, .IRQ])
        sendInterrupt(.RESET)

        nes.cpu.wram.fill(0x00)

        ppuRegisterClear()

        nes.ppu.nameTable.fill(0x00)
        nes.ppu.paletteRAMIndexes.fill(0x00)
        scan.clear()
        frames = 0

        lineBuffer.clear()
    }

    public func connect(controller1: Controller?, controller2: Controller?) {
        nes.controllers.port1 = controller1
        nes.controllers.port2 = controller2
    }

    public mutating func runFrame() {
        let before = currentFrames

        repeat {
            step()
        } while before == currentFrames
    }

    mutating func step() {
        let before = nes.cpuCycles

        cpuStep()

        let after = nes.cpuCycles
        let cpuCycles: UInt
        if before <= after {
            cpuCycles = after &- before
        } else {
            cpuCycles = UInt.max &- before &+ after
        }
        cycles += cpuCycles

        var ppuCycles = cpuCycles &* 3
        while 0 < ppuCycles {
            let currentLine = scan.line

            ppuStep()

            if currentLine != scan.line {
                lineRenderer.rednerLine(at: currentLine, by: &lineBuffer)
            }
            ppuCycles &-= 1
        }
    }
}

public protocol LineRenderer: class {
    func rednerLine(at: Int, by: inout LineBuffer)
}

extension Emulator: CPU {}

extension Emulator: CPURegisters {
    var A: UInt8 {
        get { nes.cpu.A }
        set { nes.cpu.A = newValue }
    }
    var X: UInt8 {
        get { nes.cpu.X }
        set { nes.cpu.X = newValue }
    }
    var Y: UInt8 {
        get { nes.cpu.Y }
        set { nes.cpu.Y = newValue }
    }
    var S: UInt8 {
        get { nes.cpu.S }
        set { nes.cpu.S = newValue }
    }
    var P: CPUStatus {
        get { nes.cpu.P }
        set { nes.cpu.P = newValue }
    }
    var PC: UInt16 {
        get { nes.cpu.PC }
        set { nes.cpu.PC = newValue }
    }
}

extension Emulator: CPUCycle {
    mutating func tick() {
        nes.cpuCycles &+= 1
    }

    mutating func tick(count: UInt) {
        nes.cpuCycles &+= count
    }
}

extension Emulator: CPUMemory {
    mutating func cpuRead(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.cpu.wram.read(at: address)
        case 0x2000...0x3FFF:
            return readPPURegister(from: ppuAddress(address))
        /* case 0x4000...0x4013, 0x4015: */
        /*     return apuPort?.read(from: address) ?? 0x00 */
        case 0x4016, 0x4017:
            return nes.controllers.read(at: address)
        case 0x4020...0xFFFF:
            return nes.mapper?.read(at: address) ?? 0x00
        default:
            return 0x00
        }
    }

    mutating func cpuWrite(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x07FF:
            nes.cpu.wram.write(value, at: address)
        case 0x2000...0x3FFF:
            writePPURegister(value, to: ppuAddress(address))
        /* case 0x4000...0x4013, 0x4015: */
        /*     apuPort?.write(value, to: address) */
        case 0x4016:
            nes.controllers.write(value)
        case 0x4017:
            nes.controllers.write(value)
            /* apuPort?.write(value, to: address) */
        case 0x4020...0xFFFF:
            nes.mapper?.write(value, at: address)
        default:
            break
        }
    }

    private func ppuAddress(_ address: UInt16) -> UInt16 {
        // repears every 8 bytes
        return 0x2000 &+ address % 8
    }
}

extension Emulator: PPU {
    var internalDataBus: UInt8 {
        get { nes.ppu.internalDataBus }
        set { nes.ppu.internalDataBus = newValue }
    }
}

extension Emulator: PPURegisters {
    var controller: PPUController {
        get { nes.ppu.controller }
        set { nes.ppu.controller = newValue }
    }
    var mask: PPUMask {
        get { nes.ppu.mask }
        set { nes.ppu.mask = newValue }
    }
    var status: PPUStatus {
        get { nes.ppu.status }
        set { nes.ppu.status = newValue }
    }
    var data: UInt8 {
        get { nes.ppu.data }
        set { nes.ppu.data = newValue }
    }
    var objectAttributeMemoryAddress: UInt8 {
        get { nes.ppu.objectAttributeMemoryAddress }
        set { nes.ppu.objectAttributeMemoryAddress = newValue }
    }
    var v: UInt16 {
        get { nes.ppu.v }
        set { nes.ppu.v = newValue }
    }
    var t: UInt16 {
        get { nes.ppu.t }
        set { nes.ppu.t = newValue }
    }
    var fineX: UInt8 {
        get { nes.ppu.fineX }
        set { nes.ppu.fineX = newValue }
    }
    var writeToggle: Bool {
        get { nes.ppu.writeToggle }
        set { nes.ppu.writeToggle = newValue }
    }
}

extension Emulator: PPUMemory {
    func ppuRead(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.mapper?.read(at: address) ?? 0x00
        case 0x2000...0x2FFF:
            return nes.ppu.nameTable.read(at: toNameTableAddress(address))
        case 0x3000...0x3EFF:
            return nes.ppu.nameTable.read(at: toNameTableAddress(address &- 0x1000))
        case 0x3F00...0x3FFF:
            return nes.ppu.paletteRAMIndexes.read(at: toPalleteAddress(address))
        default:
            return 0x00
        }
    }

    mutating func ppuWrite(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x1FFF:
            nes.mapper?.write(value, at: address)
        case 0x2000...0x2FFF:
            nes.ppu.nameTable.write(value, at: toNameTableAddress(address))
        case 0x3000...0x3EFF:
            nes.ppu.nameTable.write(value, at: toNameTableAddress(address &- 0x1000))
        case 0x3F00...0x3FFF:
            nes.ppu.paletteRAMIndexes.write(value, at: toPalleteAddress(address))
        default:
            break  // NOP
        }
    }

    func toNameTableAddress(_ baseAddress: UInt16) -> UInt16 {
        switch nes.mapper?.mirroring {
        case .vertical?:
            return baseAddress % 0x0800
        case .horizontal?:
            if 0x2800 <= baseAddress {
                return 0x0800 &+ baseAddress % 0x0400
            } else {
                return baseAddress % 0x0400
            }
        default:
            return baseAddress &- 0x2000
        }
    }
}

func toPalleteAddress(_ baseAddress: UInt16) -> UInt16 {
    // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
    let addr = baseAddress % 32

    if addr % 4 == 0 {
        return (addr | 0x10)
    } else {
        return addr
    }
}

extension Emulator: PPUBackground {
    var nameTableEntry: UInt8 {
        get { nes.ppu.nameTableEntry }
        set { nes.ppu.nameTableEntry = newValue }
    }
    var attrTableEntry: UInt8 {
        get { nes.ppu.attrTableEntry }
        set { nes.ppu.attrTableEntry = newValue }
    }
    var bgTempAddr: UInt16 {
        get { nes.ppu.bgTempAddr }
        set { nes.ppu.bgTempAddr = newValue }
    }
    var tile: PPUBgTile {
        get { nes.ppu.tile }
        set { nes.ppu.tile = newValue }
    }
    var nextPattern: PPUBgTilePattern {
        get { nes.ppu.nextPattern }
        set { nes.ppu.nextPattern = newValue }
    }
}

extension Emulator: PPUSpriteOAM {
    var primaryOAM: [UInt8] {
        get { nes.ppu.primaryOAM }
        set { nes.ppu.primaryOAM = newValue }
    }
    var secondaryOAM: [UInt8] {
        get { nes.ppu.secondaryOAM }
        set { nes.ppu.secondaryOAM = newValue }
    }
    var sprites: [PPUSprite] {
        get { nes.ppu.sprites }
        set { nes.ppu.sprites = newValue }
    }
    var spriteZeroOnLine: Bool {
        get { nes.ppu.spriteZeroOnLine }
        set { nes.ppu.spriteZeroOnLine = newValue }
    }
}

extension Emulator: Scanline {
    var currentLine: Int {
        get { scan.line }
        set { scan.line = newValue }
    }
    var currentDot: Int {
        get { scan.dot }
        set { scan.dot = newValue }
    }
    var currentFrames: UInt {
        get { frames }
        set { frames = newValue }
    }

    mutating func skipDot() { scan.skip() }
    mutating func nextDot() -> ScanUpdate { scan.nextDot() }
}

extension Emulator: PixelRederer {
    mutating func writePixel(_ pixel: Int, _ bg: Int, _ sprite: Int, at x: Int) {
        lineBuffer.write(pixel, bg, sprite, at: x)
    }
}

extension Emulator: InterruptLine {

    mutating func sendInterrupt(_ interrupt: Interrupt) {
        nes.interrupt.formUnion(interrupt)
    }

    func receiveInterrupt() -> Interrupt {
        return nes.interrupt
    }

    mutating func clearInterrupt(_ interrupt: Interrupt) {
        nes.interrupt.remove(interrupt)
    }

    var interrupted: Bool {
        return !nes.interrupt.isEmpty
    }
}

struct Scan {
    var dot: Int = 0
    var line: Int = 0

    mutating func clear() {
        dot = 0
        line = 0
    }

    mutating func skip() {
        dot &+= 1
    }

    mutating func nextDot() -> ScanUpdate {
        dot &+= 1
        if maxDot <= dot {
            dot %= maxDot

            let last = line

            line &+= 1
            if maxLine < line {
                line = 0
                return .frame(lastLine: last)
            } else {
                return .line(lastLine: last)
            }
        } else {
            return .dot
        }
    }
}

public struct LineBuffer {
    public var buffer = [UInt32](repeating: 0x00, count: maxDot)
    public var backgroundBuffer = [UInt32](repeating: 0x00, count: maxDot)
    public var spriteBuffer = [UInt32](repeating: 0x00, count: maxDot)

    mutating func clear() {
        buffer = [UInt32](repeating: 0x00, count: maxDot)
        backgroundBuffer = [UInt32](repeating: 0x00, count: maxDot)
        spriteBuffer = [UInt32](repeating: 0x00, count: maxDot)
    }

    mutating func write(_ pixel: Int, _ background: Int, _ sprite: Int, at x: Int) {
        buffer[x] = palletes[pixel]
        backgroundBuffer[x] = palletes[background]
        spriteBuffer[x] = palletes[sprite]
    }
}

let palletes: [UInt32] = [
    0x7C7C7C, 0x0000FC, 0x0000BC, 0x4428BC, 0x940084, 0xA80020, 0xA81000, 0x881400,
    0x503000, 0x007800, 0x006800, 0x005800, 0x004058, 0x000000, 0x000000, 0x000000,
    0xBCBCBC, 0x0078F8, 0x0058F8, 0x6844FC, 0xD800CC, 0xE40058, 0xF83800, 0xE45C10,
    0xAC7C00, 0x00B800, 0x00A800, 0x00A844, 0x008888, 0x000000, 0x000000, 0x000000,
    0xF8F8F8, 0x3CBCFC, 0x6888FC, 0x9878F8, 0xF878F8, 0xF85898, 0xF87858, 0xFCA044,
    0xF8B800, 0xB8F818, 0x58D854, 0x58F898, 0x00E8D8, 0x787878, 0x000000, 0x000000,
    0xFCFCFC, 0xA4E4FC, 0xB8B8F8, 0xD8B8F8, 0xF8B8F8, 0xF8A4C0, 0xF0D0B0, 0xFCE0A8,
    0xF8D878, 0xD8F878, 0xB8F8B8, 0xB8F8D8, 0x00FCFC, 0xF8D8F8, 0x000000, 0x000000,
]
