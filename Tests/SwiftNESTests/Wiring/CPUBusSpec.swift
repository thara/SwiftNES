import Quick
import Nimble

@testable import SwiftNES

class CPUBusSpec: QuickSpec {
    override func spec() {
        describe("WRAM") {
            var data: [UInt8] = Array(repeating: 0, count: 2049)  // 2048 + 1
            data[0] = 1
            data[1024] = 52
            data[2048] = 127

            let bus = CPUBus(initial: data)

            it("Read") {
                expect(bus.read(at: 0)).to(equal(1))
                expect(bus.read(at: 1)).to(equal(0))
                expect(bus.read(at: 1023)).to(equal(0))
                expect(bus.read(at: 1024)).to(equal(52))
                expect(bus.read(at: 1025)).to(equal(0))
            }

            it("Write & read") {
                bus.write(87, at: 256)

                expect(bus.read(at: 255)).to(equal(0))
                expect(bus.read(at: 256)).to(equal(87))
                expect(bus.read(at: 257)).to(equal(0))
            }
        }

        // describe("ROM") {

        //     it("load Program") {
        //         let bus = CPUBus()

        //         var p: [UInt8]  = Array(repeating: 0, count: 0x4000)
        //         p[0x0000] = 1
        //         p[0x0100] = 2
        //         p[0x1000] = 3

        //         bus.cartridge = Cartridge(rawData: p)

        //         expect(bus.read(at: 0x4020)).to(equal(1))
        //         expect(bus.read(at: 0x4120)).to(equal(2))
        //         expect(bus.read(at: 0x5020)).to(equal(3))
        //     }
        // }

        describe("readWord") {

            let bus = CPUBus()

            it("read 1 word") {
                bus.write(1, at: 128)
                bus.write(1, at: 129)

                expect(bus.readWord(at: 128)).to(equal(0b0000000100000001))

                bus.write(64, at: 10)
                bus.write(32, at: 11)
                bus.write(255, at: 12)

                expect(bus.readWord(at: 10)).to(equal(0b0010000001000000))
                expect(bus.readWord(at: 11)).to(equal(0b1111111100100000))
                expect(bus.readWord(at: 12)).to(equal(0b0000000011111111))
            }
        }
    }
}
