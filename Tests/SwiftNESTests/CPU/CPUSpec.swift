import Quick
import Nimble

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {

        describe("fetch") {
            it("read opcode at address indicated by PC") {
                let cpu = CPUEmulator()

                cpu.memory.write(addr: 0x9051, data: 0x90)
                cpu.memory.write(addr: 0x9052, data: 0x3F)
                cpu.memory.write(addr: 0x9053, data: 0x81)
                cpu.memory.write(addr: 0x9054, data: 0x90)

                cpu.registers.PC = 0x9052

                var opcode = cpu.fetch()
                expect(opcode).to(equal(0x3F))

                opcode = cpu.fetch()
                expect(opcode).to(equal(0x81))
            }
        }

        describe("decode") {
            let cpu = CPUEmulator()

            context("If passed opcode is supported") {
                it("select an instruction by opcode") {
                    let instruction = cpu.decode(0x24)
                    expect(instruction.mnemonic).to(equal(.BIT))
                    expect(instruction.addressing).to(equal(.zeroPage))
                    expect(instruction.cycle).to(equal(3))
                }
            }

            context("If passed opcode is not supported") {
                it("return NOP instruction") {
                    let instruction = cpu.decode(0x02)
                    expect(instruction.mnemonic).to(equal(Instruction.NOP.mnemonic))
                    expect(instruction.addressing).to(equal(Instruction.NOP.addressing))
                    expect(instruction.cycle).to(equal(Instruction.NOP.cycle))
                }
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

                cpu.memory.write(addr: 0xFFFB, data: 1)
                cpu.memory.write(addr: 0xFFFC, data: 32)
                cpu.memory.write(addr: 0xFFFD, data: 127)
                cpu.memory.write(addr: 0xFFFE, data: 64)

                _ = cpu.reset()

                expect(cpu.registers.A).to(equal(0x0000))
                expect(cpu.registers.X).to(equal(0x0000))
                expect(cpu.registers.Y).to(equal(0x0000))
                expect(cpu.registers.S).to(equal(0x00FF))
                expect(cpu.registers.P).to(equal([Status.N, Status.V, Status.Z, Status.I]))
                expect(cpu.registers.PC).to(equal(0b0111111100100000))
            }
        }

        describe("stack") {

            it("push data, and pull the same") {
                let cpu = CPUEmulator()
                cpu.registers.S = 0xFF

                cpu.pushStack(data: 0x83)
                cpu.pushStack(data: 0x14)

                expect(cpu.pullStack() as UInt8).to(equal(0x14))
                expect(cpu.pullStack() as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                let cpu = CPUEmulator()
                cpu.registers.S = 0xFF

                cpu.pushStack(word: 0x98AF)
                cpu.pushStack(word: 0x003A)

                expect(cpu.pullStack() as UInt16).to(equal(0x003A))
                expect(cpu.pullStack() as UInt16).to(equal(0x98AF))
            }
        }
    }
}
