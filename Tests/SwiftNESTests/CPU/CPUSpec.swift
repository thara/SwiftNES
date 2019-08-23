import Quick
import Nimble

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {

        describe("fetch") {
            it("read opcode at address indicated by PC") {
                let cpu = CPU()

                cpu.memory.write(0x90, at: 0x9051)
                cpu.memory.write(0x3F, at: 0x9052)
                cpu.memory.write(0x81, at: 0x9053)
                cpu.memory.write(0x90, at: 0x9054)

                cpu.registers.PC = 0x9052

                var opcode = cpu.fetch()
                expect(opcode).to(equal(0x3F))

                opcode = cpu.fetch()
                expect(opcode).to(equal(0x81))
            }
        }

        describe("decode") {
            let cpu = CPU()

            context("If passed opcode is supported") {
                it("select an instruction by opcode") {
                    let instruction = cpu.decode(0x24)
                    expect(instruction.mnemonic).to(equal(.BIT))
                    expect(instruction.cycle).to(equal(3))
                }
            }

            context("If passed opcode is not supported") {
                it("return NOP instruction") {
                    let instruction = cpu.decode(0x02)
                    expect(instruction.mnemonic).to(equal(.NOP))
                    expect(instruction.cycle).to(equal(2))
                }
            }
        }

        describe("reset") {
            it("reset registers & memory state") {
                let cpu = CPU()

                cpu.registers = Registers(
                    A: 0xFA,
                    X: 0x1F,
                    Y: 0x59,
                    S: 0x37,
                    P: [Status.N, Status.V],
                    PC: 0b0101011010001101
                )

                cpu.memory.write(1, at: 0xFFFB)
                cpu.memory.write(32, at: 0xFFFC)
                cpu.memory.write(127, at: 0xFFFD)
                cpu.memory.write(64, at: 0xFFFE)

                _ = cpu.reset()

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

                cpu.pushStack(0x83)
                cpu.pushStack(0x14)

                expect(cpu.pullStack() as UInt8).to(equal(0x14))
                expect(cpu.pullStack() as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                let cpu = CPU()
                cpu.registers.S = 0xFF

                cpu.pushStack(word: 0x98AF)
                cpu.pushStack(word: 0x003A)

                expect(cpu.pullStack() as UInt16).to(equal(0x003A))
                expect(cpu.pullStack() as UInt16).to(equal(0x98AF))
            }
        }
    }
}
