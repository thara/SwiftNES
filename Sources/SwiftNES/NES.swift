public class NES {
    let cpu: CPU
    let ppu: PPU

    public let cartridgeDrive: CartridgeDrive

    init(cpu: CPU, ppu: PPU, cartridgeDrive: CartridgeDrive) {
        self.cpu = cpu
        self.ppu = ppu
        self.cartridgeDrive = cartridgeDrive
    }

    public func cycle() {
        let cpuCycles = cpu.step()
        for _ in 0..<(cpuCycles * 3) {
            ppu.step()
        }
    }
}

public protocol CartridgeDrive {
    func insert(_ cartridge: Cartridge)
}
