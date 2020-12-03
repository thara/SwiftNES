public class SwiftNES<L: LineRenderer, A: AudioBuffer> {

    var emulator: Emulator<NESMemoryMap, L, A>

    public init(lineRenderer: L, audioBuffer: A) {
        self.emulator = Emulator(memoryMap: NESMemoryMap.self, lineRenderer: lineRenderer, audioBuffer: audioBuffer)
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
