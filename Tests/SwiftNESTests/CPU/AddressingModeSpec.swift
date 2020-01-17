import Quick
import Nimble

@testable import SwiftNES

class AddressingModeSpec: QuickSpec {
    override func spec() {

        describe("CPU.fetchOperand") {
            var nes: NES!
            beforeEach {
                nes = NES()
                nes.cpu.PC = 0x8234

                nes.cpu.X = 0x05
                nes.cpu.Y = 0x80

                write(0x90, at: 0x8234, to: &nes)
                write(0x94, at: 0x8235, to: &nes)
                write(0x33, at: 0x9490, to: &nes)
                write(0x81, at: 0x9491, to: &nes)
                write(0x90, at: 0x8234, to: &nes)
                write(0x94, at: 0x8235, to: &nes)
                write(0x33, at: 0x9490, to: &nes)
                write(0x81, at: 0x9491, to: &nes)
            }

            context("implicit") {
                it("return 0") {
                    let (operand, pc) = measurePC(&nes, implicit)
                    expect(operand == 0x00).to(beTruthy())
                    expect(pc).to(equal(0))
                }
            }

            context("accumulator") {
                it("return data on accumulator") {
                    nes.cpu.A = 0xFA

                    let (operand, pc) = measurePC(&nes, accumulator)
                    expect(operand).to(equal(0xFA))
                    expect(pc).to(equal(0))
                }
            }

            context("immediate") {
                it("return PC's data directly") {
                    let (operand, pc) = measurePC(&nes, immediate)
                    expect(operand).to(equal(0x8234))
                    expect(pc).to(equal(1))
                }
            }

            // context("zeroPage") {
            //     it("return 8 bit operand at addressing by PC on memory") {
            //         let (operand, pc) = measurePC(&nes, zeroPage)
            //         expect(operand).to(equal(0x0090))
            //         expect(pc).to(equal(1))
            //     }
            // }

            // context("zeroPageX") {
            //     it("return 8 bit operand at addressing by PC added X on memory") {
            //         let (operand, pc) = measurePC(&nes, zeroPageX)
            //         expect(operand).to(equal(0x95)) // (0x90 + 0x05) & 0xFF
            //         expect(pc).to(equal(1))
            //     }
            // }

            // context("zeroPageY") {
            //     it("return 8 bit operand at addressing by PC added Y on memory") {
            //         let (operand, pc) = measurePC(&nes, zeroPageY)
            //         expect(operand).to(equal(0x10)) // (0x90 + 0x80) & 0xFF
            //         expect(pc).to(equal(1))
            //     }
            // }

            // context("absolute") {
            //     it("return full 16 bit address") {
            //         let (operand, pc) = measurePC(&nes, absolute)
            //         expect(operand).to(equal(0x9490))
            //         expect(pc).to(equal(2))
            //     }
            // }
            // context("absoluteX") {
            //     it("return full 16 bit address added X") {
            //         let (operand, pc) = measurePC(&nes, absoluteX)
            //         expect(operand).to(equal(0x9495))  // 0x9490 + 0x05
            //         expect(pc).to(equal(2))
            //     }
            // }
            // context("absoluteY") {
            //     it("return full 16 bit address added Y") {
            //         let (operand, pc) = measurePC(&nes, absoluteY)
            //         expect(operand).to(equal(0x9510))  // 0x9490 + 0x80
            //         expect(pc).to(equal(2))
            //     }
            // }

            context("relative") {
                it("return offset") {
                    nes.cpu.PC = 0x50
                    write(120, at: 0x50, to: &nes)

                    let (operand, pc) = measurePC(&nes, relative)
                    expect(operand).to(equal(120))
                    expect(pc).to(equal(1))
                }
            }

            // context("indirect") {
            //     it("return (Indirect) address") {
            //         let (operand, pc) = measurePC(&nes, indirect)
            //         expect(operand).to(equal(0x8133))  // 0x33 + (0x81 << 8)
            //         expect(pc).to(equal(2))
            //     }
            // }

            // context("indexedIndirect") {
            //     it("return (Indirect, X) address") {
            //         write(0xFF, at: 0x95, to: &nes)
            //         write(0xF0, at: 0x96, to: &nes)

            //         let (operand, pc) = measurePC(&nes, indexedIndirect)
            //         expect(operand).to(equal(0xF0FF))  // 0xFF + (0xF0 << 8)
            //         expect(pc).to(equal(1))
            //     }
            // }

            // context("indirectIndexed") {
            //     it("return (Indirect), Y address") {
            //         write(0x43, at: 0x90, to: &nes)
            //         write(0xC0, at: 0x91, to: &nes)

            //         let (operand, pc) = measurePC(&nes, indirectIndexed)
            //         expect(operand).to(equal(0xC0C3))  // 0xC043 + Y
            //         expect(pc).to(equal(1))
            //     }
            // }
        }
    }
}

func measurePC(_ nes: inout NES, _ fetchOperand: (inout NES) -> UInt16) -> (UInt16, UInt16) {
    let pc = nes.cpu.PC
    let operand = fetchOperand(&nes)
    return (operand, nes.cpu.PC - pc)
}
