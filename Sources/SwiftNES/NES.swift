public final class NES {
    private var cpu: CPU
    private let ppu: PPU

    private var cpuMemory: Memory

    private let cartridgeDrive: CartridgeDrive
    private let controllerPort: ControllerPort

    private let interruptLine: InterruptLine

    public static let maxDot = 340
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    private var nestest: NESTest

    private(set) var cycles: UInt = 0

    private var lineBuffer = LineBuffer()

    public init() {
        interruptLine = InterruptLine()

        let cpuMemoryMap = CPUMemoryMap()
        cpu = CPU(memory: cpuMemoryMap)
        cpuMemory = cpuMemoryMap

        let ppuMemoryMap = PPUMemoryMap()
        ppu = PPU(memory: ppuMemoryMap)
        cpuMemoryMap.ppuPort = ppu

        controllerPort = ControllerPort()
        cpuMemoryMap.controllerPort = controllerPort

        cartridgeDrive = BusConnectedCartridgeDrive(cpuMemoryMap: cpuMemoryMap, ppuMemoryMap: ppuMemoryMap)

        nestest = NESTest(interruptLine: interruptLine)
    }

    public func runFrame(onLineEnd render: (Int, inout LineBuffer) -> Void) {
        let currentFrame = ppu.frames

        repeat {
            step(onLineEnd: render)
        } while currentFrame == ppu.frames
    }

    public func step(onLineEnd render: (Int, inout LineBuffer) -> Void) {
#if nestest
        if !interruptLine.interrupted { nestest.before(cpu: &cpu) }
#endif

        let cpuCycles = cpu.step(interruptLine: interruptLine)

#if nestest
        nestest.print(ppu: ppu, cycles: cycles)
        cycles &+= cpuCycles
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
        cartridgeDrive.insert(cartridge)
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

public protocol CartridgeDrive {
    func insert(_ cartridge: Cartridge)
}
