import Quick
import Nimble

@testable import SwiftNES

class AddressingModeSpec: QuickSpec {
    override func spec() {

        describe("CPU.fetchOperand") {
            var cpu: CPU!
            beforeEach {
                cpu = CPU()

                cpu.PC = 0x8234

                cpu.X = 0x05
                cpu.Y = 0x80

                cpu.write(0x90, at: 0x8234)
                cpu.write(0x94, at: 0x8235)
                cpu.write(0x33, at: 0x9490)
                cpu.write(0x81, at: 0x9491)
                cpu.write(0x90, at: 0x8234)
                cpu.write(0x94, at: 0x8235)
                cpu.write(0x33, at: 0x9490)
                cpu.write(0x81, at: 0x9491)
            }

            context("implicit") {
                it("return 0") {
                    let (operand, pc) = cpu.measurePC { CPU.implicit(on: &$0) }
                    expect(operand == 0x00).to(beTruthy())
                    expect(pc).to(equal(0))
                }
            }

            context("accumulator") {
                it("return data on accumulator") {
                    cpu.A = 0xFA

                    let (operand, pc) = cpu.measurePC { CPU.accumulator(on: &$0) }
                    expect(operand).to(equal(0xFA))
                    expect(pc).to(equal(0))
                }
            }

            context("immediate") {
                it("return PC's data directly") {
                    let (operand, pc) = cpu.measurePC { CPU.immediate(on: &$0) }
                    expect(operand).to(equal(0x8234))
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPage") {
                it("return 8 bit operand at addressing by PC on memory") {
                    let (operand, pc) = cpu.measurePC { CPU.zeroPage(on: &$0) }
                    expect(operand).to(equal(0x0090))
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPageX") {
                it("return 8 bit operand at addressing by PC added X on memory") {
                    let (operand, pc) = cpu.measurePC { CPU.zeroPageX(on: &$0) }
                    expect(operand).to(equal(0x95)) // (0x90 + 0x05) & 0xFF
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPageY") {
                it("return 8 bit operand at addressing by PC added Y on memory") {
                    let (operand, pc) = cpu.measurePC { CPU.zeroPageY(on: &$0) }
                    expect(operand).to(equal(0x10)) // (0x90 + 0x80) & 0xFF
                    expect(pc).to(equal(1))
                }
            }

            context("absolute") {
                it("return full 16 bit address") {
                    let (operand, pc) = cpu.measurePC { CPU.absolute(on: &$0) }
                    expect(operand).to(equal(0x9490))
                    expect(pc).to(equal(2))
                }
            }
            context("absoluteX") {
                it("return full 16 bit address added X") {
                    let (operand, pc) = cpu.measurePC { CPU.absoluteX(on: &$0) }
                    expect(operand).to(equal(0x9495))  // 0x9490 + 0x05
                    expect(pc).to(equal(2))
                }
            }
            context("absoluteY") {
                it("return full 16 bit address added Y") {
                    let (operand, pc) = cpu.measurePC { CPU.absoluteY(on: &$0) }
                    expect(operand).to(equal(0x9510))  // 0x9490 + 0x80
                    expect(pc).to(equal(2))
                }
            }

            context("relative") {
                it("return offset") {
                    cpu.PC = 0x50
                    cpu.write(120, at: 0x50)

                    let (operand, pc) = cpu.measurePC { CPU.relative(on: &$0) }
                    expect(operand).to(equal(120))
                    expect(pc).to(equal(1))
                }
            }

            context("indirect") {
                it("return (Indirect) address") {
                    let (operand, pc) = cpu.measurePC { CPU.indirect(on: &$0) }
                    expect(operand).to(equal(0x8133))  // 0x33 + (0x81 << 8)
                    expect(pc).to(equal(2))
                }
            }

            context("indexedIndirect") {
                it("return (Indirect, X) address") {
                    cpu.write(0xFF, at: 0x95)
                    cpu.write(0xF0, at: 0x96)

                    let (operand, pc) = cpu.measurePC { CPU.indexedIndirect(on: &$0) }
                    expect(operand).to(equal(0xF0FF))  // 0xFF + (0xF0 << 8)
                    expect(pc).to(equal(1))
                }
            }

            context("indirectIndexed") {
                it("return (Indirect), Y address") {
                    cpu.write(0x43, at: 0x90)
                    cpu.write(0xC0, at: 0x91)

                    let (operand, pc) = cpu.measurePC { CPU.indirectIndexed(on: &$0) }
                    expect(operand).to(equal(0xC0C3))  // 0xC043 + Y
                    expect(pc).to(equal(1))
                }
            }
        }
    }
}

private extension CPU {

    mutating func measurePC(_ fetchOperand: (inout CPU) -> UInt16) -> (UInt16, UInt16) {
        let pc = PC
        let operand = fetchOperand(&self)
        return (operand, PC - pc)
    }
}
