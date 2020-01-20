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

    public init(lineBuffer: LineBuffer) {
        interruptLine = InterruptLine()

        let cpuMemoryMap = CPUMemoryMap()
        cpu = CPU(memory: cpuMemoryMap)
        cpuMemory = cpuMemoryMap

        let ppuMemoryMap = PPUMemoryMap()
        ppu = PPU(memory: ppuMemoryMap, interruptLine: interruptLine, lineBuffer: lineBuffer)

        cpuMemoryMap.ppuPort = ppu.port

        controllerPort = ControllerPort()
        cpuMemoryMap.controllerPort = controllerPort

        cartridgeDrive = BusConnectedCartridgeDrive(cpuMemoryMap: cpuMemoryMap, ppuMemoryMap: ppuMemoryMap)

        nestest = NESTest(interruptLine: interruptLine)
    }

    public func runFrame() {
        let currentFrame = ppu.frames

        repeat {
            step()
        } while currentFrame == ppu.frames
    }

    public func step() {
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
            ppu.step()
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
    }

    public func connect(controller1: Controller?, controller2: Controller?) {
        controllerPort.port1 = controller1
        controllerPort.port2 = controller2
    }
}

public protocol CartridgeDrive {
    func insert(_ cartridge: Cartridge)
}
