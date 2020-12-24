import Nimble
import Quick

@testable import NES2

typealias CPUStatus = CPURegister.Status

class CPUSpec: QuickSpec {
    override func spec() {
        describe("registers") {
            it("Sync N to bit 7 of A") {
                var reg = CPURegister()

                reg.A = 0b00101111
                expect(reg.P.contains(.N)).to(beFalsy())

                reg.A = 0b10101111
                expect(reg.P.contains(.N)).to(beTruthy())
            }
        }

        describe("fetch") {
            it("read opcode at address indicated by PC") {
                var cpu = CPUStub()
                var mem: [UInt8] = Array(repeating: 0, count: 0xFFFF)

                cpu.cpuWrite(0x90, at: 0x9051, to: &mem)
                cpu.cpuWrite(0x3F, at: 0x9052, to: &mem)
                cpu.cpuWrite(0x81, at: 0x9053, to: &mem)
                cpu.cpuWrite(0x90, at: 0x9054, to: &mem)

                var reg = CPURegister()
                reg.PC = 0x9052

                var opcode = cpu.fetchOpcode(register: &reg, from: &mem)
                expect(opcode).to(equal(0x3F))

                opcode = cpu.fetchOpcode(register: &reg, from: &mem)
                expect(opcode).to(equal(0x81))
            }
        }

        describe("handleRESET") {
            it("reset registers & memory state") {
                var cpu = CPUStub()

                var reg = CPURegister()
                reg.A = 0xFA
                reg.X = 0x1F
                reg.Y = 0x59
                reg.S = 0x37
                reg.P = [CPUStatus.N, CPUStatus.V]
                reg.PC = 0b01010110_10001101

                var mem: [UInt8] = Array(repeating: 0, count: 0xFFFF)
                cpu.cpuWrite(1, at: 0xFFFB, to: &mem)
                cpu.cpuWrite(32, at: 0xFFFC, to: &mem)
                cpu.cpuWrite(127, at: 0xFFFD, to: &mem)
                cpu.cpuWrite(64, at: 0xFFFE, to: &mem)

                cpu.reset(register: &reg, bus: &mem)

                expect(reg.A).to(equal(0xFA))
                expect(reg.X).to(equal(0x1F))
                expect(reg.Y).to(equal(0x59))
                expect(reg.S).to(equal(0x34))
                expect(reg.P).to(equal([CPUStatus.N, CPUStatus.V, CPUStatus.I]))
                expect(reg.PC).to(equal(0b01111111_00100000))
            }
        }

        describe("stack") {

            it("push data, and pull the same") {
                var cpu = CPUStub()

                var reg = CPURegister()
                reg.S = 0xFF
                var mem: [UInt8] = Array(repeating: 0, count: 0xFFFF)

                cpu.pushStack(0x83, register: &reg, to: &mem)
                cpu.pushStack(0x14, register: &reg, to: &mem)

                expect(cpu.pullStack(register: &reg, from: &mem) as UInt8).to(equal(0x14))
                expect(cpu.pullStack(register: &reg, from: &mem) as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                var cpu = CPUStub()

                var reg = CPURegister()
                reg.S = 0xFF
                var mem: [UInt8] = Array(repeating: 0, count: 0xFFFF)

                cpu.pushStack(word: 0x98AF, register: &reg, to: &mem)
                cpu.pushStack(word: 0x003A, register: &reg, to: &mem)

                expect(cpu.pullStack(register: &reg, from: &mem) as UInt16).to(equal(0x003A))
                expect(cpu.pullStack(register: &reg, from: &mem) as UInt16).to(equal(0x98AF))
            }
        }
    }
}
