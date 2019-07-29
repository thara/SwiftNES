public final class NES {
    let cpu: CPU
    private let ppu: PPU

    private let cartridgeDrive: CartridgeDrive

    public static let maxDot = 341
    public static let maxLine = 261

    public static let height = 240
    public static let width = 256

    static let totalCycles = 29781

    init(cpu: CPU, ppu: PPU, cartridgeDrive: CartridgeDrive) {
        self.cpu = cpu
        self.ppu = ppu
        self.cartridgeDrive = cartridgeDrive
    }

    public func runFrame() {
        var cycles = NES.totalCycles

        while 0 < cycles {
            cycle()
            cycles &-= 1
        }
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
}

public protocol CartridgeDrive {
    func insert(_ cartridge: Cartridge)
}
