import Nimble
import Quick

@testable import SwiftNES

class CPUMemorySpec: QuickSpec {
    override func spec() {
        describe("WRAM") {
            var data: [UInt8] = Array(repeating: 0, count: 2049)  // 2048 + 1
            data[0] = 1
            data[1024] = 52
            data[2048] = 127

            let map = CPUMemory(initial: data)

            it("Read") {
                expect(map.read(at: 0)).to(equal(1))
                expect(map.read(at: 1)).to(equal(0))
                expect(map.read(at: 1023)).to(equal(0))
                expect(map.read(at: 1024)).to(equal(52))
                expect(map.read(at: 1025)).to(equal(0))
            }

            it("Write & read") {
                map.write(87, at: 256)

                expect(map.read(at: 255)).to(equal(0))
                expect(map.read(at: 256)).to(equal(87))
                expect(map.read(at: 257)).to(equal(0))
            }
        }

        // describe("ROM") {

        //     it("load Program") {
        //         let map = CPUMemory()

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

            let map = CPUMemory()

            it("read 1 word") {
                map.write(1, at: 128)
                map.write(1, at: 129)

                expect(map.readWord(at: 128)).to(equal(0b00000001_00000001))

                map.write(64, at: 10)
                map.write(32, at: 11)
                map.write(255, at: 12)

                expect(map.readWord(at: 10)).to(equal(0b00100000_01000000))
                expect(map.readWord(at: 11)).to(equal(0b11111111_00100000))
                expect(map.readWord(at: 12)).to(equal(0b00000000_11111111))
            }
        }
    }
}
