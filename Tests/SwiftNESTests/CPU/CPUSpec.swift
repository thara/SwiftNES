import Quick
import Nimble

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {

        describe("fetch") {
            it("read opcode at address indicated by PC") {
                let cpu = CPU()
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                memory.write(0x90, at: 0x9051)
                memory.write(0x3F, at: 0x9052)
                memory.write(0x81, at: 0x9053)
                memory.write(0x90, at: 0x9054)

                cpu.registers.PC = 0x9052

                var opcode = CPU.fetch(cpu: cpu, memory: &memory)
                expect(opcode).to(equal(0x3F))

                opcode = CPU.fetch(cpu: cpu, memory: &memory)
                expect(opcode).to(equal(0x81))
            }
        }

        describe("reset") {
            it("reset registers & memory state") {
                let cpu = CPU()
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                cpu.registers = CPURegisters(
                    A: 0xFA,
                    X: 0x1F,
                    Y: 0x59,
                    S: 0x37,
                    P: [Status.N, Status.V],
                    PC: 0b0101011010001101
                )

                memory.write(1, at: 0xFFFB)
                memory.write(32, at: 0xFFFC)
                memory.write(127, at: 0xFFFD)
                memory.write(64, at: 0xFFFE)

                _ = cpu.reset(memory: &memory)

                expect(cpu.registers.A).to(equal(0xFA))
                expect(cpu.registers.X).to(equal(0x1F))
                expect(cpu.registers.Y).to(equal(0x59))
                expect(cpu.registers.S).to(equal(0x34))
                expect(cpu.registers.P).to(equal([Status.N, Status.V, Status.I]))
                expect(cpu.registers.PC).to(equal(0b0111111100100000))
            }
        }

        describe("stack") {

            it("push data, and pull the same") {
                let cpu = CPU()
                cpu.registers.S = 0xFF
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                pushStack(0x83, registers: &cpu.registers, memory: &memory)
                pushStack(0x14, registers: &cpu.registers, memory: &memory)

                expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt8).to(equal(0x14))
                expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                let cpu = CPU()
                cpu.registers.S = 0xFF
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                pushStack(word: 0x98AF, registers: &cpu.registers, memory: &memory)
                pushStack(word: 0x003A, registers: &cpu.registers, memory: &memory)

                expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt16).to(equal(0x003A))
                expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt16).to(equal(0x98AF))
            }
        }
    }
}
