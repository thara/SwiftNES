import Quick
import Nimble

@testable import SwiftNES

class PPUMemoryMapSpec: QuickSpec {
    override func spec() {
        describe("toNameTableAddress") {
            context("Vertical mirroring mode") {
                let mirroring: Mirroring = .vertical

                it("mirror correctly") {
                    expect(toNameTableAddress(0x2000, mirroring: mirroring)) == 0
                    expect(toNameTableAddress(0x23FF, mirroring: mirroring)) == 0x03FF
                    expect(toNameTableAddress(0x2400, mirroring: mirroring)) == 0x0400
                    expect(toNameTableAddress(0x27FF, mirroring: mirroring)) == 0x07FF
                    expect(toNameTableAddress(0x2800, mirroring: mirroring)) == 0
                    expect(toNameTableAddress(0x2BFF, mirroring: mirroring)) == 0x03FF
                    expect(toNameTableAddress(0x2C00, mirroring: mirroring)) == 0x0400
                    expect(toNameTableAddress(0x2FFF, mirroring: mirroring)) == 0x07FF
                }
            }

            context("Horizontal mirroring mode") {
                let mirroring: Mirroring = .horizontal

                it("mirror correctly") {
                    expect(toNameTableAddress(0x2000, mirroring: mirroring)) == 0
                    expect(toNameTableAddress(0x23FF, mirroring: mirroring)) == 0x03FF
                    expect(toNameTableAddress(0x2400, mirroring: mirroring)) == 0
                    expect(toNameTableAddress(0x27FF, mirroring: mirroring)) == 0x03FF
                    expect(toNameTableAddress(0x2800, mirroring: mirroring)) == 0x0800
                    expect(toNameTableAddress(0x2BFF, mirroring: mirroring)) == 0x0BFF
                    expect(toNameTableAddress(0x2C00, mirroring: mirroring)) == 0x0800
                    expect(toNameTableAddress(0x2FFF, mirroring: mirroring)) == 0x0BFF
                }
            }
        }
    }
}
