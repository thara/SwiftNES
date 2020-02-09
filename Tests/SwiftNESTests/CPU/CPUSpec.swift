import Quick
import Nimble

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {
        describe("registers") {
            it("Sync N to bit 7 of A") {
                var cpu = CPU()

                cpu.A = 0b00101111
                expect(cpu.P.contains(.N)).to(beFalsy())

                cpu.A = 0b10101111
                expect(cpu.P.contains(.N)).to(beTruthy())
            }
        }

        describe("fetch") {
            it("read opcode at address indicated by PC") {
                var cpu = CPU()

                cpu.write(0x90, at: 0x9051)
                cpu.write(0x3F, at: 0x9052)
                cpu.write(0x81, at: 0x9053)
                cpu.write(0x90, at: 0x9054)

                cpu.PC = 0x9052

                var opcode = cpu.fetchOperand()
                expect(opcode).to(equal(0x3F))

                opcode = cpu.fetchOperand()
                expect(opcode).to(equal(0x81))
            }
        }

        describe("reset") {
            it("reset registers & memory state") {
                var cpu = CPU()

                cpu.A = 0xFA
                cpu.X = 0x1F
                cpu.Y = 0x59
                cpu.S = 0x37
                cpu.P = [CPU.Status.N, CPU.Status.V]
                cpu.PC = 0b0101011010001101

                cpu.write(1, at: 0xFFFB)
                cpu.write(32, at: 0xFFFC)
                cpu.write(127, at: 0xFFFD)
                cpu.write(64, at: 0xFFFE)

                _ = cpu.reset()

                expect(cpu.A).to(equal(0xFA))
                expect(cpu.X).to(equal(0x1F))
                expect(cpu.Y).to(equal(0x59))
                expect(cpu.S).to(equal(0x34))
                expect(cpu.P).to(equal([CPU.Status.N, CPU.Status.V, CPU.Status.I]))
                expect(cpu.PC).to(equal(0b0111111100100000))
            }
        }

        describe("stack") {

            it("push data, and pull the same") {
                var cpu = CPU()
                cpu.S = 0xFF

                pushStack(0x83, to: &cpu)
                pushStack(0x14, to: &cpu)

                expect(pullStack(from: &cpu) as UInt8).to(equal(0x14))
                expect(pullStack(from: &cpu) as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                var cpu = CPU()
                cpu.S = 0xFF

                pushStack(word: 0x98AF, to: &cpu)
                pushStack(word: 0x003A, to: &cpu)

                expect(pullStack(from: &cpu) as UInt16).to(equal(0x003A))
                expect(pullStack(from: &cpu) as UInt16).to(equal(0x98AF))
            }
        }
    }
}
