import Quick
import Nimble

@testable import SwiftNES

class PPUEmulatorSpec: QuickSpec {
    override func spec() {
        describe("PPUEmulator") {
            var ppu: PPUEmulator!
            beforeEach {
                ppu = PPUEmulator()
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
                    ppu.lineBuffer.nextDot()

                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x2B3D))

                    ppu.lineBuffer.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.nameTableEntry).to(equal(0x03))

                    ppu.lineBuffer.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x2BF7))

                    ppu.lineBuffer.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.attrTableEntry).to(equal(0x41))

                    ppu.lineBuffer.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x0035))

                    ppu.lineBuffer.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTileFirst).to(equal(0x11))

                    ppu.lineBuffer.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x003D))

                    ppu.lineBuffer.nextDot()
                    ppu.updateBackground()
                    expect(ppu.background.tempTileSecond).to(equal(0x81))
                }
            }
        }
    }
}
