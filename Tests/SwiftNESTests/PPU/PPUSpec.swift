import Quick
import Nimble

@testable import SwiftNES

class PPUSpec: QuickSpec {
    override func spec() {
        describe("PPU") {
            var nes: NES!
            beforeEach {
                nes = NES()
            }

            describe("fetchBackgroundPixel") {
                beforeEach {
                    nes.ppu.v = vramAddress(fineYScroll: 5, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                    writePPU(0x11, at: 0x0035, to: &nes)
                    writePPU(0x81, at: 0x003D, to: &nes)

                    writePPU(0x03, at: 0x2B3D, to: &nes)
                    writePPU(0x41, at: 0x2BF7, to: &nes)

                }

                it("update background state") {
                    _ = nes.ppu.scan.nextDot()

                    fetchBackgroundPixel(from: &nes)
                    expect(nes.ppu.bgTempAddr).to(equal(0x2B3D))

                    _ = nes.ppu.scan.nextDot()
                    fetchBackgroundPixel(from: &nes)
                    expect(nes.ppu.nameTableEntry).to(equal(0x03))

                    _ = nes.ppu.scan.nextDot()
                    fetchBackgroundPixel(from: &nes)
                    expect(nes.ppu.bgTempAddr).to(equal(0x2BF7))

                    _ = nes.ppu.scan.nextDot()
                    fetchBackgroundPixel(from: &nes)
                    expect(nes.ppu.attrTableEntry).to(equal(0x41))

                    _ = nes.ppu.scan.nextDot()
                    fetchBackgroundPixel(from: &nes)
                    expect(nes.ppu.bgTempAddr).to(equal(0x0035))

                    _ = nes.ppu.scan.nextDot()
                    fetchBackgroundPixel(from: &nes)
                    // expect(nes.ppu.nextPattern.low).to(equal(0x11))

                    _ = nes.ppu.scan.nextDot()
                    fetchBackgroundPixel(from: &nes)
                    expect(nes.ppu.bgTempAddr).to(equal(0x003D))

                    _ = nes.ppu.scan.nextDot()
                    fetchBackgroundPixel(from: &nes)
                    // expect(nes.ppu.nextPattern.high).to(equal(0x81))
                }
            }
        }
    }
}
