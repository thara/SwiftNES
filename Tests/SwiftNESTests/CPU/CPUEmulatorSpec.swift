import Nimble
import Quick

@testable import SwiftNES

class CPUEmulatorSpec: QuickSpec {
    override func spec() {
        describe("fetch") {
            it("read opcode at address indicated by PC") {
                let emu = CPUEmulatorStub()

                emu.write(0x90, at: 0x9051)
                emu.write(0x3F, at: 0x9052)
                emu.write(0x81, at: 0x9053)
                emu.write(0x90, at: 0x9054)

                emu.cpu.PC = 0x9052

                var opcode = emu.fetchOpcode()
                expect(opcode).to(equal(0x3F))

                opcode = emu.fetchOpcode()
                expect(opcode).to(equal(0x81))
            }
        }

        describe("reset") {
            it("reset registers & memory state") {
                let emu = CPUEmulatorStub()

                emu.cpu.A = 0xFA
                emu.cpu.X = 0x1F
                emu.cpu.Y = 0x59
                emu.cpu.S = 0x37
                emu.cpu.P = [CPU.Status.N, CPU.Status.V]
                emu.cpu.PC = 0b01010110_10001101

                emu.write(1, at: 0xFFFB)
                emu.write(32, at: 0xFFFC)
                emu.write(127, at: 0xFFFD)
                emu.write(64, at: 0xFFFE)

                emu.reset()

                expect(emu.cpu.A).to(equal(0xFA))
                expect(emu.cpu.X).to(equal(0x1F))
                expect(emu.cpu.Y).to(equal(0x59))
                expect(emu.cpu.S).to(equal(0x34))
                expect(emu.cpu.P).to(equal([CPU.Status.N, CPU.Status.V, CPU.Status.I]))
                expect(emu.cpu.PC).to(equal(0b01111111_00100000))
            }
        }


        describe("stack") {

            it("push data, and pull the same") {
                let emu = CPUEmulatorStub()
                emu.cpu.S = 0xFF

                emu.pushStack(0x83)
                emu.pushStack(0x14)

                expect(emu.pullStack() as UInt8).to(equal(0x14))
                expect(emu.pullStack() as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                let emu = CPUEmulatorStub()
                emu.cpu.S = 0xFF

                emu.pushStack(word: 0x98AF)
                emu.pushStack(word: 0x003A)

                expect(emu.pullStack() as UInt16).to(equal(0x003A))
                expect(emu.pullStack() as UInt16).to(equal(0x98AF))
            }
        }
    }
}

class CPUEmulatorStub : CPUEmulator {
    var cpu = CPU()
    var mem = [UInt8](repeating: 0x00, count: 65536)

    func cpuRead(at address: UInt16) -> UInt8 {
        return mem[Int(address)]
    }
    func cpuWrite(_ value: UInt8, at address: UInt16) {
        mem[Int(address)] = value
    }

    func cpuTick() {
        cpu.cycles += 1
    }
}
