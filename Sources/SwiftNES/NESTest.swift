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

    func print() {
        if enabled {
            let log = "\(registers.PC.hex4)  \(machineCode.padding(9))\(assemblyCode.padding(33))\(registers!)"
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
