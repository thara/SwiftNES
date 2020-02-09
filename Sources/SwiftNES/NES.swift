public final class NES {
    fileprivate var cpu: CPU
    fileprivate var ppu: PPU
    fileprivate var apu: APU

    private let cpuMemory = CPUMemory()
    private let ppuMemory = PPUMemory()

    private let controllerPort = ControllerPort()

    fileprivate let interruptLine: InterruptLine

    public static let maxDot = 340
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    private var nestest: NESTest

    fileprivate var cycles: UInt = 0

    fileprivate var lineBuffer = LineBuffer()

    public init() {
        interruptLine = InterruptLine()

        cpu = CPU(memory: cpuMemory)
        ppu = PPU(memory: ppuMemory)
        cpuMemory.ppuPort = ppu
        cpuMemory.controllerPort = controllerPort

        apu = APU()

        nestest = NESTest(interruptLine: interruptLine)
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
    }

    public func connect(controller1: Controller?, controller2: Controller?) {
        controllerPort.port1 = controller1
        controllerPort.port2 = controller2
    }
}

public func runFrame(_ nes: NES, onLineEnd render: (Int, inout LineBuffer) -> Void) {
    let currentFrame = nes.ppu.frames

    repeat {
        step(nes, onLineEnd: render)
    } while currentFrame == nes.ppu.frames
}

func step(_ nes: NES, onLineEnd render: (Int, inout LineBuffer) -> Void) {
#if nestest
    if !interruptLine.interrupted { nestest.before(cpu: &cpu) }
#endif

    let cpuCycles = SwiftNES.step(cpu: &nes.cpu, interruptLine: nes.interruptLine)
    nes.cycles &+= cpuCycles

    nes.apu.step()

#if nestest
    nestest.print(ppu: nes.ppu, cycles: cycles)
    if interruptLine.interrupted { return }
#endif

    var ppuCycles = cpuCycles &* 3
    while 0 < ppuCycles {
        let currentLine = nes.ppu.scan.line

        nes.ppu.step(writeTo: &nes.lineBuffer, interruptLine: nes.interruptLine)

        if currentLine != nes.ppu.scan.line {
            render(currentLine, &nes.lineBuffer)
        }

        ppuCycles &-= 1
    }
}
