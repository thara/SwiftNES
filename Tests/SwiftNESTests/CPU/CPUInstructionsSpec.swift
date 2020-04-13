import Nimble
import Quick

@testable import SwiftNES

class InstructionSpec: QuickSpec {
    override func spec() {
        var cpu: CPU!
        let interruptLine = InterruptLine()
        beforeEach {
            cpu = CPU()
        }

        describe("LDA") {

            describe("immediate") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA9

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0xF8))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("zeroPage") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA5

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x93, at: 0x00F8)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x93))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, X") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB5

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x93, at: 0x0087)
                    cpu.PC = 0x0302
                    cpu.X = 0x8F

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x93))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAD

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x07, at: 0x0304)
                    cpu.write(0x51, at: 0x07F8)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x51))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteX") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xBD

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x07, at: 0x0304)
                    cpu.write(0x51, at: 0x07FA)
                    cpu.PC = 0x0302
                    cpu.X = 0x02

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x51))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteY") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB9

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x07, at: 0x0304)
                    cpu.write(0x51, at: 0x07FA)
                    cpu.PC = 0x0302
                    cpu.Y = 0x02

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x51))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("indexedIndirect") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA1

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x23, at: 0x00FA)
                    cpu.write(0x04, at: 0x00FB)
                    cpu.write(0x9F, at: 0x0423)
                    cpu.PC = 0x0302
                    cpu.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x9F))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("indirectIndexed") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB1

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x40, at: 0x0303)
                    cpu.write(0x71, at: 0x0040)
                    cpu.write(0x07, at: 0x0041)
                    cpu.write(0x93, at: 0x0773)
                    cpu.PC = 0x0302
                    cpu.Y = 0x02

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x93))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(5))
                }
            }
        }

        describe("LDX") {

            describe("immediate") {
                it("load X register") {
                    let opcode: UInt8 = 0xA2

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.X).to(equal(0xF8))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("zeroPage") {
                it("load X register") {
                    let opcode: UInt8 = 0xA6

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x93, at: 0x00F8)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.X).to(equal(0x93))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, Y") {
                it("load X register") {
                    let opcode: UInt8 = 0xB6

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x93, at: 0x0087)
                    cpu.PC = 0x0302
                    cpu.Y = 0x8F

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.X).to(equal(0x93))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAE

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x07, at: 0x0304)
                    cpu.write(0x51, at: 0x07F8)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.X).to(equal(0x51))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }
        }

        // skip LDY because of similar specifications to LDA or LDX

        describe("STA") {

            describe("zeroPage") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x85

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.PC = 0x0302
                    cpu.A = 0x93

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x00F8)).to(equal(0x93))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, X") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x95

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.PC = 0x0302
                    cpu.A = 0x32
                    cpu.X = 0x8F

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0087)).to(equal(0x32))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x8D

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x07, at: 0x0304)
                    cpu.PC = 0x0302
                    cpu.A = 0x19

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x07F8)).to(equal(0x19))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteX") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x9D

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x07, at: 0x0304)
                    cpu.PC = 0x0302
                    cpu.A = 0x24
                    cpu.X = 0x02

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x07FA)).to(equal(0x24))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("absoluteY") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x99

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x07, at: 0x0304)
                    cpu.write(0x51, at: 0x07FA)
                    cpu.PC = 0x0302
                    cpu.A = 0x23
                    cpu.Y = 0x02

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x07FA)).to(equal(0x23))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("indexedIndirect") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x81

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0xF8, at: 0x0303)
                    cpu.write(0x23, at: 0x00FA)
                    cpu.write(0x04, at: 0x00FB)
                    cpu.write(0x9F, at: 0x0423)
                    cpu.PC = 0x0302
                    cpu.A = 0xF1
                    cpu.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0423)).to(equal(0xF1))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("indirectIndexed") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x91

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x40, at: 0x0303)
                    cpu.write(0x71, at: 0x0040)
                    cpu.write(0x07, at: 0x0041)
                    cpu.write(0x93, at: 0x0773)
                    cpu.PC = 0x0302
                    cpu.A = 0xF2
                    cpu.Y = 0x02

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0773)).to(equal(0xF2))
                    expect(cpu.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }
        }

        // skip STX/STY because of similar specifications to STA

        describe("TAX") {
            describe("implicit") {
                it("transfer Accumulator to X register") {
                    let opcode: UInt8 = 0xAA

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0xF2
                    cpu.X = 0x32

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.X).to(equal(0xF2))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TAY") {
            describe("implicit") {
                it("transfer Accumulator to Y register") {
                    let opcode: UInt8 = 0xA8

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0xF2
                    cpu.Y = 0x32

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.Y).to(equal(0xF2))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TXA") {
            describe("implicit") {
                it("transfer X register to accumulator") {
                    let opcode: UInt8 = 0x8A

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0xF2
                    cpu.X = 0x32

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x32))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TYA") {
            describe("implicit") {
                it("transfer Y register to accumulator") {
                    let opcode: UInt8 = 0x98

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0xF2
                    cpu.Y = 0x32

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0x32))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("PHA") {
            describe("implicit") {
                it("push accumulator to stack") {
                    let opcode: UInt8 = 0x48

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.S = 0xFF
                    cpu.A = 0xF2

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.pullStack() as UInt8).to(equal(0xF2))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PHP") {
            describe("implicit") {
                it("push processor status to stack") {
                    let opcode: UInt8 = 0x08

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.S = 0xFF
                    cpu.P = [.N, .B, .I, .Z, .C]

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(CPU.Status(rawValue: cpu.pullStack())).to(equal([cpu.P, CPU.Status.operatedB] as CPU.Status))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PLA") {
            describe("implicit") {
                it("pull stack and write accumulator") {
                    let opcode: UInt8 = 0x68

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.S = 0xFF
                    cpu.A = 0xF2
                    cpu.pushStack(0xA2)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0xA2))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(4))
                }
            }
        }

        describe("PLP") {
            describe("implicit") {
                it("pull stack and write processor status") {
                    let opcode: UInt8 = 0x28

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.S = 0xFF

                    let status: CPU.Status = [.N, .R, .Z, .C]
                    cpu.pushStack(status.rawValue)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P).to(equal(status))
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(4))
                }
            }
        }

        describe("AND") {
            describe("absolute") {
                it("performe logical AND on the accumulator") {
                    let opcode: UInt8 = 0x2D

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(0b01011100, at: 0x0130)
                    cpu.PC = 0x0302
                    cpu.A = 0b11011011

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0b01011000))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("EOR") {
            describe("absolute") {
                it("performe exclusive OR on the accumulator") {
                    let opcode: UInt8 = 0x4D

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(0b01011100, at: 0x0130)
                    cpu.PC = 0x0302
                    cpu.A = 0b11011011

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0b10000111))
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ORA") {
            describe("absolute") {
                it("performe OR on the accumulator") {
                    let opcode: UInt8 = 0x0D

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(0b01011100, at: 0x0130)
                    cpu.PC = 0x0302
                    cpu.A = 0b11011011

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0b11011111))
                    expect(cpu.PC).to(equal(0x0305))
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

                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x30, at: 0x0303)
                        cpu.write(0x01, at: 0x0304)
                        cpu.write(0b10011100, at: 0x0130)
                        cpu.PC = 0x0302
                        cpu.A = 0b01000011

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.P.contains(.Z)).to(beTruthy())
                        expect(cpu.P.contains(.V)).to(beFalsy())
                        expect(cpu.P.contains(.N)).to(beTruthy())
                        expect(cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("if overflow") {
                    it("set overflow status") {
                        let opcode: UInt8 = 0x2C

                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x30, at: 0x0303)
                        cpu.write(0x01, at: 0x0304)
                        cpu.write(0b01011100, at: 0x0130)
                        cpu.PC = 0x0302
                        cpu.A = 0b11011011

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.P.contains(.Z)).to(beFalsy())
                        expect(cpu.P.contains(.V)).to(beTruthy())
                        expect(cpu.P.contains(.N)).to(beFalsy())
                        expect(cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("if negative") {
                    it("set negative status") {
                        let opcode: UInt8 = 0x2C

                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x30, at: 0x0303)
                        cpu.write(0x01, at: 0x0304)
                        cpu.write(0b10011100, at: 0x0130)
                        cpu.PC = 0x0302
                        cpu.A = 0b10011011

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.P.contains(.Z)).to(beFalsy())
                        expect(cpu.P.contains(.V)).to(beFalsy())
                        expect(cpu.P.contains(.N)).to(beTruthy())
                        expect(cpu.PC).to(equal(0x0305))
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

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(255, at: 0x0130)
                    cpu.PC = 0x0302
                    cpu.A = 12
                    cpu.P.formUnion(.C)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(12))
                    expect(cpu.P.contains(.Z)).to(beFalsy())
                    expect(cpu.P.contains(.V)).to(beFalsy())
                    expect(cpu.P.contains(.N)).to(beFalsy())
                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0305))
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

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(42, at: 0x0130)
                    cpu.PC = 0x0302
                    cpu.A = 30
                    cpu.P.formUnion(.C)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(244))
                    expect(cpu.P.contains(.Z)).to(beFalsy())
                    expect(cpu.P.contains(.V)).to(beFalsy())
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.P.contains(.C)).to(beFalsy())
                    expect(cpu.PC).to(equal(0x0305))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x30, at: 0x0303)
                        cpu.write(0x01, at: 0x0304)
                        cpu.write(97, at: 0x0130)
                        cpu.PC = 0x0302
                        cpu.A = 97

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.P.contains(.C)).to(beTruthy())
                        expect(cpu.P.contains(.Z)).to(beTruthy())
                        expect(cpu.P.contains(.N)).to(beFalsy())
                        expect(cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A >= M") {
                    it("set Zero flag") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x30, at: 0x0303)
                        cpu.write(0x01, at: 0x0304)
                        cpu.write(97, at: 0x0130)
                        cpu.PC = 0x0302
                        cpu.A = 98

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.P.contains(.C)).to(beTruthy())
                        expect(cpu.P.contains(.Z)).to(beFalsy())
                        expect(cpu.P.contains(.N)).to(beFalsy())
                        expect(cpu.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A < M") {
                    it("set Zero flag") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x30, at: 0x0303)
                        cpu.write(0x01, at: 0x0304)
                        cpu.write(97, at: 0x0130)
                        cpu.PC = 0x0302
                        cpu.A = 96

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.P.contains(.C)).to(beFalsy())
                        expect(cpu.P.contains(.Z)).to(beFalsy())
                        expect(cpu.P.contains(.N)).to(beTruthy())
                        expect(cpu.PC).to(equal(0x0305))
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

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(254, at: 0x0130)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0130)).to(equal(255))
                    expect(cpu.P.contains(.Z)).to(beFalsy())
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0305))
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

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(254, at: 0x0130)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0130)).to(equal(253))
                    expect(cpu.P.contains(.Z)).to(beFalsy())
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0305))
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

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0b11001011

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0b10010110))
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("shift left bits on memory") {
                    let opcode: UInt8 = 0x0E

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(0b11101110, at: 0x0130)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0130)).to(equal(0b11011100))
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("LSR") {
            describe("accumulator") {
                it("shift right bits of the accumulator") {
                    let opcode: UInt8 = 0x4A

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0b11001011

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0b01100101))
                    expect(cpu.P.contains(.N)).to(beFalsy())
                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("shift right bits of memory") {
                    let opcode: UInt8 = 0x4E

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(0b11101110, at: 0x0130)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0130)).to(equal(0b01110111))
                    expect(cpu.P.contains(.N)).to(beFalsy())
                    expect(cpu.P.contains(.C)).to(beFalsy())
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ROL") {
            describe("accumulator") {
                it("rotate left") {
                    let opcode: UInt8 = 0x2A

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0b11001011

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0b10010110))
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("rotate left") {
                    let opcode: UInt8 = 0x2E

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(0b11101110, at: 0x0130)
                    cpu.PC = 0x0302
                    cpu.P.formUnion(.C)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0130)).to(equal(0b11011101))
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ROR") {
            describe("accumulator") {
                it("rotate right") {
                    let opcode: UInt8 = 0x6A

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.A = 0b11001011

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.A).to(equal(0b01100101))
                    expect(cpu.P.contains(.N)).to(beFalsy())
                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("rotate right") {
                    let opcode: UInt8 = 0x6E

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.write(0b11101110, at: 0x0130)
                    cpu.PC = 0x0302
                    cpu.P.formUnion(.C)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.read(at: 0x0130)).to(equal(0b11110111))
                    expect(cpu.P.contains(.N)).to(beTruthy())
                    expect(cpu.P.contains(.C)).to(beFalsy())
                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("JMP") {
            describe("absolute") {
                it("jump") {
                    let opcode: UInt8 = 0x4C

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.PC = 0x0302

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.PC).to(equal(0x0130))
                    expect(cycle).to(equal(3))
                }
            }
            // skip other addressing mode because of similar specifications to the above.
        }

        describe("JSR") {
            describe("implicit") {
                it("jump to subroutine") {
                    let opcode: UInt8 = 0x20

                    cpu.write(opcode, at: 0x0302)
                    cpu.write(0x30, at: 0x0303)
                    cpu.write(0x01, at: 0x0304)
                    cpu.PC = 0x0302
                    cpu.S = 0xFF

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.PC).to(equal(0x0130))
                    expect(cpu.pullStack() as UInt16).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("RTS") {
            describe("implicit") {
                it("return from subroutine") {
                    let opcode: UInt8 = 0x60

                    cpu.write(opcode, at: 0x0130)
                    cpu.PC = 0x0130
                    cpu.S = 0xFF
                    cpu.pushStack(word: 0x0304)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("RTI") {
            describe("implicit") {
                it("return from interrupt") {
                    let opcode: UInt8 = 0x40

                    cpu.write(opcode, at: 0x0130)
                    cpu.PC = 0x0130
                    cpu.S = 0xFF

                    cpu.pushStack(word: 0x0401)
                    let status: CPU.Status = [.N, .Z, .C]
                    cpu.pushStack(status.rawValue)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.PC).to(equal(0x0401))
                    expect(cpu.P.rawValue).to(equal(status.rawValue | 0x20))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("BCC") {
            describe("relative") {
                let opcode: UInt8 = 0x90

                context("if carray flag is clear") {
                    it("add the relative displacement to the PC") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.C)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if carray flag is set") {
                    it("NOP") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.C)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.C)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if carray flag is set") {
                    it("add the relative displacement to the PC") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.C)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.Z)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if zero flag is set") {
                    it("add the relative displacement to the PC") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.Z)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.N)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if negative flag is set") {
                    it("add the relative displacement to the PC") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.N)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.Z)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if zero flag is set") {
                    it("NOP") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.Z)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.N)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if negative flag is set") {
                    it("NOP") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.N)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.V)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if overflow flag is set") {
                    it("NOP") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.V)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
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
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.remove(.V)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if overflow flag is set") {
                    it("add the relative displacement to the PC") {
                        cpu.write(opcode, at: 0x0302)
                        cpu.write(0x03, at: 0x0303)
                        cpu.PC = 0x0302
                        cpu.P.formUnion(.V)

                        let cycle = cpu.step(interruptLine: interruptLine)

                        expect(cpu.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }
            }
        }

        describe("CLC") {
            describe("implicit") {
                it("clear carry flag") {
                    let opcode: UInt8 = 0x18

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.P.formUnion(.C)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P.contains(.C)).to(beFalsy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLD") {
            describe("implicit") {
                it("clear decimal mode") {
                    let opcode: UInt8 = 0xD8

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.P.formUnion(.D)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P.contains(.D)).to(beFalsy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLI") {
            describe("implicit") {
                it("clear interrupt disable") {
                    let opcode: UInt8 = 0x58

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.P.formUnion(.I)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P.contains(.I)).to(beFalsy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLV") {
            describe("implicit") {
                it("clear overflow flag") {
                    let opcode: UInt8 = 0xB8

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.P.formUnion(.V)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P.contains(.V)).to(beFalsy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SEC") {
            describe("implicit") {
                it("set carray flag") {
                    let opcode: UInt8 = 0x38

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.P.remove(.C)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P.contains(.C)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SED") {
            describe("implicit") {
                it("set decimal flag") {
                    let opcode: UInt8 = 0xF8

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.P.remove(.D)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P.contains(.D)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SEI") {
            describe("implicit") {
                it("set interrupt disable") {
                    let opcode: UInt8 = 0x78

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.P.remove(.I)

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.P.contains(.I)).to(beTruthy())
                    expect(cpu.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("BRK") {
            describe("implicit") {
                it("force interrupt") {
                    let opcode: UInt8 = 0x00

                    cpu.write(0x70, at: 0xFFFE)
                    cpu.write(0x81, at: 0xFFFF)

                    cpu.write(opcode, at: 0x0302)
                    cpu.PC = 0x0302
                    cpu.S = 0xFF

                    let status: CPU.Status = [.N, .R, .Z, .C]
                    cpu.P = status

                    let cycle = cpu.step(interruptLine: interruptLine)

                    expect(cpu.PC).to(equal(0x8170))
                    expect(cpu.pullStack() as UInt8).to(equal(status.rawValue | CPU.Status.interruptedB.rawValue))
                    expect(cpu.pullStack() as UInt16).to(equal(0x0303))
                    expect(cycle).to(equal(7))
                }
            }
        }
    }
}
