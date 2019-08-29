import Foundation

struct NESTest {
    let disassembler: Disassembler

    var registers: CPURegisters! = nil
    var enabled: Bool = false

    var machineCode: String = ""
    var assemblyCode: String = ""

    init(disassembler: Disassembler) {
        self.disassembler = disassembler
    }

    mutating func before(cpu: CPU) {
        enabled = !cpu.interrupted
        if enabled {
            (machineCode, assemblyCode) = disassembler.disassemble()
            registers = cpu.registers
        }
    }

    func print(ppu: PPU, cycles: UInt) {
        if enabled {
            let log = String(format: "%04X  %@%@%@ PPU:%3d,%3d CYC:%d",
                   registers.PC,
                   machineCode.padding(9), assemblyCode.padding(33), registers!.description,
                   UInt(ppu.scan.dot), UInt(ppu.scan.line), cycles)
            Swift.print(log)
        }
    }
}

#if nestest
public func nestest(romPath: String) throws {
    let rom = try NESFile(path: romPath)

    guard let cartridge = Cartridge(file: rom) else {
        fatalError("Unsupported mapper")
    }

    let nes = makeNES(renderer: DummyRenderer())
    nes.insert(cartridge: cartridge)

    nes.runFrame()
}

private class DummyRenderer: Renderer {
    func newLine(number: Int, pixels: [UInt32]) {}
}
#endif

fileprivate extension String {
    func padding(_ length: Int) -> String {
        return padding(toLength: length, withPad: " ", startingAt: 0)
    }
}

extension CPURegisters: CustomStringConvertible {
    var description: String {
        return "A:\(A.hex2) X:\(X.hex2) Y:\(Y.hex2) P:\(P.rawValue.hex2) SP:\(S.hex2)"
    }
}
