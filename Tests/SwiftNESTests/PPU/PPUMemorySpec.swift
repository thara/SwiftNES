import Nimble
import Quick

@testable import SwiftNES

class PPUMemorySpec: QuickSpec {
    override func spec() {
        describe("toNameTableAddress") {
            let map = PPUMemory()

            context("Vertical mirroring mode") {
                beforeEach {
                    map.mirroring = .vertical
                }

                it("mirror correctly") {
                    expect(map.toNameTableAddress(0x2000)) == 0
                    expect(map.toNameTableAddress(0x23FF)) == 0x03FF
                    expect(map.toNameTableAddress(0x2400)) == 0x0400
                    expect(map.toNameTableAddress(0x27FF)) == 0x07FF
                    expect(map.toNameTableAddress(0x2800)) == 0
                    expect(map.toNameTableAddress(0x2BFF)) == 0x03FF
                    expect(map.toNameTableAddress(0x2C00)) == 0x0400
                    expect(map.toNameTableAddress(0x2FFF)) == 0x07FF
                }
            }

            context("Horizontal mirroring mode") {
                beforeEach {
                    map.mirroring = .horizontal
                }

                it("mirror correctly") {
                    expect(map.toNameTableAddress(0x2000)) == 0
                    expect(map.toNameTableAddress(0x23FF)) == 0x03FF
                    expect(map.toNameTableAddress(0x2400)) == 0
                    expect(map.toNameTableAddress(0x27FF)) == 0x03FF
                    expect(map.toNameTableAddress(0x2800)) == 0x0800
                    expect(map.toNameTableAddress(0x2BFF)) == 0x0BFF
                    expect(map.toNameTableAddress(0x2C00)) == 0x0800
                    expect(map.toNameTableAddress(0x2FFF)) == 0x0BFF
                }
            }
        }
    }
}
