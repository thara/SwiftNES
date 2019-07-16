import Quick
import Nimble

@testable import SwiftNES

class PPUEmulatorSpec: QuickSpec {
    override func spec() {
        describe("PPUEmulator") {
            var ppu: PPUEmulator!
            beforeEach {
                ppu = PPUEmulator(sendNMI: {})
            }

            describe("updateBackground") {
                beforeEach {
                    ppu.registers.v = vramAddress(fineYScroll: 5, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                    ppu.memory.write(addr: 0x0035, data: 0x11)
                    ppu.memory.write(addr: 0x003D, data: 0x81)

                    ppu.memory.write(addr: 0x2B3D, data: 0x03)
                    ppu.memory.write(addr: 0x2BF7, data: 0x41)

                }

                it("update background state") {
                    ppu.dot = 1

                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x2B3D))

                    ppu.dot += 1
                    ppu.updateBackground()
                    expect(ppu.background.nameTableEntry).to(equal(0x03))

                    ppu.dot += 1
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x2BF7))

                    ppu.dot += 1
                    ppu.updateBackground()
                    expect(ppu.background.attrTableEntry).to(equal(0x41))

                    ppu.dot += 1
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x0035))

                    ppu.dot += 1
                    ppu.updateBackground()
                    expect(ppu.background.tempTileFirst).to(equal(0x11))

                    ppu.dot += 1
                    ppu.updateBackground()
                    expect(ppu.background.tempTableAddr).to(equal(0x003D))

                    ppu.dot += 1
                    ppu.updateBackground()
                    expect(ppu.background.tempTileSecond).to(equal(0x81))
                }
            }
        }
    }
}
