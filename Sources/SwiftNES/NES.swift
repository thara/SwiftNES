public final class NES {
    var cpu: CPU
    private var wram: [UInt8]

    private let ppu: PPU
    var apu: APUPort

    var cartridge: Cartridge?

    private let ppuBus = PPUBus()

    private let controllerPort = ControllerPort()

    private let interruptLine: InterruptLine

    public static let maxDot = 340
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    private var nestest: NESTest

    private var lineBuffer = LineBuffer()

    var lineRenderer: LineRenderer
    var audioBuffer: AudioBuffer

    let samplingFrequency: UInt = 1_789_772
    let downSamplingRate: UInt = 44100

    public init(withRenderer lineRenderer: LineRenderer, withAudio audioBuffer: AudioBuffer) {
        self.wram = [UInt8](repeating: 0x00, count: 32767)

        interruptLine = InterruptLine()

        cpu = CPU()
        ppu = PPU(bus: ppuBus)

        let apu = APU(sampleRate: samplingFrequency / downSamplingRate, framePeriod: 7458)
        self.apu = APUPort(apu: apu)

        nestest = NESTest(interruptLine: interruptLine)

        self.lineRenderer = lineRenderer
        self.audioBuffer = audioBuffer
    }

    public func runFrame() {
        let currentFrame = ppu.frames

        repeat {
            step()
        } while currentFrame == ppu.frames
    }

    public func step() {
        #if nestest
            if !interruptLine.interrupted {
                nestest.before(nes: self)
            }
        #endif

        cpuStep(interruptLine: interruptLine)

        #if nestest
            nestest.print(ppu: ppu, cycles: cpu.cycles)
            if interruptLine.interrupted {
                return
            }
        #endif
    }

    public func insert(cartridge: Cartridge) {
        self.cartridge = cartridge
        ppuBus.cartridge = cartridge

        cpuPowerOn()

        interruptLine.clear([.NMI, .IRQ])
        interruptLine.send(.RESET)

        wram = [UInt8](repeating: 0x00, count: 32767)

        ppu.reset()
        lineBuffer.clear()

        apu.reset()
    }

    public func connect(controller1: Controller?, controller2: Controller?) {
        controllerPort.port1 = controller1
        controllerPort.port2 = controller2
    }
}

extension NES: CPUEmulator {
    func cpuRead(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return wram.read(at: address)
        case 0x2000...0x3FFF:
            return ppu.read(from: ppuAddress(address))
        case 0x4000...0x4013, 0x4015:
            return apu.read(from: address)
        case 0x4016, 0x4017:
            return controllerPort.read(at: address)
        case 0x4020...0xFFFF:
            return cartridge?.read(at: address) ?? 0x00
        default:
            return 0x00
        }
    }

    /// Write the given `value` at the `address` into this memory
    func cpuWrite(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x0000...0x07FF:
            wram.write(value, at: address)
        case 0x2000...0x3FFF:
            ppu.write(value, to: ppuAddress(address))
        case 0x4000...0x4013, 0x4015:
            apu.write(value, to: address)
        case 0x4016:
            controllerPort.write(value)
        case 0x4017:
            controllerPort.write(value)
            apu.write(value, to: address)
        case 0x4020...0xFFFF:
            cartridge?.write(value, at: address)
        default:
            break
        }
    }

    func cpuTick() {
        cpu.cycles += 1

        let cpuSteel = apu.step(audioBuffer: audioBuffer, memoryReader: self)
        if cpuSteel {
            cpu.cycles &+= 4
        }

        var ppuCycles = 3
        while 0 < ppuCycles {
            let currentLine = ppu.line

            ppu.step(writeTo: &lineBuffer, interruptLine: interruptLine)

            if currentLine != ppu.line {
                lineRenderer.newLine(at: currentLine, by: &lineBuffer)
            }

            ppuCycles &-= 1
        }
    }

    private func ppuAddress(_ address: UInt16) -> UInt16 {
        // repears every 8 bytes
        return 0x2000 &+ address % 8
    }
}

public protocol LineRenderer {
    func newLine(at: Int, by: inout LineBuffer)
}

extension NES: DMCMemoryReader {
    func readDMC(at address: UInt16) -> UInt8 {
        return cpuRead(at: address)
    }
}
