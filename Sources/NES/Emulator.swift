struct Emulator<M: MemoryMap, L: LineRenderer, A: AudioBuffer> {
    var nes = NES()
    var memoryMap: M.Type

    var currentFrames: UInt = 0
    var scan = Scan()

    var lineBuffer = LineBuffer()

    var cycles: UInt = 0

    let lineRenderer: L
    let audioBuffer: A

    mutating func insert(cartridge rom: ROM) {
        nes.mapper = rom.mapper

        cpuPowerOn()
        clearInterrupt([.NMI, .IRQ])
        sendInterrupt(.RESET)

        nes.cpu.wram.fill(0x00)

        ppuRegisterClear()

        nes.ppu.nameTable.fill(0x00)
        nes.ppu.paletteRAMIndexes.fill(0x00)
        scan.clear()
        currentFrames = 0

        lineBuffer.clear()
    }

    mutating func runFrame() {
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

        /* for _ in 0..<cpuCycles { */
        /*     let cpuSteel = apuStep() */
        /*     if cpuSteel { */
        /*         cycles &+= 4 */
        /*     } */
        /* } */

        //FIXME
        // if apu.frameInterrupted {
        //     interruptLine.send(.IRQ)
        // }

        var ppuCycles = cpuCycles &* 3
        while 0 < ppuCycles {
            let currentLine = scan.line

            ppuStep()

            switch scan.nextDot() {
            case .frame:
                currentFrames += 1
            default:
                break
            }

            if currentLine != scan.line {
                lineRenderer.rednerLine(at: currentLine, by: &lineBuffer)
            }
            ppuCycles &-= 1
        }
    }
}

public protocol AudioBuffer {
    func write(_ sample: Float)
}

public protocol LineRenderer: class {
    func rednerLine(at: Int, by: inout LineBuffer)
}

struct Scan {
    enum Update: Equatable {
        case dot
        case line(lastLine: Int)
        case frame(lastLine: Int)
    }

    var dot: Int = 0
    var line: Int = 0

    mutating func clear() {
        dot = 0
        line = 0
    }

    mutating func skip() {
        dot &+= 1
    }

    mutating func nextDot() -> Update {
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
