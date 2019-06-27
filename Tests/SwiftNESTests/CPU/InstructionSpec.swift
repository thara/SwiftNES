import Quick
import Nimble

@testable import SwiftNES

class InstructionSpec: QuickSpec {
    override func spec() {
        var cpu: CPU!
        beforeEach {
            cpu = CPUEmulator()
        }

        describe("LDA") {

            describe("immediate") {
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

            describe("zeroPage") {
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

            describe("zeroPage, X") {
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

            describe("absolute") {
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

            describe("absoluteX") {
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

            describe("absoluteY") {
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

            describe("indexedIndirect") {
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

            describe("indirectIndexed") {
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

        describe("LDX") {

            describe("immediate") {
                it("load X register") {
                    let opcode: UInt8 = 0xA2

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.registers.X).to(equal(0xF8))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("zeroPage") {
                it("load X register") {
                    let opcode: UInt8 = 0xA6

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x00F8, data: 0x93)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.registers.X).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, Y") {
                it("load X register") {
                    let opcode: UInt8 = 0xB6

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0087, data: 0x93)
                    cpu.registers.PC = 0x0302
                    cpu.registers.Y = 0x8F

                    let cycle = cpu.run()

                    expect(cpu.registers.X).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAE

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0304, data: 0x07)
                    cpu.memory.write(addr: 0x07F8, data: 0x51)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.registers.X).to(equal(0x51))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }
        }

        // skip LDY because of similar specifications to LDA or LDX

        describe("STA") {

            describe("zeroPage") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x85

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x93

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x00F8)).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, X") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x95

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x32
                    cpu.registers.X = 0x8F

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0087)).to(equal(0x32))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x8D

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0304, data: 0x07)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x19

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x07F8)).to(equal(0x19))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteX") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x9D

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0304, data: 0x07)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x24
                    cpu.registers.X = 0x02

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x07FA)).to(equal(0x24))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("absoluteY") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x99

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x0304, data: 0x07)
                    cpu.memory.write(addr: 0x07FA, data: 0x51)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x23
                    cpu.registers.Y = 0x02

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x07FA)).to(equal(0x23))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("indexedIndirect") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x81

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0xF8)
                    cpu.memory.write(addr: 0x00FA, data: 0x23)
                    cpu.memory.write(addr: 0x00FB, data: 0x04)
                    cpu.memory.write(addr: 0x0423, data: 0x9F)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF1
                    cpu.registers.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0423)).to(equal(0xF1))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("indirectIndexed") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x91

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x40)
                    cpu.memory.write(addr: 0x0040, data: 0x71)
                    cpu.memory.write(addr: 0x0041, data: 0x07)
                    cpu.memory.write(addr: 0x0773, data: 0x93)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.Y = 0x02

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0773)).to(equal(0xF2))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }
        }

        // skip STX/STY because of similar specifications to STA

        describe("TAX") {
            describe("implicit") {
                it("transfer Accumulator to X register") {
                    let opcode: UInt8 = 0xAA

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.X = 0x32

                    let cycle = cpu.run()

                    expect(cpu.registers.X).to(equal(0xF2))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TAY") {
            describe("implicit") {
                it("transfer Accumulator to Y register") {
                    let opcode: UInt8 = 0xA8

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.Y = 0x32

                    let cycle = cpu.run()

                    expect(cpu.registers.Y).to(equal(0xF2))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TXA") {
            describe("implicit") {
                it("transfer X register to accumulator") {
                    let opcode: UInt8 = 0x8A

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.X = 0x32

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x32))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("TYA") {
            describe("implicit") {
                it("transfer Y register to accumulator") {
                    let opcode: UInt8 = 0x98

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.Y = 0x32

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0x32))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("PHA") {
            describe("implicit") {
                it("push accumulator to stack") {
                    let opcode: UInt8 = 0x48

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF
                    cpu.registers.A = 0xF2

                    let cycle = cpu.run()

                    expect(cpu.pullStack() as UInt8).to(equal(0xF2))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PHP") {
            describe("implicit") {
                it("push processor status to stack") {
                    let opcode: UInt8 = 0x08

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF
                    cpu.registers.P = [.N, .B, .I, .Z, .C]

                    let cycle = cpu.run()

                    expect(Status(rawValue: cpu.pullStack())).to(equal(cpu.registers.P))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PLA") {
            describe("implicit") {
                it("pull stack and write accumulator") {
                    let opcode: UInt8 = 0x68

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF
                    cpu.registers.A = 0xF2
                    cpu.pushStack(data: 0xA2)

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0xA2))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PLP") {
            describe("implicit") {
                it("pull stack and write processor status") {
                    let opcode: UInt8 = 0x28

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF

                    let status: Status = [.N, .R, .Z, .C]
                    cpu.pushStack(data: status.rawValue)

                    let cycle = cpu.run()

                    expect(cpu.registers.P).to(equal(status))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(4))
                }
            }
        }

        describe("AND") {
            describe("absolute") {
                it("performe logical AND on the accumulator") {
                    let opcode: UInt8 = 0x2D

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 0b01011100)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11011011

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0b01011000))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("EOR") {
            describe("absolute") {
                it("performe exclusive OR on the accumulator") {
                    let opcode: UInt8 = 0x4D

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 0b01011100)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11011011

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0b10000111))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ORA") {
            describe("absolute") {
                it("performe OR on the accumulator") {
                    let opcode: UInt8 = 0x0D

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 0b01011100)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11011011

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0b11011111))
                    expect(cpu.registers.PC).to(equal(0x0305))
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

                        cpu.memory.write(addr: 0x0302, data: opcode)
                        cpu.memory.write(addr: 0x0303, data: 0x30)
                        cpu.memory.write(addr: 0x0304, data: 0x01)
                        cpu.memory.write(addr: 0x0130, data: 0b10011100)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 0b01000011

                        let cycle = cpu.run()

                        expect(cpu.registers.P.contains(.Z)).to(beTruthy())
                        expect(cpu.registers.P.contains(.V)).to(beFalsy())
                        expect(cpu.registers.P.contains(.N)).to(beFalsy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("if overflow") {
                    it("set overflow status") {
                        let opcode: UInt8 = 0x2C

                        cpu.memory.write(addr: 0x0302, data: opcode)
                        cpu.memory.write(addr: 0x0303, data: 0x30)
                        cpu.memory.write(addr: 0x0304, data: 0x01)
                        cpu.memory.write(addr: 0x0130, data: 0b01011100)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 0b11011011

                        let cycle = cpu.run()

                        expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                        expect(cpu.registers.P.contains(.V)).to(beTruthy())
                        expect(cpu.registers.P.contains(.N)).to(beFalsy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("if negative") {
                    it("set negative status") {
                        let opcode: UInt8 = 0x2C

                        cpu.memory.write(addr: 0x0302, data: opcode)
                        cpu.memory.write(addr: 0x0303, data: 0x30)
                        cpu.memory.write(addr: 0x0304, data: 0x01)
                        cpu.memory.write(addr: 0x0130, data: 0b10011100)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 0b10011011

                        let cycle = cpu.run()

                        expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                        expect(cpu.registers.P.contains(.V)).to(beFalsy())
                        expect(cpu.registers.P.contains(.N)).to(beTruthy())
                        expect(cpu.registers.PC).to(equal(0x0305))
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

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 30)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 12
                    cpu.registers.P.formUnion(.C)

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(43))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("SBC") {
            describe("absolute") {
                it("subtract with carry") {
                    let opcode: UInt8 = 0xED

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 30)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 42
                    cpu.registers.P.formUnion(.C)

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(11))
                    expect(cpu.registers.PC).to(equal(0x0305))
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
                        cpu.memory.write(addr: 0x0302, data: opcode)
                        cpu.memory.write(addr: 0x0303, data: 0x30)
                        cpu.memory.write(addr: 0x0304, data: 0x01)
                        cpu.memory.write(addr: 0x0130, data: 97)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 97

                        let cycle = cpu.run()

                        expect(cpu.registers.P.contains(.C)).to(beFalsy())
                        expect(cpu.registers.P.contains(.Z)).to(beTruthy())
                        expect(cpu.registers.P.contains(.N)).to(beFalsy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A >= M") {
                    it("set Zero flag") {
                        cpu.memory.write(addr: 0x0302, data: opcode)
                        cpu.memory.write(addr: 0x0303, data: 0x30)
                        cpu.memory.write(addr: 0x0304, data: 0x01)
                        cpu.memory.write(addr: 0x0130, data: 97)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 98

                        let cycle = cpu.run()

                        expect(cpu.registers.P.contains(.C)).to(beTruthy())
                        expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                        expect(cpu.registers.P.contains(.N)).to(beFalsy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A < M") {
                    it("set Zero flag") {
                        cpu.memory.write(addr: 0x0302, data: opcode)
                        cpu.memory.write(addr: 0x0303, data: 0x30)
                        cpu.memory.write(addr: 0x0304, data: 0x01)
                        cpu.memory.write(addr: 0x0130, data: 97)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 96

                        let cycle = cpu.run()

                        expect(cpu.registers.P.contains(.C)).to(beFalsy())
                        expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                        expect(cpu.registers.P.contains(.N)).to(beTruthy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        // skip CPX/CPY because of similar specifications to the CMP.

        describe("INC") {
            describe("absolute") {
                it("increment carry") {
                    let opcode: UInt8 = 0xEE

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 254)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0130)).to(equal(255))
                    expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0305))
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

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 254)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0130)).to(equal(253))
                    expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0305))
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

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0b10010110))
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("shift left bits on memory") {
                    let opcode: UInt8 = 0x0E

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 0b11101110)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0130)).to(equal(0b11011100))
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("LSR") {
            describe("accumulator") {
                it("shift right bits of the accumulator") {
                    let opcode: UInt8 = 0x4A

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0b01100101))
                    expect(cpu.registers.P.contains(.N)).to(beFalsy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("shift right bits of memory") {
                    let opcode: UInt8 = 0x4E

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 0b11101110)
                    cpu.registers.PC = 0x0302

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0130)).to(equal(0b01110111))
                    expect(cpu.registers.P.contains(.N)).to(beFalsy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ROL") {
            describe("accumulator") {
                it("rotate left") {
                    let opcode: UInt8 = 0x2A

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0b10010110))
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("rotate left") {
                    let opcode: UInt8 = 0x2E

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 0b11101110)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.C)

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0130)).to(equal(0b11011101))
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("ROR") {
            describe("accumulator") {
                it("rotate right") {
                    let opcode: UInt8 = 0x6A

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = cpu.run()

                    expect(cpu.registers.A).to(equal(0b01100101))
                    expect(cpu.registers.P.contains(.N)).to(beFalsy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }

            describe("absolute") {
                it("rotate right") {
                    let opcode: UInt8 = 0x6E

                    cpu.memory.write(addr: 0x0302, data: opcode)
                    cpu.memory.write(addr: 0x0303, data: 0x30)
                    cpu.memory.write(addr: 0x0304, data: 0x01)
                    cpu.memory.write(addr: 0x0130, data: 0b11101110)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.C)

                    let cycle = cpu.run()

                    expect(cpu.memory.read(addr: 0x0130)).to(equal(0b11110111))
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.P.contains(.C)).to(beFalsy())
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }
    }
}
