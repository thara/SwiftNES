import Quick
import Nimble

@testable import SwiftNES

class BackgroundSpec: QuickSpec {
    override func spec() {
        var ppu: PPUEmulator!
        beforeEach {
            ppu = PPUEmulator(sendNMI: {})
        }

        describe("nameTableAddr") {
            it("returns name table address in VRAM address") {
                ppu.registers.vramAddr = 0b1101101100111101 // name table no = 2 (0b10)

                expect(ppu.nameTableAddr).to(equal(0x2B3D))  // 0b10101100111101
                expect(ppu.nameTableAddr) >= 0x2800 // begin address in second name table
                expect(ppu.nameTableAddr) <= 0x2BBF // end address in second name table
            }
        }

        describe("attrTableAddr") {
            it("returns attribute table address in VRAM address") {
                ppu.registers.vramAddr = 0b1101101100111101 // name table no = 2 (0b10)

                expect(ppu.attrTableAddr).to(equal(0x2BF7))  // 0b10101111110111
                expect(ppu.attrTableAddr) >= 0x2Bc0 // begin address in second attribute table
                expect(ppu.attrTableAddr) <= 0x2BFF // end address in second attribute table
            }
        }

        describe("bgPatternTableAddr") {
            context("controller bgTableAddr off") {
                it("returns pattern table address") {
                    ppu.registers.vramAddr = 0b1101101100111101
                    ppu.background.nameTableEntry = 0x03

                    expect(ppu.bgPatternTableAddr).to(equal(0x0035))
                }
            }

            context("controller bgTableAddr on") {
                it("returns pattern table address") {
                    ppu.registers.vramAddr = 0b1101101100111101
                    ppu.registers.controller.formUnion(.bgTableAddr)
                    ppu.background.nameTableEntry = 0x03

                    expect(ppu.bgPatternTableAddr).to(equal(0x1035))
                }
            }
        }

        describe("updateBackground") {

            beforeEach {
                ppu.registers.vramAddr = 0b1101101100111101

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
                expect(ppu.background.tileBitmapLow).to(equal(0x11))

                ppu.dot += 1
                ppu.updateBackground()
                expect(ppu.background.tempTableAddr).to(equal(0x003D))

                ppu.dot += 1
                ppu.updateBackground()
                expect(ppu.background.tileBitmapHigh).to(equal(0x81))

                expect(ppu.registers.vramAddr).to(equal(0b1101101100111110))
            }

            context("next tile reached") {
                it("switch horizontal nametable") {
                    ppu.registers.vramAddr = 0b1101101100111111
                    expect(ppu.registers.vramAddr.nameTableSelect).to(equal(0b0000100000000000))

                    ppu.dot = 8
                    ppu.updateBackground()

                    expect(ppu.registers.vramAddr).to(equal(0b1101111100100000))
                    expect(ppu.registers.vramAddr.nameTableSelect).to(equal(0b0000110000000000))
                }
            }
        }
    }
}
