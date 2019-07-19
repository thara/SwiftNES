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
                expect(bus.read(addr: 0)).to(equal(1))
                expect(bus.read(addr: 1)).to(equal(0))
                expect(bus.read(addr: 1023)).to(equal(0))
                expect(bus.read(addr: 1024)).to(equal(52))
                expect(bus.read(addr: 1025)).to(equal(0))
            }

            it("Write & read") {
                bus.write(addr: 256, data: 87)

                expect(bus.read(addr: 255)).to(equal(0))
                expect(bus.read(addr: 256)).to(equal(87))
                expect(bus.read(addr: 257)).to(equal(0))
            }
        }

        describe("ROM") {

            it("load Program") {
                let bus = CPUBus()

                var p: [UInt8]  = Array(repeating: 0, count: 0x4000)
                p[0x0000] = 1
                p[0x0100] = 2
                p[0x1000] = 3

                bus.cartridge = Cartridge(rawData: p)

                expect(bus.read(addr: 0x4020)).to(equal(1))
                expect(bus.read(addr: 0x4120)).to(equal(2))
                expect(bus.read(addr: 0x5020)).to(equal(3))
            }
        }

        describe("readWord") {

            let bus = CPUBus()

            it("read 1 word") {
                bus.write(addr: 128, data: 1)
                bus.write(addr: 129, data: 1)

                expect(bus.readWord(addr: 128)).to(equal(0b0000000100000001))

                bus.write(addr: 10, data: 64)
                bus.write(addr: 11, data: 32)
                bus.write(addr: 12, data: 255)

                expect(bus.readWord(addr: 10)).to(equal(0b0010000001000000))
                expect(bus.readWord(addr: 11)).to(equal(0b1111111100100000))
                expect(bus.readWord(addr: 12)).to(equal(0b0000000011111111))
            }
        }
    }
}
