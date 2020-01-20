import Foundation

struct NESTest {
    let disassembler: Disassembler
    let interruptLine: InterruptLine

    var cpu: CPU! = nil
    var enabled: Bool = false

    var machineCode: String = ""
    var assemblyCode: String = ""

    init(disassembler: Disassembler, interruptLine: InterruptLine) {
        self.disassembler = disassembler
        self.interruptLine = interruptLine
    }

    mutating func before(cpu: inout CPU) {
        enabled = !interruptLine.interrupted
        if enabled {
            (machineCode, assemblyCode) = disassembler.disassemble(cpu: &cpu)
            self.cpu = cpu
        }
    }

    func print(ppu: PPU, cycles: UInt) {
        if enabled {
            let cpuState = "\(machineCode.padding(9))\(assemblyCode.padding(33))\(cpu!.description)"
            let ppuState = String(format: "%3d,%3d", ppu.scan.dot, ppu.scan.line)
            let log = "\(cpu.PC.hex4)  \(cpuState) PPU:\(ppuState) CYC:\(cycles)"
            Swift.print(log)
        }
    }
}

#if nestest
public func nestest(romPath: String) throws {
    let cartridge = try Cartridge(file: try NESFile(path: romPath))

    let nes = makeNES(renderer: DummyRenderer())
    nes.insert(cartridge: cartridge)

    while true {
        nes.step()
        if 26554 < nes.cycles {
            break
        }
    }
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

extension CPU: CustomStringConvertible {
    var description: String {
        return "A:\(A.hex2) X:\(X.hex2) Y:\(Y.hex2) P:\(P.rawValue.hex2) SP:\(S.hex2)"
    }
}
