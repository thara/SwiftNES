func makeNES() -> NES {
    let nes = NES()

    nes.cpu.readCPU = { NES.readCPU(at: $0, on: nes) }
    nes.cpu.writeCPU = { NES.writeCPU($0, at: $1, on: nes) }

    nes.ppu.readMemory = { NES.readPPUMemory(at: $0, on: nes) }
    nes.ppu.writeMemory = { NES.writePPUMemory($0, at: $1, on: nes) }

    return nes
}

class NES {
    var cpu: CPU
    var ppu: PPU

    var rom: ROM? {
        didSet {
            mirroring = rom?.mapper.mirroring
        }
    }

    var wram: [UInt8]
    var nameTable: [UInt8]
    var paletteRAMIndexes: [UInt8]

    let interruptLine: InterruptLine

    var mirroring: Mirroring?

    private(set) var cycles: UInt = 0

    var renderLine: (Int, LineBuffer) -> () = { _, _ in }

    init() {
        self.interruptLine = InterruptLine()

        self.cpu = CPU(interruptLine: interruptLine)
        self.ppu = PPU(interruptLine: interruptLine)

        self.wram = [UInt8](repeating: 0x00, count: 32767)
        self.nameTable = [UInt8](repeating: 0x00, count: 0x1000)
        self.paletteRAMIndexes = [UInt8](repeating: 0x00, count: 0x0020)
    }

    public func runFrame() {
        let currentFrame = ppu.frames

        repeat {
            step()
        } while currentFrame == ppu.frames
    }

    func step() {
        let cpuCycles = cpu.step()
        cycles &+= cpuCycles

        var ppuCycles = cpuCycles &* 3
        while 0 < ppuCycles {
            let currentLine = ppu.line

            ppu.step()

            if currentLine != ppu.line {
                renderLine(currentLine, ppu.lineBuffer)
            }
            ppuCycles &-= 1
        }
    }
}

extension NES {

    /// Read a byte at the given `address` on CPU memory
    static func readCPU(at address: UInt16, on nes: NES) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.wram[Int(address)]
        case 0x2000...0x3FFF:
            return nes.ppu.read(at: ppuAddress(address))
        /* case 0x4000...0x4013, 0x4015: */
        /*     return apuPort?.read(from: address) ?? 0x00 */
        /* case 0x4016, 0x4017: */
        /*     return controllerPort?.read(at: address) ?? 0x00 */
        case 0x4020...0xFFFF:
            return nes.rom?.read(at: address) ?? 0x00
        default:
            return 0;
        }
    }

    /// Write the given `value` at the `address` into CPU memory
    static func writeCPU(_ value: UInt8, at address: UInt16, on nes: NES) {
        switch address {
        case 0x0000...0x07FF:
            nes.wram[Int(address)] = value
        case 0x2000...0x3FFF:
            nes.ppu.write(value, at: ppuAddress(address))
        /* case 0x4000...0x4013, 0x4015: */
        /*     apuPort?.write(value, to: address) */
        /* case 0x4016: */
        /*     controllerPort?.write(value) */
        /* case 0x4017: */
        /*     controllerPort?.write(value) */
        /*     apuPort?.write(value, to: address) */
        case 0x4020...0xFFFF:
            nes.rom?.write(value, at: address)
        default:
            break
        }
    }

    static func ppuAddress(_ address: UInt16) -> UInt16 {
        // repears every 8 bytes
        return 0x2000 &+ address % 8
    }

    /// Read a byte at the given `address` on PPU memory
    static func readPPUMemory(at address: UInt16, on nes: NES) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return nes.rom?.read(at: address) ?? 0x00
        case 0x2000...0x2FFF:
            return nes.nameTable[Int(toNameTableAddress(address, on: nes))]
        case 0x3000...0x3EFF:
            return nes.nameTable[Int(toNameTableAddress(address &- 0x1000, on: nes))]
        case 0x3F00...0x3FFF:
            return nes.paletteRAMIndexes[Int(toPalleteAddress(address))]
        default:
            return 0x00
        }
    }

    /// Write the given `value` at the `address` into PPU memory
    static func writePPUMemory(_ value: UInt8, at address: UInt16, on nes: NES) {
        switch address {
        case 0x0000...0x1FFF:
            nes.rom?.write(value, at: address)
        case 0x2000...0x2FFF:
            nes.nameTable[Int(toNameTableAddress(address, on: nes))] = value
        case 0x3000...0x3EFF:
            nes.nameTable[Int(toNameTableAddress(address &- 0x1000, on: nes))] = value
        case 0x3F00...0x3FFF:
            nes.paletteRAMIndexes[Int(toPalleteAddress(address))] = value
        default:
            break  // NOP
        }
    }

    static func toNameTableAddress(_ baseAddress: UInt16, on nes: NES) -> UInt16 {
        switch nes.mirroring {
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

    static func toPalleteAddress(_ baseAddress: UInt16) -> UInt16 {
        // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
        let addr = baseAddress % 32

        if addr % 4 == 0 {
            return (addr | 0x10)
        } else {
            return addr
        }
    }
}

enum Mirroring {
    case vertical, horizontal
}

// MARK: - Memory
/* protocol Memory: class { */
/*     /// Read a byte at the given `address` on CPU memory */
/*     func readCPU(at: UInt16) -> UInt8 */
/*     /// Write the given `value` at the `address` into CPU memory */
/*     func writeCPU(_ value: UInt8, at: UInt16) */

/*     /// Read a byte at the given `address` on PPU memory */
/*     func readPPU(at: UInt16) -> UInt8 */
/*     /// Write the given `value` at the `address` into PPU memory */
/*     func writePPU(_ value: UInt8, at: UInt16) */
/* } */

/* extension Memory { */
    /* func readCPU(at address: UInt16) -> UInt16 { */
    /*     return readCPU(at: address).u16 | (readCPU(at: address + 1).u16 << 8) */
    /* } */

    /* func readPPU(at address: UInt16) -> UInt16 { */
    /*     return readPPU(at: address).u16 | (readPPU(at: address + 1).u16 << 8) */
    /* } */
/* } */

// MARK: - Interrupt
struct Interrupt: OptionSet {
    let rawValue: UInt8

    static let RESET = Interrupt(rawValue: 1 << 3)
    static let NMI = Interrupt(rawValue: 1 << 2)
    static let IRQ = Interrupt(rawValue: 1 << 1)
    static let BRK = Interrupt(rawValue: 1 << 0)
}

final class InterruptLine {
    private var current: Interrupt = []

    func send(_ interrupt: Interrupt) {
        current.formUnion(interrupt)
    }

    func get() -> Interrupt {
        return current
    }

    func clear(_ interrupt: Interrupt) {
        current.remove(interrupt)
    }

    var interrupted: Bool {
        return !current.isEmpty
    }
}

