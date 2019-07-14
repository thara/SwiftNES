import Quick
import Nimble

@testable import SwiftNES

class BackgroundSpec: QuickSpec {
    override func spec() {
        describe("Background") {
            var bg: Background!
            beforeEach {
                bg = Background()
            }

            describe("shift") {
                it("shift registers") {
                    bg.tilePatternFirst = 0b10101001
                    bg.tilePatternSecond = 0b00101101
                    bg.tileAttrLow = 0b11001010
                    bg.tileAttrHigh = 0b01111100

                    bg.tileAttrLowLatch = true
                    bg.tileAttrHighLatch = false

                    bg.shift()

                    expect(bg.tilePatternFirst).to(equal(0b101010010))
                    expect(bg.tilePatternSecond).to(equal(0b01011010))
                    expect(bg.tileAttrLow).to(equal(0b10010101))
                    expect(bg.tileAttrHigh).to(equal(0b11111000))
                }
            }

            describe("reloadShift") {
                it("reload shift registers") {
                    bg.tilePatternFirst = 0b1010100100101101
                    bg.tilePatternSecond = 0b1110110100011001
                    bg.tileAttrLowLatch = false
                    bg.tileAttrHighLatch = false

                    bg.tempTileFirst = 0b11111111
                    bg.tempTileSecond = 0b00000000
                    bg.attrTableEntry = 0b1010110

                    bg.reloadShift()

                    expect(bg.tilePatternFirst).to(equal(0b1010100111111111))
                    expect(bg.tilePatternSecond).to(equal(0b1110110100000000))
                    expect(bg.tileAttrLowLatch).to(beFalsy())
                    expect(bg.tileAttrHighLatch).to(beTruthy())
                }
            }

            describe("getPaletteIndex") {
                it("create correct pallet index") {
                    bg.tilePatternFirst = 0b010100100101101
                    bg.tilePatternSecond = 0b101110100011001
                    bg.tileAttrLow = 0b1111010
                    bg.tileAttrHigh = 0b1001100

                    let result = bg.getPaletteIndex(fineX: 3)

                    expect(result & 0b0011).to(equal(0b0010))
                    expect(result & 0b1100).to(equal(0b0100))
                }
            }

            describe("addressNameTableEntry") {
                it("set name table address to tempTableAddr") {
                    let v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                    bg.addressNameTableEntry(using: v)

                    expect(bg.tempTableAddr).to(equal(0x2B3D))  // 0b10101100111101
                    expect(bg.tempTableAddr) >= 0x2800 // begin address in second name table
                    expect(bg.tempTableAddr) <= 0x2BBF // end address in second name table
                }
            }

            describe("addressAttrTableEntry") {
                it("set attribute table address to tempTableAddr") {
                    let v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

                    bg.addressAttrTableEntry(using: v)

                    expect(bg.tempTableAddr).to(equal(0x2BF7))  // 0b10101111110111
                    expect(bg.tempTableAddr) >= 0x2Bc0 // begin address in second attribute table
                    expect(bg.tempTableAddr) <= 0x2BFF // end address in second attribute table
                }
            }

            describe("addressTileBitmapLow") {
                context("controller bgTableAddr off") {
                    it("set pattern table address to tempTableAddr") {
                        let v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
                        bg.nameTableEntry = 0x03

                        bg.addressTileBitmapLow(using: v, controller: [])

                        expect(bg.tempTableAddr).to(equal(0x0035))
                    }
                }

                context("controller bgTableAddr on") {
                    it("set pattern table address to tempTableAddr") {
                        let v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
                        bg.nameTableEntry = 0x03

                        bg.addressTileBitmapLow(using: v, controller: .bgTableAddr)

                        expect(bg.tempTableAddr).to(equal(0x1035))
                    }
                }
            }
        }
    }
}
