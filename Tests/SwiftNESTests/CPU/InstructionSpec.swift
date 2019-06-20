import Quick
import Nimble

@testable import SwiftNES

class InstructionSpec: QuickSpec {
    override func spec() {
        describe("LDA") {
            var cpu: CPU!
            beforeEach {
                cpu = CPUEmulator()
            }

            describe("LDA immediate") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA9

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0xF8))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("LDA zeroPage") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA5

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x00F8, data: 0x93)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("LDA zeroPage, X") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB5

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0087, data: 0x93)
                    cpu.registers.PC = 0x0302
                    cpu.registers.X = 0x8F

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("LDA absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAD

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0304, data: 0x07)
                    cpu.memory.write(addr: 0x07F8, data: 0x51)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x51))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("LDA absoluteX") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xBD

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0304, data: 0x07)
                    cpu.memory.write(addr: 0x07FA, data: 0x51)
                    cpu.registers.PC = 0x0302
                    cpu.registers.X = 0x02

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x51))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("LDA absoluteY") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB9

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0304, data: 0x07)
                    cpu.memory.write(addr: 0x07FA, data: 0x51)
                    cpu.registers.PC = 0x0302
                    cpu.registers.Y = 0x02

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x51))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("LDA indexedIndirect") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA1

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x00FA, data: 0x23)
                    cpu.memory.write(addr: 0x00FB, data: 0x04)
                    cpu.memory.write(addr: 0x0423, data: 0x9F)
                    cpu.registers.PC = 0x0302
                    cpu.registers.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x9F))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("LDA indexedIndirect") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB1

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x40)
                    cpu.memory.write(addr: 0x0040, data: 0x71)
                    cpu.memory.write(addr: 0x0041, data: 0x07)
                    cpu.memory.write(addr: 0x0773, data: 0x93)
                    cpu.registers.PC = 0x0302
                    cpu.registers.Y = 0x02

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(5))
                }
            }
        }
    }
}
