public final class NES {
    private let cpu: CPU
    private let ppu: PPU

    private let cartridgeDrive: CartridgeDrive
    private let controllerPort: ControllerPort

    public static let maxDot = 341
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    init(cpu: CPU, ppu: PPU, cartridgeDrive: CartridgeDrive, controllerPort: ControllerPort) {
        self.cpu = cpu
        self.ppu = ppu
        self.cartridgeDrive = cartridgeDrive
        self.controllerPort = controllerPort
    }

    public func runFrame() {
        let currentFrame = ppu.frames

        repeat {
            cycle()
        } while currentFrame == ppu.frames
    }

    public func cycle() {
        let cpuCycles = cpu.step()

        var ppuCycles = cpuCycles &* 3
        while 0 < ppuCycles {
            ppu.step()
            ppuCycles &-= 1
        }
    }

    public func insert(cartridge: Cartridge) {
        cartridgeDrive.insert(cartridge)
        cpu.powerOn()
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
