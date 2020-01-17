import Quick
import Nimble

@testable import SwiftNES

class CPUMemoryMapSpec: QuickSpec {
    override func spec() {
        describe("WRAM") {
            var nes = NES()

            var data: [UInt8] = Array(repeating: 0, count: 2049)  // 2048 + 1
            data[0] = 1
            data[1024] = 52
            data[2048] = 127

            nes.wram = data

            it("Read") {
                expect(read(at: 0, from: &nes)).to(equal(1))
                expect(read(at: 1, from: &nes)).to(equal(0))
                expect(read(at: 1023, from: &nes)).to(equal(0))
                expect(read(at: 1024, from: &nes)).to(equal(52))
                expect(read(at: 1025, from: &nes)).to(equal(0))
            }

            it("Write & read") {
                write(87, at: 256, to: &nes)

                expect(read(at: 255, from: &nes)).to(equal(0))
                expect(read(at: 256, from: &nes)).to(equal(87))
                expect(read(at: 257, from: &nes)).to(equal(0))
            }
        }

        // describe("ROM") {

        //     it("load Program") {
        //         let map = CPUMemoryMap()

        //         var p: [UInt8]  = Array(repeating: 0, count: 0x4000)
        //         p[0x0000] = 1
        //         p[0x0100] = 2
        //         p[0x1000] = 3

        //         map.cartridge = Cartridge(rawData: p)

        //         expect(map.read(at: 0x4020)).to(equal(1))
        //         expect(map.read(at: 0x4120)).to(equal(2))
        //         expect(map.read(at: 0x5020)).to(equal(3))
        //     }
        // }

        describe("readWord") {
            var nes = NES()

            it("read 1 word") {
                write(1, at: 128, to: &nes)
                write(1, at: 129, to: &nes)

                expect(readWord(at: 128, from: &nes)).to(equal(0b0000000100000001))

                write(64, at: 10, to: &nes)
                write(32, at: 11, to: &nes)
                write(255, at: 12, to: &nes)

                expect(readWord(at: 10, from: &nes)).to(equal(0b0010000001000000))
                expect(readWord(at: 11, from: &nes)).to(equal(0b1111111100100000))
                expect(readWord(at: 12, from: &nes)).to(equal(0b0000000011111111))
            }
        }
    }
}
