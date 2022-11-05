import Nimble
import Quick

@testable import SwiftNES

class AddressingModeSpec: QuickSpec {
    override func spec() {

        describe("AddressingMode.getOperand") {
            var emu: CPUEmulatorStub!
            beforeEach {
                emu = CPUEmulatorStub()

                emu.cpu.PC = 0x8234

                emu.cpu.X = 0x05
                emu.cpu.Y = 0x80

                emu.write(0x90, at: 0x8234)
                emu.write(0x94, at: 0x8235)
                emu.write(0x33, at: 0x9490)
                emu.write(0x81, at: 0x9491)
                emu.write(0x90, at: 0x8234)
                emu.write(0x94, at: 0x8235)
                emu.write(0x33, at: 0x9490)
                emu.write(0x81, at: 0x9491)
            }

            context("implicit") {
                it("return 0") {
                    let (operand, pc) = emu.measurePC(.implicit)
                    expect(operand == 0x00).to(beTruthy())
                    expect(pc).to(equal(0))
                }
            }

            context("accumulator") {
                it("return data on accumulator") {
                    emu.cpu.A = 0xFA

                    let (operand, pc) = emu.measurePC(.accumulator)
                    expect(operand).to(equal(0xFA))
                    expect(pc).to(equal(0))
                }
            }

            context("immediate") {
                it("return PC's data directly") {
                    let (operand, pc) = emu.measurePC(.immediate)
                    expect(operand).to(equal(0x8234))
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPage") {
                it("return 8 bit operand at addressing by PC on memory") {
                    let (operand, pc) = emu.measurePC(.zeroPage)
                    expect(operand).to(equal(0x0090))
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPageX") {
                it("return 8 bit operand at addressing by PC added X on memory") {
                    let (operand, pc) = emu.measurePC(.zeroPageX)
                    expect(operand).to(equal(0x95))  // (0x90 + 0x05) & 0xFF
                    expect(pc).to(equal(1))
                }
            }

            context("zeroPageY") {
                it("return 8 bit operand at addressing by PC added Y on memory") {
                    let (operand, pc) = emu.measurePC(.zeroPageY)
                    expect(operand).to(equal(0x10))  // (0x90 + 0x80) & 0xFF
                    expect(pc).to(equal(1))
                }
            }

            context("absolute") {
                it("return full 16 bit address") {
                    let (operand, pc) = emu.measurePC(.absolute)
                    expect(operand).to(equal(0x9490))
                    expect(pc).to(equal(2))
                }
            }
            context("absoluteX") {
                it("return full 16 bit address added X") {
                    let (operand, pc) = emu.measurePC(.absoluteX(penalty: false))
                    expect(operand).to(equal(0x9495))  // 0x9490 + 0x05
                    expect(pc).to(equal(2))
                }
            }
            context("absoluteY") {
                it("return full 16 bit address added Y") {
                    let (operand, pc) = emu.measurePC(.absoluteY(penalty: false))
                    expect(operand).to(equal(0x9510))  // 0x9490 + 0x80
                    expect(pc).to(equal(2))
                }
            }

            context("relative") {
                it("return offset") {
                    emu.cpu.PC = 0x50
                    emu.write(120, at: 0x50)

                    let (operand, pc) = emu.measurePC(.relative)
                    expect(operand).to(equal(120))
                    expect(pc).to(equal(1))
                }
            }

            context("indirect") {
                it("return (Indirect) address") {
                    let (operand, pc) = emu.measurePC(.indirect)
                    expect(operand).to(equal(0x8133))  // 0x33 + (0x81 << 8)
                    expect(pc).to(equal(2))
                }
            }

            context("indexedIndirect") {
                it("return (Indirect, X) address") {
                    emu.write(0xFF, at: 0x95)
                    emu.write(0xF0, at: 0x96)

                    let (operand, pc) = emu.measurePC(.indexedIndirect)
                    expect(operand).to(equal(0xF0FF))  // 0xFF + (0xF0 << 8)
                    expect(pc).to(equal(1))
                }
            }

            context("indirectIndexed") {
                it("return (Indirect), Y address") {
                    emu.write(0x43, at: 0x90)
                    emu.write(0xC0, at: 0x91)

                    let (operand, pc) = emu.measurePC(.indirectIndexed)
                    expect(operand).to(equal(0xC0C3))  // 0xC043 + Y
                    expect(pc).to(equal(1))
                }
            }
        }
    }
}

extension CPUEmulator {
    fileprivate func measurePC(_ m: AddressingMode) -> (UInt16, UInt16) {
        let pc = cpu.PC
        let operand = getOperand(by: m)
        return (operand, cpu.PC - pc)
    }
}
