import Quick
import Nimble

@testable import SwiftNES

class MemorySpec: QuickSpec {
    override func spec() {
        describe("WRAM") {
            var data: [UInt8] = Array(repeating: 0, count: 2049)  // 2048 + 1
            data[0] = 1
            data[1024] = 52
            data[2048] = 127

            let mem = AddressSpace(initial: data)

            it("Read") {
                expect(mem.read(addr: 0)).to(equal(1))
                expect(mem.read(addr: 1)).to(equal(0))
                expect(mem.read(addr: 1023)).to(equal(0))
                expect(mem.read(addr: 1024)).to(equal(52))
                expect(mem.read(addr: 1025)).to(equal(0))
            }

            it("Write & read") {
                mem.write(addr: 256, data: 87)

                expect(mem.read(addr: 255)).to(equal(0))
                expect(mem.read(addr: 256)).to(equal(87))
                expect(mem.read(addr: 257)).to(equal(0))
            }
        }

        describe("ROM") {

            it("load Program") {
                let mem = AddressSpace()

                var program: [UInt8]  = Array(repeating: 0, count: 0x4000)
                program[0x0000] = 1
                program[0x0100] = 2
                program[0x1000] = 3

                mem.loadProgram(index: 0, data: program)
                mem.loadProgram(index: 1, data: program)

                expect(mem.read(addr: 0x8000)).to(equal(1))
                expect(mem.read(addr: 0x8100)).to(equal(2))
                expect(mem.read(addr: 0x9000)).to(equal(3))

                expect(mem.read(addr: 0xC000)).to(equal(1))
                expect(mem.read(addr: 0xC100)).to(equal(2))
                expect(mem.read(addr: 0xD000)).to(equal(3))
            }
        }

        describe("readWord") {

            let mem = AddressSpace()

            it("read 1 word") {
                mem.write(addr: 128, data: 1)
                mem.write(addr: 129, data: 1)

                expect(mem.readWord(addr: 128)).to(equal(0b0000000100000001))

                mem.write(addr: 10, data: 64)
                mem.write(addr: 11, data: 32)
                mem.write(addr: 12, data: 255)

                expect(mem.readWord(addr: 10)).to(equal(0b0010000001000000))
                expect(mem.readWord(addr: 11)).to(equal(0b1111111100100000))
                expect(mem.readWord(addr: 12)).to(equal(0b0000000011111111))
            }
        }
    }
}
