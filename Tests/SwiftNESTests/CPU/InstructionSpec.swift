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

//         describe("PHA") {
//             describe("implicit") {
//                 it("push accumulator to stack") {
//                     let opcode: UInt8 = 0x48

//                     cpu.memory.write(addr: 0x0302, data: opcode)
//                     cpu.registers.PC = 0x0302
//                     cpu.registers.A = 0xF2

//                     let cycle = cpu.run()

//                     expect(cpu.pullStack() as UInt16).to(equal(0xF2))
//                     expect(cpu.registers.PC).to(equal(0x0303))
//                     expect(cycle).to(equal(3))
//                 }
//             }
//         }
    }
}
