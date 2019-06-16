import Quick
import Nimble

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {

        describe("fetch") {
            it("read opcode at address indicated by PC") {
                let cpu = CPUEmulator()

                var mem: [UInt8] = Array(repeating: 0, count: 0x4000)
                mem[0x9051 - 0x8000] = 0x90
                mem[0x9052 - 0x8000] = 0x3F
                mem[0x9053 - 0x8000] = 0x81
                mem[0x9054 - 0x8000] = 0x90
                cpu.memory.loadProgram(index: 0, data: mem)

                cpu.registers.PC = 0x9052

                var opcode = cpu.fetch()
                expect(opcode).to(equal(0x3F))

                opcode = cpu.fetch()
                expect(opcode).to(equal(0x81))
            }
        }

        describe("reset") {
            it("reset registers & memory state") {
                let cpu = CPUEmulator()

                cpu.registers = Registers(
                    A: 0xFA,
                    X: 0x1F,
                    Y: 0x59,
                    S: 0x37,
                    P: [Status.N, Status.V],
                    PC: 0b0101011010001101
                )

                let program1: [UInt8] = Array(repeating: 0, count: 0x4000)
                cpu.memory.loadProgram(index: 0, data: program1)

                var program2: [UInt8]  = Array(repeating: 0, count: 0x4000)
                program2[0xFFFB - 0xC000] = 1
                program2[0xFFFC - 0xC000] = 32
                program2[0xFFFD - 0xC000] = 127
                program2[0xFFFE - 0xC000] = 64
                cpu.memory.loadProgram(index: 1, data: program2)

                cpu.reset()

                expect(cpu.registers.A).to(equal(0x0000))
                expect(cpu.registers.X).to(equal(0x0000))
                expect(cpu.registers.Y).to(equal(0x0000))
                expect(cpu.registers.S).to(equal(0x00FF))
                expect(cpu.registers.P).to(equal([Status.N, Status.V]))
                expect(cpu.registers.PC).to(equal(0b0111111100100000))
            }
        }
    }
}
