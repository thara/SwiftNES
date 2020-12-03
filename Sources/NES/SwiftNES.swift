public class SwiftNES<L: LineRenderer> {

    var emulator: Emulator<NESMemoryMap, L>

    public init(lineRenderer: L) {
        self.emulator = Emulator(memoryMap: NESMemoryMap.self, lineRenderer: lineRenderer)
    }

    public func insert(cartridge rom: ROM) {
        emulator.insert(cartridge: rom)
    }

    public func connect(controller1: Controller?, controller2: Controller?) {
        emulator.nes.controllers.port1 = controller1
        emulator.nes.controllers.port2 = controller2
    }

    public func runFrame() {
        emulator.runFrame()
    }
}
