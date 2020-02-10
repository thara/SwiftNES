public final class NES {
    var cpu: CPU
    var ppu: PPU
    fileprivate var apu: APU

    let cpuMemory = CPUMemoryBus()
    private let ppuMemory = PPUMemory()

    let controllerPort = ControllerPort()
    var cartridge: Cartridge?

    fileprivate let interruptLine: InterruptLine

    public static let maxDot = 340
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    private var nestest: NESTest

    var cycles: UInt = 0

    fileprivate var lineBuffer = LineBuffer()

    public init() {
        interruptLine = InterruptLine()

        cpu = CPU()
        ppu = PPU(memory: ppuMemory)

        apu = APU()

        nestest = NESTest(interruptLine: interruptLine)

        cpuMemory.nes = self
    }

    public func insert(cartridge: Cartridge) {
        self.cartridge = cartridge
        ppuMemory.cartridge = cartridge

        cpu.powerOn()

        interruptLine.clear([.NMI, .IRQ])
        interruptLine.send(.RESET)

        cpuMemory.clear()
        ppu.reset()
        lineBuffer.clear()
    }

    public func connect(controller1: Controller?, controller2: Controller?) {
        controllerPort.port1 = controller1
        controllerPort.port2 = controller2
    }
}

public protocol RunFrame {
    static func runFrame(_ nes: inout Self, onLineEnd render: (Int, inout LineBuffer) -> Void)
}

extension NES: RunFrame {
    public static func runFrame(_ nes: inout NES, onLineEnd render: (Int, inout LineBuffer) -> Void) {
        let currentFrame = nes.ppu.frames

        repeat {
            step(&nes, onLineEnd: render)
        } while currentFrame == nes.ppu.frames
    }

    static func step(_ nes: inout NES, onLineEnd render: (Int, inout LineBuffer) -> Void) {
    #if nestest
        if !interruptLine.interrupted { nestest.before(cpu: &cpu) }
    #endif

        let cpuCycles = cpuStep(interruptLine: nes.interruptLine, on: &nes)
        // nes.cycles &+= cpuCycles

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
}
