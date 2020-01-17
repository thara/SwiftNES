import Quick
import Nimble

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {
        describe("registers") {
            it("Sync N to bit 7 of A") {
                var reg = CPU(A: 0, X: 0, Y: 0, S: 0, P: [], PC: 0)

                reg.A = 0b00101111
                expect(reg.P.contains(.N)).to(beFalsy())

                reg.A = 0b10101111
                expect(reg.P.contains(.N)).to(beTruthy())
            }
        }

        describe("fetchOpCode") {
            it("read opcode at address indicated by PC") {
                var nes = NES()

                write(0x90, at: 0x0609, to: &nes)
                write(0x3F, at: 0x0610, to: &nes)
                write(0x81, at: 0x0611, to: &nes)
                write(0x90, at: 0x0612, to: &nes)

                nes.cpu.PC = 0x0610

                var opcode = fetchOpCode(from: &nes)
                expect(opcode).to(equal(0x3F))

                opcode = fetchOpCode(from: &nes)
                expect(opcode).to(equal(0x81))
            }
        }

        // describe("reset") {
        //     it("reset registers & memory state") {
        //         var nes = NES()

        //         nes.cpu = CPU(
        //             A: 0xFA,
        //             X: 0x1F,
        //             Y: 0x59,
        //             S: 0x37,
        //             P: [Status.N, Status.V],
        //             PC: 0b0101011010001101
        //         )

        //         write(1, at: 0xFFFB, to: &nes)
        //         write(32, at: 0xFFFC, to: &nes)
        //         write(127, at: 0xFFFD, to: &nes)
        //         write(64, at: 0xFFFE, to: &nes)

        //         _ = reset(on: &nes)

        //         expect(nes.cpu.A).to(equal(0xFA))
        //         expect(nes.cpu.X).to(equal(0x1F))
        //         expect(nes.cpu.Y).to(equal(0x59))
        //         expect(nes.cpu.S).to(equal(0x34))
        //         expect(nes.cpu.P).to(equal([Status.N, Status.V, Status.I]))
        //         expect(nes.cpu.PC).to(equal(0b0111111100100000))
        //     }
        // }

        describe("stack") {

            it("push data, and pull the same") {
                var nes = NES()
                nes.cpu.S = 0xFF

                pushStack(0x83, to: &nes)
                pushStack(0x14, to: &nes)

                expect(pullStack(from: &nes) as UInt8).to(equal(0x14))
                expect(pullStack(from: &nes) as UInt8).to(equal(0x83))
            }

            it("push word, and pull the same") {
                var nes = NES()
                nes.cpu.S = 0xFF

                pushStack(word: 0x98AF, to: &nes)
                pushStack(word: 0x003A, to: &nes)

                expect(pullStack(from: &nes) as UInt16).to(equal(0x003A))
                expect(pullStack(from: &nes) as UInt16).to(equal(0x98AF))
            }
        }
    }
}
