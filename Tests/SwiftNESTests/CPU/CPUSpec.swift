import Quick
import Nimble

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {
        describe("registers") {
            it("Sync N to bit 7 of A") {
                var reg = CPU(A: 0, X: 0, Y: 0, S: 0, P: [], PC: 0)

                reg.A = 0b00101111
                expect(reg.P.contains(.N)).to(beFalsy())

                reg.A = 0b10101111
                expect(reg.P.contains(.N)).to(beTruthy())
            }
        }

        describe("fetch") {
            it("read opcode at address indicated by PC") {
                var cpu = CPU()
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                memory.write(0x90, at: 0x9051)
                memory.write(0x3F, at: 0x9052)
                memory.write(0x81, at: 0x9053)
                memory.write(0x90, at: 0x9054)

                cpu.PC = 0x9052

                var opcode = cpu.fetch(from: &memory)
                expect(opcode).to(equal(0x3F))

                opcode = cpu.fetch(from: &memory)
                expect(opcode).to(equal(0x81))
            }
        }

        describe("reset") {
            it("reset registers & memory state") {
                var cpu = CPU()
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                cpu = CPU(
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

                expect(cpu.A).to(equal(0xFA))
                expect(cpu.X).to(equal(0x1F))
                expect(cpu.Y).to(equal(0x59))
                expect(cpu.S).to(equal(0x34))
                expect(cpu.P).to(equal([Status.N, Status.V, Status.I]))
                expect(cpu.PC).to(equal(0b0111111100100000))
            }
        }

        describe("stack") {

            it("push data, and pull the same") {
                var cpu = CPU()
                cpu.S = 0xFF
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                cpu.pushStack(0x83, to: &memory)
                cpu.pushStack(0x14, to: &memory)

                expect(cpu.pullStack(from: &memory) as UInt8).to(equal(0x14))
                expect(cpu.pullStack(from: &memory) as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                var cpu = CPU()
                cpu.S = 0xFF
                var memory: Memory = [UInt8](repeating: 0x00, count: 65536)

                cpu.pushStack(word: 0x98AF, to: &memory)
                cpu.pushStack(word: 0x003A, to: &memory)

                expect(cpu.pullStack(from: &memory) as UInt16).to(equal(0x003A))
                expect(cpu.pullStack(from: &memory) as UInt16).to(equal(0x98AF))
            }
        }
    }
}
