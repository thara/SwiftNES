import Quick
import Nimble

@testable import SwiftNES

class InstructionSpec: QuickSpec {
    override func spec() {
        var nes: NES!
        beforeEach {
            nes = NES()
        }

        describe("LDA") {

            describe("immediate") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA9

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0xF8))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("zeroPage") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA5

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x93, at: 0x00F8, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x93))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, X") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB5

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x93, at: 0x0087, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.X = 0x8F

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x93))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAD

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x07, at: 0x0304, to: &nes)
                    write(0x51, at: 0x07F8, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x51))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteX") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xBD

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x07, at: 0x0304, to: &nes)
                    write(0x51, at: 0x07FA, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.X = 0x02

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x51))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteY") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB9

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x07, at: 0x0304, to: &nes)
                    write(0x51, at: 0x07FA, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.Y = 0x02

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x51))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("indexedIndirect") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA1

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x23, at: 0x00FA, to: &nes)
                    write(0x04, at: 0x00FB, to: &nes)
                    write(0x9F, at: 0x0423, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x9F))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("indirectIndexed") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB1

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x40, at: 0x0303, to: &nes)
                    write(0x71, at: 0x0040, to: &nes)
                    write(0x07, at: 0x0041, to: &nes)
                    write(0x93, at: 0x0773, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.Y = 0x02

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x93))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(5))
                }
            }
        }

        describe("LDX") {

            describe("immediate") {
                it("load X register") {
                    let opcode: UInt8 = 0xA2

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.X).to(equal(0xF8))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("zeroPage") {
                it("load X register") {
                    let opcode: UInt8 = 0xA6

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x93, at: 0x00F8, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.X).to(equal(0x93))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, Y") {
                it("load X register") {
                    let opcode: UInt8 = 0xB6

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x93, at: 0x0087, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.Y = 0x8F

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.X).to(equal(0x93))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAE

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x07, at: 0x0304, to: &nes)
                    write(0x51, at: 0x07F8, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.X).to(equal(0x51))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }
        }

        // skip LDY because of similar specifications to LDA or LDX

        describe("STA") {

            describe("zeroPage") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x85

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0x93

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x00F8, from: &nes)).to(equal(0x93))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, X") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x95

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0x32
                    nes.cpu.X = 0x8F

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0087, from: &nes)).to(equal(0x32))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x8D

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x07, at: 0x0304, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0x19

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x07F8, from: &nes)).to(equal(0x19))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteX") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x9D

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x07, at: 0x0304, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0x24
                    nes.cpu.X = 0x02

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x07FA, from: &nes)).to(equal(0x24))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("absoluteY") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x99

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x07, at: 0x0304, to: &nes)
                    write(0x51, at: 0x07FA, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0x23
                    nes.cpu.Y = 0x02

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x07FA, from: &nes)).to(equal(0x23))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("indexedIndirect") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x81

                    write(opcode, at: 0x0302, to: &nes)
                    write(0xF8, at: 0x0303, to: &nes)
                    write(0x23, at: 0x00FA, to: &nes)
                    write(0x04, at: 0x00FB, to: &nes)
                    write(0x9F, at: 0x0423, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0xF1
                    nes.cpu.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0423, from: &nes)).to(equal(0xF1))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("indirectIndexed") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x91

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x40, at: 0x0303, to: &nes)
                    write(0x71, at: 0x0040, to: &nes)
                    write(0x07, at: 0x0041, to: &nes)
                    write(0x93, at: 0x0773, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0xF2
                    nes.cpu.Y = 0x02

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0773, from: &nes)).to(equal(0xF2))
                    expect(nes.cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }
        }

        // skip STX/STY because of similar specifications to STA

        describe("TAX") {
            describe("implicit") {
                it("transfer Accumulator to X register") {
                    let opcode: UInt8 = 0xAA

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0xF2
                    nes.cpu.X = 0x32

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.X).to(equal(0xF2))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TAY") {
            describe("implicit") {
                it("transfer Accumulator to Y register") {
                    let opcode: UInt8 = 0xA8

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0xF2
                    nes.cpu.Y = 0x32

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.Y).to(equal(0xF2))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TXA") {
            describe("implicit") {
                it("transfer X register to accumulator") {
                    let opcode: UInt8 = 0x8A

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0xF2
                    nes.cpu.X = 0x32

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x32))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TYA") {
            describe("implicit") {
                it("transfer Y register to accumulator") {
                    let opcode: UInt8 = 0x98

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0xF2
                    nes.cpu.Y = 0x32

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0x32))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("PHA") {
            describe("implicit") {
                it("push accumulator to stack") {
                    let opcode: UInt8 = 0x48

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.S = 0xFF
                    nes.cpu.A = 0xF2

                    let cycle = cpuStep(nes: &nes)

                    expect(pullStack(from: &nes) as UInt8).to(equal(0xF2))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PHP") {
            describe("implicit") {
                it("push processor status to stack") {
                    let opcode: UInt8 = 0x08

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.S = 0xFF
                    nes.cpu.P = [.N, .B, .I, .Z, .C]

                    let cycle = cpuStep(nes: &nes)

                    expect(Status(rawValue: pullStack(from: &nes))).to(equal([nes.cpu.P, Status.operatedB] as Status))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PLA") {
            describe("implicit") {
                it("pull stack and write accumulator") {
                    let opcode: UInt8 = 0x68

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.S = 0xFF
                    nes.cpu.A = 0xF2
                    pushStack(0xA2, to: &nes)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0xA2))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(4))
                }
            }
        }

        describe("PLP") {
            describe("implicit") {
                it("pull stack and write processor status") {
                    let opcode: UInt8 = 0x28

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.S = 0xFF

                    let status: Status = [.N, .R, .Z, .C]
                    pushStack(status.rawValue, to: &nes)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P).to(equal(status))
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(4))
                }
            }
        }

        describe("AND") {
            describe("absolute") {
                it("performe logical AND on the accumulator") {
                    let opcode: UInt8 = 0x2D

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(0b01011100, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0b11011011

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0b01011000))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("EOR") {
            describe("absolute") {
                it("performe exclusive OR on the accumulator") {
                    let opcode: UInt8 = 0x4D

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(0b01011100, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0b11011011

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0b10000111))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ORA") {
            describe("absolute") {
                it("performe OR on the accumulator") {
                    let opcode: UInt8 = 0x0D

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(0b01011100, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0b11011011

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0b11011111))
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("BIT") {
            describe("absolute") {

                context("if zero") {
                    it("set zero status") {
                        let opcode: UInt8 = 0x2C

                        write(opcode, at: 0x0302, to: &nes)
                        write(0x30, at: 0x0303, to: &nes)
                        write(0x01, at: 0x0304, to: &nes)
                        write(0b10011100, at: 0x0130, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.A = 0b01000011

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.P.contains(.Z)).to(beTruthy())
                        expect(nes.cpu.P.contains(.V)).to(beFalsy())
                        expect(nes.cpu.P.contains(.N)).to(beTruthy())
                        expect(nes.cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("if overflow") {
                    it("set overflow status") {
                        let opcode: UInt8 = 0x2C

                        write(opcode, at: 0x0302, to: &nes)
                        write(0x30, at: 0x0303, to: &nes)
                        write(0x01, at: 0x0304, to: &nes)
                        write(0b01011100, at: 0x0130, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.A = 0b11011011

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                        expect(nes.cpu.P.contains(.V)).to(beTruthy())
                        expect(nes.cpu.P.contains(.N)).to(beFalsy())
                        expect(nes.cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("if negative") {
                    it("set negative status") {
                        let opcode: UInt8 = 0x2C

                        write(opcode, at: 0x0302, to: &nes)
                        write(0x30, at: 0x0303, to: &nes)
                        write(0x01, at: 0x0304, to: &nes)
                        write(0b10011100, at: 0x0130, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.A = 0b10011011

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                        expect(nes.cpu.P.contains(.V)).to(beFalsy())
                        expect(nes.cpu.P.contains(.N)).to(beTruthy())
                        expect(nes.cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ADC") {
            describe("absolute") {
                it("add with carry") {
                    let opcode: UInt8 = 0x6D

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(255, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 12
                    nes.cpu.P.formUnion(.C)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(12))
                    expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                    expect(nes.cpu.P.contains(.V)).to(beFalsy())
                    expect(nes.cpu.P.contains(.N)).to(beFalsy())
                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("SBC") {
            // TODO more test patterns
            describe("absolute") {
                it("subtract with carry") {
                    let opcode: UInt8 = 0xED

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(42, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 30
                    nes.cpu.P.formUnion(.C)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(244))
                    expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                    expect(nes.cpu.P.contains(.V)).to(beFalsy())
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.P.contains(.C)).to(beFalsy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("CMP") {
            describe("absolute") {
                let opcode: UInt8 = 0xCD

                context("A == M") {
                    it("set Zero flag") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x30, at: 0x0303, to: &nes)
                        write(0x01, at: 0x0304, to: &nes)
                        write(97, at: 0x0130, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.A = 97

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.P.contains(.C)).to(beTruthy())
                        expect(nes.cpu.P.contains(.Z)).to(beTruthy())
                        expect(nes.cpu.P.contains(.N)).to(beFalsy())
                        expect(nes.cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A >= M") {
                    it("set Zero flag") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x30, at: 0x0303, to: &nes)
                        write(0x01, at: 0x0304, to: &nes)
                        write(97, at: 0x0130, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.A = 98

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.P.contains(.C)).to(beTruthy())
                        expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                        expect(nes.cpu.P.contains(.N)).to(beFalsy())
                        expect(nes.cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A < M") {
                    it("set Zero flag") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x30, at: 0x0303, to: &nes)
                        write(0x01, at: 0x0304, to: &nes)
                        write(97, at: 0x0130, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.A = 96

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.P.contains(.C)).to(beFalsy())
                        expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                        expect(nes.cpu.P.contains(.N)).to(beTruthy())
                        expect(nes.cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        // TODO CPX/CPY test

        describe("INC") {
            describe("absolute") {
                it("increment carry") {
                    let opcode: UInt8 = 0xEE

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(254, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0130, from: &nes)).to(equal(255))
                    expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        // skip INX/INY because of similar specifications to the INC.

        describe("DEC") {
            describe("absolute") {
                it("decrement carry") {
                    let opcode: UInt8 = 0xCE

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(254, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0130, from: &nes)).to(equal(253))
                    expect(nes.cpu.P.contains(.Z)).to(beFalsy())
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        // skip DEX/DEY because of similar specifications to the INC.

        describe("ASL") {
            describe("accumulator") {
                it("shift left bits of the accumulator") {
                    let opcode: UInt8 = 0x0A

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0b11001011

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0b10010110))
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("shift left bits on memory") {
                    let opcode: UInt8 = 0x0E

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(0b11101110, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0130, from: &nes)).to(equal(0b11011100))
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("LSR") {
            describe("accumulator") {
                it("shift right bits of the accumulator") {
                    let opcode: UInt8 = 0x4A

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0b11001011

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0b01100101))
                    expect(nes.cpu.P.contains(.N)).to(beFalsy())
                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("shift right bits of memory") {
                    let opcode: UInt8 = 0x4E

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(0b11101110, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0130, from: &nes)).to(equal(0b01110111))
                    expect(nes.cpu.P.contains(.N)).to(beFalsy())
                    expect(nes.cpu.P.contains(.C)).to(beFalsy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ROL") {
            describe("accumulator") {
                it("rotate left") {
                    let opcode: UInt8 = 0x2A

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0b11001011

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0b10010110))
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("rotate left") {
                    let opcode: UInt8 = 0x2E

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(0b11101110, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.formUnion(.C)

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0130, from: &nes)).to(equal(0b11011101))
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ROR") {
            describe("accumulator") {
                it("rotate right") {
                    let opcode: UInt8 = 0x6A

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.A = 0b11001011

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.A).to(equal(0b01100101))
                    expect(nes.cpu.P.contains(.N)).to(beFalsy())
                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("rotate right") {
                    let opcode: UInt8 = 0x6E

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    write(0b11101110, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.formUnion(.C)

                    let cycle = cpuStep(nes: &nes)

                    expect(read(at: 0x0130, from: &nes)).to(equal(0b11110111))
                    expect(nes.cpu.P.contains(.N)).to(beTruthy())
                    expect(nes.cpu.P.contains(.C)).to(beFalsy())
                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("JMP") {
            describe("absolute") {
                it("jump") {
                    let opcode: UInt8 = 0x4C

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    nes.cpu.PC = 0x0302

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.PC).to(equal(0x0130))
                    expect(cycle).to(equal(3))
                }
            }
            // skip other addressing mode because of similar specifications to the above.
        }

        describe("JSR") {
            describe("implicit") {
                it("jump to subroutine") {
                    let opcode: UInt8 = 0x20

                    write(opcode, at: 0x0302, to: &nes)
                    write(0x30, at: 0x0303, to: &nes)
                    write(0x01, at: 0x0304, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.S = 0xFF

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.PC).to(equal(0x0130))
                    expect(pullStack(from: &nes) as UInt16).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("RTS") {
            describe("implicit") {
                it("return from subroutine") {
                    let opcode: UInt8 = 0x60

                    write(opcode, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0130
                    nes.cpu.S = 0xFF
                    pushStack(word: 0x0304, to: &nes)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("RTI") {
            describe("implicit") {
                it("return from interrupt") {
                    let opcode: UInt8 = 0x40

                    write(opcode, at: 0x0130, to: &nes)
                    nes.cpu.PC = 0x0130
                    nes.cpu.S = 0xFF

                    pushStack(word: 0x0401, to: &nes)
                    let status: Status = [.N, .Z, .C]
                    pushStack(status.rawValue, to: &nes)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.PC).to(equal(0x0401))
                    expect(nes.cpu.P.rawValue).to(equal(status.rawValue | 0x20))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("BCC") {
            describe("relative") {
                let opcode: UInt8 = 0x90

                context("if carray flag is clear") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.C)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if carray flag is set") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.C)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }
            }
        }

        describe("BCS") {
            describe("relative") {
                let opcode: UInt8 = 0xB0

                context("if carray flag is clear") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.C)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if carray flag is set") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.C)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }
            }
        }

        describe("BEQ") {
            describe("relative") {
                let opcode: UInt8 = 0xF0

                context("if zero flag is clear") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.Z)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if zero flag is set") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.Z)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }
            }
        }

        describe("BMI") {
            describe("relative") {
                let opcode: UInt8 = 0x30

                context("if negative flag is clear") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.N)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if negative flag is set") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.N)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }
            }
        }

        describe("BNE") {
            describe("relative") {
                let opcode: UInt8 = 0xD0

                context("if zero flag is clear") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.Z)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if zero flag is set") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.Z)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }
            }
        }

        describe("BPL") {
            describe("relative") {
                let opcode: UInt8 = 0x10

                context("if negative flag is clear") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.N)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if negative flag is set") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.N)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }
            }
        }

        describe("BVC") {
            describe("relative") {
                let opcode: UInt8 = 0x50

                context("if overflow flag is clear") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.V)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if overflow flag is set") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.V)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }
            }
        }

        describe("BVS") {
            describe("relative") {
                let opcode: UInt8 = 0x70

                context("if overflow flag is clear") {
                    it("NOP") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.remove(.V)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if overflow flag is set") {
                    it("add the relative displacement to the PC") {
                        write(opcode, at: 0x0302, to: &nes)
                        write(0x03, at: 0x0303, to: &nes)
                        nes.cpu.PC = 0x0302
                        nes.cpu.P.formUnion(.V)

                        let cycle = cpuStep(nes: &nes)

                        expect(nes.cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }
            }
        }

        describe("CLC") {
            describe("implicit") {
                it("clear carry flag") {
                    let opcode: UInt8 = 0x18

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.formUnion(.C)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P.contains(.C)).to(beFalsy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLD") {
            describe("implicit") {
                it("clear decimal mode") {
                    let opcode: UInt8 = 0xD8

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.formUnion(.D)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P.contains(.D)).to(beFalsy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLI") {
            describe("implicit") {
                it("clear interrupt disable") {
                    let opcode: UInt8 = 0x58

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.formUnion(.I)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P.contains(.I)).to(beFalsy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLV") {
            describe("implicit") {
                it("clear overflow flag") {
                    let opcode: UInt8 = 0xB8

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.formUnion(.V)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P.contains(.V)).to(beFalsy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SEC") {
            describe("implicit") {
                it("set carray flag") {
                    let opcode: UInt8 = 0x38

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.remove(.C)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P.contains(.C)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SED") {
            describe("implicit") {
                it("set decimal flag") {
                    let opcode: UInt8 = 0xF8

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.remove(.D)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P.contains(.D)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SEI") {
            describe("implicit") {
                it("set interrupt disable") {
                    let opcode: UInt8 = 0x78

                    write(opcode, at: 0x0302, to: &nes)
                    nes.cpu.PC = 0x0302
                    nes.cpu.P.remove(.I)

                    let cycle = cpuStep(nes: &nes)

                    expect(nes.cpu.P.contains(.I)).to(beTruthy())
                    expect(nes.cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        // describe("BRK") {
        //     describe("implicit") {
        //         it("force interrupt") {
        //             let opcode: UInt8 = 0x00

        //             write(0x70, at: 0xFFFE, to: &nes)
        //             write(0x81, at: 0xFFFF, to: &nes)

        //             write(opcode, at: 0x0302, to: &nes)
        //             nes.cpu.PC = 0x0302
        //             nes.cpu.S = 0xFF

        //             let status: Status = [.N, .R, .Z, .C]
        //             nes.cpu.P = status

        //             let cycle = cpuStep(nes: &nes)

        //             expect(nes.cpu.PC).to(equal(0x8170))
        //             expect(pullStack(from: &nes) as UInt8).to(equal(status.rawValue | Status.interruptedB.rawValue))
        //             expect(pullStack(from: &nes) as UInt16).to(equal(0x0303))
        //             expect(cycle).to(equal(7))
        //         }
        //     }
        // }
    }
}
