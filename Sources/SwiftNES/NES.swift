public struct NES {
    var cpu = CPU()
    let ppu: PPU

    var ppuMemory = PPUMemoryMap()

    var wram = [UInt8](repeating: 0x00, count: 32767)

    var cartridge: Cartridge?
    let cartridgeDrive: CartridgeDrive
    let controllerPort = ControllerPort()

    let interruptLine = InterruptLine()

    public static let maxDot = 340
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    private var nestest: NESTest

    private(set) var cycles: UInt = 0

    public init() {
        let ppuMemoryMap = PPUMemoryMap()
        ppu = PPU(memory: ppuMemoryMap)

        let cpuMemoryMap = CPUMemoryMap()
        cartridgeDrive = BusConnectedCartridgeDrive(cpuMemoryMap: cpuMemoryMap, ppuMemoryMap: ppuMemoryMap)

        nestest = NESTest(disassembler: Disassembler(), interruptLine: interruptLine)
    }

    public mutating func runFrame(render: (Int, inout LineBuffer) -> Void) {
        let currentFrame = ppu.frames

        repeat {
            step(render)
        } while currentFrame == ppu.frames
    }

    public mutating func step(_ render: (Int, inout LineBuffer) -> Void) {
#if nestest
        if !interruptLine.interrupted { nestest.before(cpu: &cpu, memory: &cpuMemory) }
#endif

        let cpuCycles = cpuStep(nes: &self)

#if nestest
        nestest.print(ppu: ppu, cycles: cycles)
        cycles &+= cpuCycles
        if interruptLine.interrupted { return }
#endif

        var ppuCycles = cpuCycles &* 3
        while 0 < ppuCycles {
            let currentLine = ppu.scan.line

            ppu.step(interruptLine: interruptLine)

            if currentLine != ppu.scan.line {
                render(currentLine, &ppu.lineBuffer)
            }

            ppuCycles &-= 1
        }
    }

    public mutating func insert(cartridge: Cartridge) {
        self.cartridge = cartridge
        cartridgeDrive.insert(cartridge)
        cpu.powerOn()

        interruptLine.clear([.NMI, .IRQ])
        interruptLine.send(.RESET)

        wram.fill(0x00)
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
