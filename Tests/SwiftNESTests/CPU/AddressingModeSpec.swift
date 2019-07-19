import Quick
import Nimble

@testable import SwiftNES

class AddressingModeSpec: QuickSpec {
    override func spec() {

        describe("CPU.fetchOperand") {
            var cpu: CPU!
            beforeEach {
                cpu = CPUEmulator()

                cpu.registers.PC = 0x8234

                cpu.registers.X = 0x05
                cpu.registers.Y = 0x80

                cpu.memory.write(addr: 0x8234, data: 0x90)
                cpu.memory.write(addr: 0x8235, data: 0x94)
                cpu.memory.write(addr: 0x9490, data: 0x33)
                cpu.memory.write(addr: 0x9491, data: 0x81)
                cpu.memory.write(addr: 0x8234, data: 0x90)
                cpu.memory.write(addr: 0x8235, data: 0x94)
                cpu.memory.write(addr: 0x9490, data: 0x33)
                cpu.memory.write(addr: 0x9491, data: 0x81)
            }

            context("implicit") {
                it("return nil") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .implicit)
                    expect(operand == nil).to(beTruthy())
                    expect(pc).to(equal(0))
                }
            }

            context("accumulator") {
                it("return data on accumulator") {
                    cpu.registers.A = 0xFA

                    let (operand, pc) = cpu.fetchOperand(addressingMode: .accumulator)
                    expect(operand).to(equal(0xFA))
                    expect(pc).to(equal(0))
                }
            }

            context("immediate") {
                it("return PC's data directly") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .immediate)
                    expect(operand).to(equal(0x8234))
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPage") {
                it("return 8 bit operand at addressing by PC on memory") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .zeroPage)
                    expect(operand).to(equal(0x0090))
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPageX") {
                it("return 8 bit operand at addressing by PC added X on memory") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .zeroPageX)
                    expect(operand).to(equal(0x95)) // (0x90 + 0x05) & 0xFF
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPageY") {
                it("return 8 bit operand at addressing by PC added Y on memory") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .zeroPageY)
                    expect(operand).to(equal(0x10)) // (0x90 + 0x80) & 0xFF
                    expect(pc).to(equal(1))
                }
            }

            context("absolute") {
                it("return full 16 bit address") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .absolute)
                    expect(operand).to(equal(0x9490))
                    expect(pc).to(equal(2))
                }
            }
            context("absoluteX") {
                it("return full 16 bit address added X") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .absoluteX)
                    expect(operand).to(equal(0x9495))  // 0x9490 + 0x05
                    expect(pc).to(equal(2))
                }
            }
            context("absoluteY") {
                it("return full 16 bit address added Y") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .absoluteY)
                    expect(operand).to(equal(0x9510))  // 0x9490 + 0x80
                    expect(pc).to(equal(2))
                }
            }

            context("relative") {
                it("return offset") {
                    cpu.registers.PC = 0x50
                    cpu.memory.write(addr: 0x50, data: 120)

                    let (operand, pc) = cpu.fetchOperand(addressingMode: .relative)
                    expect(operand).to(equal(120))
                    expect(pc).to(equal(1))
                }
            }

            context("indirect") {
                it("return (Indirect) address") {
                    let (operand, pc) = cpu.fetchOperand(addressingMode: .indirect)
                    expect(operand).to(equal(0x8133))  // 0x33 + (0x81 << 8)
                    expect(pc).to(equal(2))
                }
            }

            context("indexedIndirect") {
                it("return (Indirect, X) address") {
                    cpu.memory.write(addr: 0x95, data: 0xFF)
                    cpu.memory.write(addr: 0x96, data: 0xF0)

                    let (operand, pc) = cpu.fetchOperand(addressingMode: .indexedIndirect)
                    expect(operand).to(equal(0xF0FF))  // 0xFF + (0xF0 << 8)
                    expect(pc).to(equal(1))
                }
            }

            context("indirectIndexed") {
                it("return (Indirect), Y address") {
                    cpu.memory.write(addr: 0x90, data: 0x43)
                    cpu.memory.write(addr: 0x91, data: 0xC0)

                    let (operand, pc) = cpu.fetchOperand(addressingMode: .indirectIndexed)
                    expect(operand).to(equal(0xC0C3))  // 0xC043 + Y
                    expect(pc).to(equal(1))
                }
            }
        }
    }
}
