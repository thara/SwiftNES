import Quick
import Nimble

@testable import SwiftNES

class PPUBusSpec: QuickSpec {
    override func spec() {
        describe("toNameTableAddress") {
            let bus = PPUBus()

            context("Vertical mirroring mode") {
                beforeEach {
                    bus.mirroring = .vertical
                }

                it("mirror correctly") {
                    expect(bus.toNameTableAddress(0x2000)) == 0
                    expect(bus.toNameTableAddress(0x23FF)) == 0x03FF
                    expect(bus.toNameTableAddress(0x2400)) == 0x0400
                    expect(bus.toNameTableAddress(0x27FF)) == 0x07FF
                    expect(bus.toNameTableAddress(0x2800)) == 0
                    expect(bus.toNameTableAddress(0x2BFF)) == 0x03FF
                    expect(bus.toNameTableAddress(0x2C00)) == 0x0400
                    expect(bus.toNameTableAddress(0x2FFF)) == 0x07FF
                }
            }

            context("Horizontal mirroring mode") {
                beforeEach {
                    bus.mirroring = .horizontal
                }

                it("mirror correctly") {
                    expect(bus.toNameTableAddress(0x2000)) == 0
                    expect(bus.toNameTableAddress(0x23FF)) == 0x03FF
                    expect(bus.toNameTableAddress(0x2400)) == 0
                    expect(bus.toNameTableAddress(0x27FF)) == 0x03FF
                    expect(bus.toNameTableAddress(0x2800)) == 0x0800
                    expect(bus.toNameTableAddress(0x2BFF)) == 0x0BFF
                    expect(bus.toNameTableAddress(0x2C00)) == 0x0800
                    expect(bus.toNameTableAddress(0x2FFF)) == 0x0BFF
                }
            }
        }
    }
}
