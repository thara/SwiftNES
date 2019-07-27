import Quick
import Nimble

@testable import SwiftNES

class PPUSpec: QuickSpec {
    override func spec() {
        describe("PPU") {
            var ppu: PPU!
            beforeEach {
                ppu = PPU()
            }

            describe("updateBackground") {
                beforeEach {
                    ppu.registers.v = vramAddress(fineYScroll: 5, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                    ppu.memory.write(0x11, at: 0x0035)
                    ppu.memory.write(0x81, at: 0x003D)

                    ppu.memory.write(0x03, at: 0x2B3D)
                    ppu.memory.write(0x41, at: 0x2BF7)

                }

                it("update background state") {
                    ppu.scan.nextDot()

                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x2B3D))

                    ppu.scan.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.nameTableEntry).to(equal(0x03))

                    ppu.scan.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x2BF7))

                    ppu.scan.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.attrTableEntry).to(equal(0x41))

                    ppu.scan.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x0035))

                    ppu.scan.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTileFirst).to(equal(0x11))

                    ppu.scan.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x003D))

                    ppu.scan.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTileSecond).to(equal(0x81))
                }
            }
        }
    }
}
