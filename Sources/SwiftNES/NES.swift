public final class NES {
    private var cpu: CPU
    private let ppu: PPU
    var apu: APU

    private let cpuMemory = CPUMemory()
    private let ppuMemory = PPUMemory()

    private let controllerPort = ControllerPort()

    private let interruptLine: InterruptLine

    public static let maxDot = 340
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    private var nestest: NESTest

    private(set) var cycles: UInt = 0

    private var lineBuffer = LineBuffer()

    let samplingFrequency: UInt = 1789772
    let downSamplingRate: UInt = 44100

    public init() {
        interruptLine = InterruptLine()

        cpu = CPU(memory: cpuMemory)
        ppu = PPU(memory: ppuMemory)
        cpuMemory.ppuPort = ppu
        cpuMemory.controllerPort = controllerPort

        apu = APU(sampleRate: samplingFrequency / downSamplingRate, framePeriod: 7458)
        cpuMemory.apuPort = apu

        nestest = NESTest(interruptLine: interruptLine)
    }

    public func runFrame<T: AudioBuffer>(
        onLineEnd render: (Int, inout LineBuffer) -> Void,
        withAudio audioBuffer: T) {
        let currentFrame = ppu.frames

        repeat {
            step(onLineEnd: render, withAudio: audioBuffer)
        } while currentFrame == ppu.frames
    }

    public func step<T: AudioBuffer>(
        onLineEnd render: (Int, inout LineBuffer) -> Void,
        withAudio audioBuffer: T) {
#if nestest
        if !interruptLine.interrupted { nestest.before(cpu: &cpu) }
#endif

        let cpuCycles = cpu.step(interruptLine: interruptLine)
        cycles &+= cpuCycles

        let cpuSteel = apu.step(audioBuffer: audioBuffer, memoryReader: cpuMemory)
        if cpuSteel {
            cycles &+= 4
        }

#if nestest
        nestest.print(ppu: ppu, cycles: cycles)
        if interruptLine.interrupted { return }
#endif

        var ppuCycles = cpuCycles &* 3
        while 0 < ppuCycles {
            let currentLine = ppu.line

            ppu.step(writeTo: &lineBuffer, interruptLine: interruptLine)

            if currentLine != ppu.line {
                render(currentLine, &lineBuffer)
            }

            ppuCycles &-= 1
        }
    }

    public func insert(cartridge: Cartridge) {
        cpuMemory.cartridge = cartridge
        ppuMemory.cartridge = cartridge

        cpu.powerOn()

        interruptLine.clear([.NMI, .IRQ])
        interruptLine.send(.RESET)

        cpu.memory.clear()
        ppu.reset()
        lineBuffer.clear()

        apu.reset()
    }

    public func connect(controller1: Controller?, controller2: Controller?) {
        controllerPort.port1 = controller1
        controllerPort.port2 = controller2
    }
}

extension CPUMemory: DMCMemoryReader {}
