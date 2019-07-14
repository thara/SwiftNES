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
                ppu.registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                expect(ppu.nameTableAddr).to(equal(0x2B3D))  // 0b10101100111101
                expect(ppu.nameTableAddr) >= 0x2800 // begin address in second name table
                expect(ppu.nameTableAddr) <= 0x2BBF // end address in second name table
            }
        }

        describe("attrTableAddr") {
            it("returns attribute table address in VRAM address") {
                ppu.registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                expect(ppu.attrTableAddr).to(equal(0x2BF7))  // 0b10101111110111
                expect(ppu.attrTableAddr) >= 0x2Bc0 // begin address in second attribute table
                expect(ppu.attrTableAddr) <= 0x2BFF // end address in second attribute table
            }
        }

        describe("bgPatternTableAddr") {
            context("controller bgTableAddr off") {
                it("returns pattern table address") {
                    ppu.registers.v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
                    ppu.background.nameTableEntry = 0x03

                    expect(ppu.bgPatternTableAddr).to(equal(0x0035))
                }
            }

            context("controller bgTableAddr on") {
                it("returns pattern table address") {
                    ppu.registers.v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
                    ppu.registers.controller.formUnion(.bgTableAddr)
                    ppu.background.nameTableEntry = 0x03

                    expect(ppu.bgPatternTableAddr).to(equal(0x1035))
                }
            }
        }

        describe("incrCoarseX") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("increment coarse X") {
                ppu.registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
                expect(ppu.registers.v.coarseX).to(equal(29))

                ppu.incrCoarseX()
                expect(ppu.registers.v.coarseX).to(equal(30))
            }

            context("the next tile is reached") {
                it("switch horizontal nametable") {
                    ppu.registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11111)
                    expect(ppu.registers.v.coarseX).to(equal(31))
                    expect(ppu.registers.v.nameTableNo).to(equal(2))

                    ppu.incrCoarseX()

                    expect(ppu.registers.v.coarseX).to(equal(0))
                    expect(ppu.registers.v.nameTableNo).to(equal(3))
                }
            }
        }

        describe("incrY") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("increment fine Y") {
                ppu.registers.v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b10101, coarseXScroll: 0b11101)
                ppu.incrY()
                expect(ppu.registers.v).to(equal(0b0110101010111101))
            }

            context("if fine Y == 7") {
                context("the last row of tiles in a nametable") {
                    it("switch vertical nametable") {
                        ppu.registers.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 29, coarseXScroll: 0b11101)

                        ppu.incrY()
                        expect(ppu.registers.v.fineYScroll).to(equal(0))
                        expect(ppu.registers.v.nameTableNo).to(equal(0))
                        expect(ppu.registers.v.coarseYScroll).to(equal(0))
                        expect(ppu.registers.v.coarseXScroll).to(equal(0b11101))
                    }
                }

                context("out of range") {
                    it("clear coarse Y") {
                        ppu.registers.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 31, coarseXScroll: 0b11101)

                        ppu.incrY()
                        expect(ppu.registers.v.fineYScroll).to(equal(0))
                        expect(ppu.registers.v.nameTableNo).to(equal(2))
                        expect(ppu.registers.v.coarseYScroll).to(equal(0))
                        expect(ppu.registers.v.coarseXScroll).to(equal(0b11101))
                    }
                }

                it("increment coarse Y") {
                    ppu.registers.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 0b11101)

                    ppu.incrY()
                    expect(ppu.registers.v.fineYScroll).to(equal(0))
                    expect(ppu.registers.v.nameTableNo).to(equal(2))
                    expect(ppu.registers.v.coarseYScroll).to(equal(12))
                    expect(ppu.registers.v.coarseXScroll).to(equal(0b11101))
                }
            }

        }

        describe("updateHorizontalPosition") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("update coarse X and name table select of VRAM address") {
                ppu.registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 29)

                ppu.registers.t = 0b110101000101
                expect(ppu.registers.t.nameTableNo).to(equal(3))
                expect(ppu.registers.t.coarseXScroll).to(equal(5))
                expect(ppu.registers.t.coarseYScroll).to(equal(10))

                ppu.updateHorizontalPosition()

                expect(ppu.registers.v.nameTableNo).to(equal(3))
                expect(ppu.registers.v.coarseXScroll).to(equal(5))
                expect(ppu.registers.v.coarseYScroll).to(equal(11))
            }
        }

        describe("updateVerticalPosition") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("update coarse Y and name table select of VRAM address") {
                ppu.registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 29)

                ppu.registers.t = 0b010101000101
                expect(ppu.registers.t.nameTableNo).to(equal(1))
                expect(ppu.registers.t.coarseXScroll).to(equal(5))
                expect(ppu.registers.t.coarseYScroll).to(equal(10))

                ppu.updateVerticalPosition()

                expect(ppu.registers.v.nameTableNo).to(equal(0))
                expect(ppu.registers.v.coarseXScroll).to(equal(29))
                expect(ppu.registers.v.coarseYScroll).to(equal(10))
            }
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

        describe("getBackgroundPaletteIndex") {
            it("create correct pallet index") {
                ppu.registers.fineX = 3
                ppu.background.tilePatternFirst = 0b010100100101101
                ppu.background.tilePatternSecond = 0b101110100011001
                ppu.background.tileAttrLow = 0b1111010
                ppu.background.tileAttrHigh = 0b1001100

                let result = ppu.getBackgroundPaletteIndex()

                expect(result & 0b0011).to(equal(0b0010))
                expect(result & 0b1100).to(equal(0b0100))
            }
        }

        describe("shift") {
            it("shift registers") {
                ppu.background.tilePatternFirst = 0b10101001
                ppu.background.tilePatternSecond = 0b00101101
                ppu.background.tileAttrLow = 0b11001010
                ppu.background.tileAttrHigh = 0b01111100

                ppu.background.tileAttrLowLatch = true
                ppu.background.tileAttrHighLatch = false

                ppu.background.shift()

                expect(ppu.background.tilePatternFirst).to(equal(0b101010010))
                expect(ppu.background.tilePatternSecond).to(equal(0b01011010))
                expect(ppu.background.tileAttrLow).to(equal(0b10010101))
                expect(ppu.background.tileAttrHigh).to(equal(0b11111000))
            }
        }

        describe("reloadShift") {
            it("reload shift registers") {
                ppu.background.tilePatternFirst = 0b1010100100101101
                ppu.background.tilePatternSecond = 0b1110110100011001
                ppu.background.tileAttrLowLatch = false
                ppu.background.tileAttrHighLatch = false

                ppu.background.tempTileFirst = 0b11111111
                ppu.background.tempTileSecond = 0b00000000
                ppu.background.attrTableEntry = 0b1010110

                ppu.background.reloadShift()

                expect(ppu.background.tilePatternFirst).to(equal(0b1010100111111111))
                expect(ppu.background.tilePatternSecond).to(equal(0b1110110100000000))
                expect(ppu.background.tileAttrLowLatch).to(beFalsy())
                expect(ppu.background.tileAttrHighLatch).to(beTruthy())
            }
        }
    }
}

private func vramAddress(fineYScroll: UInt16 = 0, nameTableNo: UInt16, coarseYScroll: UInt16, coarseXScroll: UInt16) -> UInt16 {
    return (fineYScroll << 12) | (nameTableNo << 10) | (coarseYScroll << 5) | coarseXScroll
}
