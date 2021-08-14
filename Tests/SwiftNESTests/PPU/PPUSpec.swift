import Nimble
import Quick

@testable import SwiftNES

class PPUSpec: QuickSpec {
    override func spec() {
        describe("PPU") {
            var ppu: PPU!
            beforeEach {
                ppu = PPU()
            }

            describe("fetchBackgroundPixel") {
                beforeEach {
                    ppu.registers.v = vramAddress(
                        fineYScroll: 5, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                    ppu.bus.write(0x11, at: 0x0035)
                    ppu.bus.write(0x81, at: 0x003D)

                    ppu.bus.write(0x03, at: 0x2B3D)
                    ppu.bus.write(0x41, at: 0x2BF7)

                }

                it("update background state") {
                    _ = ppu.scan.nextDot()

                    ppu.fetchBackgroundPixel()
                    expect(ppu.bgTempAddr).to(equal(0x2B3D))

                    _ = ppu.scan.nextDot()
                    ppu.fetchBackgroundPixel()
                    expect(ppu.nameTableEntry).to(equal(0x03))

                    _ = ppu.scan.nextDot()
                    ppu.fetchBackgroundPixel()
                    expect(ppu.bgTempAddr).to(equal(0x2BF7))

                    _ = ppu.scan.nextDot()
                    ppu.fetchBackgroundPixel()
                    expect(ppu.attrTableEntry).to(equal(0x41))

                    _ = ppu.scan.nextDot()
                    ppu.fetchBackgroundPixel()
                    expect(ppu.bgTempAddr).to(equal(0x0035))

                    _ = ppu.scan.nextDot()
                    ppu.fetchBackgroundPixel()
                    expect(ppu.nextPattern.low).to(equal(0x11))

                    _ = ppu.scan.nextDot()
                    ppu.fetchBackgroundPixel()
                    expect(ppu.bgTempAddr).to(equal(0x003D))

                    _ = ppu.scan.nextDot()
                    ppu.fetchBackgroundPixel()
                    expect(ppu.nextPattern.high).to(equal(0x81))
                }
            }
        }
    }
}
