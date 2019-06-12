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

            it("Out of region") {
                expect(mem.read(addr: 2049)).to(equal(0))

                mem.write(addr: 2049, data: 100)
                expect(mem.read(addr: 2049)).to(equal(0))
            }
        }
    }
}
