import Quick
import Nimble

@testable import SwiftNES

class InstructionSpec: QuickSpec {
    override func spec() {
        var cpu: CPU!
        var memory: Memory!
        beforeEach {
            cpu = CPU()
            memory = [UInt8](repeating: 0x00, count: 65536)
        }

        describe("LDA") {

            describe("immediate") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA9

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0xF8))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("zeroPage") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA5

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x93, at: 0x00F8)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, X") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB5

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x93, at: 0x0087)
                    cpu.registers.PC = 0x0302
                    cpu.registers.X = 0x8F

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAD

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x07, at: 0x0304)
                    memory.write(0x51, at: 0x07F8)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0x51))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteX") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xBD

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x07, at: 0x0304)
                    memory.write(0x51, at: 0x07FA)
                    cpu.registers.PC = 0x0302
                    cpu.registers.X = 0x02

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0x51))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteY") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB9

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x07, at: 0x0304)
                    memory.write(0x51, at: 0x07FA)
                    cpu.registers.PC = 0x0302
                    cpu.registers.Y = 0x02

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0x51))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("indexedIndirect") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xA1

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x23, at: 0x00FA)
                    memory.write(0x04, at: 0x00FB)
                    memory.write(0x9F, at: 0x0423)
                    cpu.registers.PC = 0x0302
                    cpu.registers.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0x9F))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("indirectIndexed") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xB1

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x40, at: 0x0303)
                    memory.write(0x71, at: 0x0040)
                    memory.write(0x07, at: 0x0041)
                    memory.write(0x93, at: 0x0773)
                    cpu.registers.PC = 0x0302
                    cpu.registers.Y = 0x02

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.X).to(equal(0xF8))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(2))
                }
            }

            describe("zeroPage") {
                it("load X register") {
                    let opcode: UInt8 = 0xA6

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x93, at: 0x00F8)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.X).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, Y") {
                it("load X register") {
                    let opcode: UInt8 = 0xB6

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x93, at: 0x0087)
                    cpu.registers.PC = 0x0302
                    cpu.registers.Y = 0x8F

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.X).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("load accumulator") {
                    let opcode: UInt8 = 0xAE

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x07, at: 0x0304)
                    memory.write(0x51, at: 0x07F8)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x93

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x00F8)).to(equal(0x93))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(3))
                }
            }

            describe("zeroPage, X") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x95

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x32
                    cpu.registers.X = 0x8F

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0087)).to(equal(0x32))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absolute") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x8D

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x07, at: 0x0304)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x19

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x07F8)).to(equal(0x19))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(4))
                }
            }

            describe("absoluteX") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x9D

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x07, at: 0x0304)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x24
                    cpu.registers.X = 0x02

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x07FA)).to(equal(0x24))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("absoluteY") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x99

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x07, at: 0x0304)
                    memory.write(0x51, at: 0x07FA)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0x23
                    cpu.registers.Y = 0x02

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x07FA)).to(equal(0x23))
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(5))
                }
            }

            describe("indexedIndirect") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x81

                    memory.write(opcode, at: 0x0302)
                    memory.write(0xF8, at: 0x0303)
                    memory.write(0x23, at: 0x00FA)
                    memory.write(0x04, at: 0x00FB)
                    memory.write(0x9F, at: 0x0423)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF1
                    cpu.registers.X = 0x02
                    // low: 0xFA, high: (0xFA + 1) & 0x00FF = 0xFB

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0423)).to(equal(0xF1))
                    expect(cpu.registers.PC).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }

            describe("indirectIndexed") {
                it("Store accumulator") {
                    let opcode: UInt8 = 0x91

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x40, at: 0x0303)
                    memory.write(0x71, at: 0x0040)
                    memory.write(0x07, at: 0x0041)
                    memory.write(0x93, at: 0x0773)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.Y = 0x02

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0773)).to(equal(0xF2))
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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.X = 0x32

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.Y = 0x32

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.X = 0x32

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0xF2
                    cpu.registers.Y = 0x32

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF
                    cpu.registers.A = 0xF2

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt8).to(equal(0xF2))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PHP") {
            describe("implicit") {
                it("push processor status to stack") {
                    let opcode: UInt8 = 0x08

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF
                    cpu.registers.P = [.N, .B, .I, .Z, .C]

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(Status(rawValue: pullStack(registers: &cpu.registers, memory: &memory))).to(equal([cpu.registers.P, Status.operatedB] as Status))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(3))
                }
            }
        }

        describe("PLA") {
            describe("implicit") {
                it("pull stack and write accumulator") {
                    let opcode: UInt8 = 0x68

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF
                    cpu.registers.A = 0xF2
                    pushStack(0xA2, registers: &cpu.registers, memory: &memory)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(0xA2))
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(4))
                }
            }
        }

        describe("PLP") {
            describe("implicit") {
                it("pull stack and write processor status") {
                    let opcode: UInt8 = 0x28

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF

                    let status: Status = [.N, .R, .Z, .C]
                    pushStack(status.rawValue, registers: &cpu.registers, memory: &memory)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(0b01011100, at: 0x0130)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11011011

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(0b01011100, at: 0x0130)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11011011

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(0b01011100, at: 0x0130)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11011011

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                        memory.write(opcode, at: 0x0302)
                        memory.write(0x30, at: 0x0303)
                        memory.write(0x01, at: 0x0304)
                        memory.write(0b10011100, at: 0x0130)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 0b01000011

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.P.contains(.Z)).to(beTruthy())
                        expect(cpu.registers.P.contains(.V)).to(beFalsy())
                        expect(cpu.registers.P.contains(.N)).to(beTruthy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("if overflow") {
                    it("set overflow status") {
                        let opcode: UInt8 = 0x2C

                        memory.write(opcode, at: 0x0302)
                        memory.write(0x30, at: 0x0303)
                        memory.write(0x01, at: 0x0304)
                        memory.write(0b01011100, at: 0x0130)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 0b11011011

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                        memory.write(opcode, at: 0x0302)
                        memory.write(0x30, at: 0x0303)
                        memory.write(0x01, at: 0x0304)
                        memory.write(0b10011100, at: 0x0130)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 0b10011011

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(255, at: 0x0130)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 12
                    cpu.registers.P.formUnion(.C)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(12))
                    expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                    expect(cpu.registers.P.contains(.V)).to(beFalsy())
                    expect(cpu.registers.P.contains(.N)).to(beFalsy())
                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0305))
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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(42, at: 0x0130)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 30
                    cpu.registers.P.formUnion(.C)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.A).to(equal(244))
                    expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                    expect(cpu.registers.P.contains(.V)).to(beFalsy())
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.P.contains(.C)).to(beFalsy())
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x30, at: 0x0303)
                        memory.write(0x01, at: 0x0304)
                        memory.write(97, at: 0x0130)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 97

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.P.contains(.C)).to(beTruthy())
                        expect(cpu.registers.P.contains(.Z)).to(beTruthy())
                        expect(cpu.registers.P.contains(.N)).to(beFalsy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A >= M") {
                    it("set Zero flag") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x30, at: 0x0303)
                        memory.write(0x01, at: 0x0304)
                        memory.write(97, at: 0x0130)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 98

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.P.contains(.C)).to(beTruthy())
                        expect(cpu.registers.P.contains(.Z)).to(beFalsy())
                        expect(cpu.registers.P.contains(.N)).to(beFalsy())
                        expect(cpu.registers.PC).to(equal(0x0305))
                        expect(cycle).to(equal(4))
                    }
                }

                context("A < M") {
                    it("set Zero flag") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x30, at: 0x0303)
                        memory.write(0x01, at: 0x0304)
                        memory.write(97, at: 0x0130)
                        cpu.registers.PC = 0x0302
                        cpu.registers.A = 96

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

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

        // TODO CPX/CPY test

        describe("INC") {
            describe("absolute") {
                it("increment carry") {
                    let opcode: UInt8 = 0xEE

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(254, at: 0x0130)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0130)).to(equal(255))
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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(254, at: 0x0130)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0130)).to(equal(253))
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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(0b11101110, at: 0x0130)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0130)).to(equal(0b11011100))
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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(0b11101110, at: 0x0130)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0130)).to(equal(0b01110111))
                    expect(cpu.registers.P.contains(.N)).to(beFalsy())
                    expect(cpu.registers.P.contains(.C)).to(beFalsy())
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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(0b11101110, at: 0x0130)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.C)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0130)).to(equal(0b11011101))
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

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.A = 0b11001011

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

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

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    memory.write(0b11101110, at: 0x0130)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.C)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(memory.read(at: 0x0130)).to(equal(0b11110111))
                    expect(cpu.registers.P.contains(.N)).to(beTruthy())
                    expect(cpu.registers.P.contains(.C)).to(beFalsy())
                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }

            // skip other addressing mode because of similar specifications to the above.
        }

        describe("JMP") {
            describe("absolute") {
                it("jump") {
                    let opcode: UInt8 = 0x4C

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    cpu.registers.PC = 0x0302

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.PC).to(equal(0x0130))
                    expect(cycle).to(equal(3))
                }
            }
            // skip other addressing mode because of similar specifications to the above.
        }

        describe("JSR") {
            describe("implicit") {
                it("jump to subroutine") {
                    let opcode: UInt8 = 0x20

                    memory.write(opcode, at: 0x0302)
                    memory.write(0x30, at: 0x0303)
                    memory.write(0x01, at: 0x0304)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.PC).to(equal(0x0130))
                    expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt16).to(equal(0x0304))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("RTS") {
            describe("implicit") {
                it("return from subroutine") {
                    let opcode: UInt8 = 0x60

                    memory.write(opcode, at: 0x0130)
                    cpu.registers.PC = 0x0130
                    cpu.registers.S = 0xFF
                    pushStack(word: 0x0304, registers: &cpu.registers, memory: &memory)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.PC).to(equal(0x0305))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("RTI") {
            describe("implicit") {
                it("return from interrupt") {
                    let opcode: UInt8 = 0x40

                    memory.write(opcode, at: 0x0130)
                    cpu.registers.PC = 0x0130
                    cpu.registers.S = 0xFF

                    pushStack(word: 0x0401, registers: &cpu.registers, memory: &memory)
                    let status: Status = [.N, .Z, .C]
                    pushStack(status.rawValue, registers: &cpu.registers, memory: &memory)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.PC).to(equal(0x0401))
                    expect(cpu.registers.P.rawValue).to(equal(status.rawValue | 0x20))
                    expect(cycle).to(equal(6))
                }
            }
        }

        describe("BCC") {
            describe("relative") {
                let opcode: UInt8 = 0x90

                context("if carray flag is clear") {
                    it("add the relative displacement to the PC") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.C)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if carray flag is set") {
                    it("NOP") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.C)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.C)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if carray flag is set") {
                    it("add the relative displacement to the PC") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.C)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.Z)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if zero flag is set") {
                    it("add the relative displacement to the PC") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.Z)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.N)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if negative flag is set") {
                    it("add the relative displacement to the PC") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.N)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.Z)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if zero flag is set") {
                    it("NOP") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.Z)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.N)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if negative flag is set") {
                    it("NOP") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.N)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.V)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }

                context("if overflow flag is set") {
                    it("NOP") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.V)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
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
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.remove(.V)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0304))
                        expect(cycle).to(equal(2))
                    }
                }

                context("if overflow flag is set") {
                    it("add the relative displacement to the PC") {
                        memory.write(opcode, at: 0x0302)
                        memory.write(0x03, at: 0x0303)
                        cpu.registers.PC = 0x0302
                        cpu.registers.P.formUnion(.V)

                        let cycle = CPU.step(cpu: cpu, memory: &memory)

                        expect(cpu.registers.PC).to(equal(0x0307))
                        expect(cycle).to(equal(3))
                    }
                }
            }
        }

        describe("CLC") {
            describe("implicit") {
                it("clear carry flag") {
                    let opcode: UInt8 = 0x18

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.C)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.P.contains(.C)).to(beFalsy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLD") {
            describe("implicit") {
                it("clear decimal mode") {
                    let opcode: UInt8 = 0xD8

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.D)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.P.contains(.D)).to(beFalsy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLI") {
            describe("implicit") {
                it("clear interrupt disable") {
                    let opcode: UInt8 = 0x58

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.I)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.P.contains(.I)).to(beFalsy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("CLV") {
            describe("implicit") {
                it("clear overflow flag") {
                    let opcode: UInt8 = 0xB8

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.formUnion(.V)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.P.contains(.V)).to(beFalsy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SEC") {
            describe("implicit") {
                it("set carray flag") {
                    let opcode: UInt8 = 0x38

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.remove(.C)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.P.contains(.C)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SED") {
            describe("implicit") {
                it("set decimal flag") {
                    let opcode: UInt8 = 0xF8

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.remove(.D)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.P.contains(.D)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("SEI") {
            describe("implicit") {
                it("set interrupt disable") {
                    let opcode: UInt8 = 0x78

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.P.remove(.I)

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.P.contains(.I)).to(beTruthy())
                    expect(cpu.registers.PC).to(equal(0x0303))
                    expect(cycle).to(equal(2))
                }
            }
        }

        describe("BRK") {
            describe("implicit") {
                it("force interrupt") {
                    let opcode: UInt8 = 0x00

                    memory.write(0x70, at: 0xFFFE)
                    memory.write(0x81, at: 0xFFFF)

                    memory.write(opcode, at: 0x0302)
                    cpu.registers.PC = 0x0302
                    cpu.registers.S = 0xFF

                    let status: Status = [.N, .R, .Z, .C]
                    cpu.registers.P = status

                    let cycle = CPU.step(cpu: cpu, memory: &memory)

                    expect(cpu.registers.PC).to(equal(0x8170))
                    expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt8).to(equal(status.rawValue | Status.interruptedB.rawValue))
                    expect(pullStack(registers: &cpu.registers, memory: &memory) as UInt16).to(equal(0x0303))
                    expect(cycle).to(equal(7))
                }
            }
        }
    }
}
