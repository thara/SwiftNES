import Quick
import Nimble

@testable import SwiftNES

class BackgroundSpec: QuickSpec {
    override func spec() {
        describe("Background") {
            var tile: Tile!
            beforeEach {
                tile = Tile()
            }

            describe("shift") {
                it("shift registers") {
                    tile.pattern.low = 0b10101001
                    tile.pattern.high = 0b00101101
                    tile.attribute.low = 0b11001010
                    tile.attribute.high = 0b01111100

                    tile.attribute.lowLatch = true
                    tile.attribute.highLatch = false

                    tile.shift()

                    expect(tile.pattern.low).to(equal(0b101010010))
                    expect(tile.pattern.high).to(equal(0b01011010))
                    expect(tile.attribute.low).to(equal(0b10010101))
                    expect(tile.attribute.high).to(equal(0b11111000))
                }
            }

            describe("reloadShift") {
                it("reload shift registers") {
                    tile.pattern.low = 0b1010100100101101
                    tile.pattern.high = 0b1110110100011001
                    tile.attribute.lowLatch = false
                    tile.attribute.highLatch = false

                    var nextPattern = TilePattern()
                    nextPattern.low = 0b11111111
                    nextPattern.high = 0b00000000

                    tile.reload(for: nextPattern, attribute: 0b1010110)

                    expect(tile.pattern.low).to(equal(0b1010100111111111))
                    expect(tile.pattern.high).to(equal(0b1110110100000000))
                    expect(tile.attribute.lowLatch).to(beFalsy())
                    expect(tile.attribute.highLatch).to(beTruthy())
                }
            }

            // describe("addressNameTableEntry") {
            //     it("set name table address to tempAddr") {
            //         let v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

            //         bg.addressNameTableEntry(using: v)

            //         expect(bg.tempAddr).to(equal(0x2B3D))  // 0b10101100111101
            //         expect(bg.tempAddr) >= 0x2800 // begin address in second name table
            //         expect(bg.tempAddr) <= 0x2BBF // end address in second name table
            //     }
            // }

            // describe("addressAttrTableEntry") {
            //     it("set attribute table address to tempAddr") {
            //         let v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)

            //         bg.addressAttrTableEntry(using: v)

            //         expect(bg.tempAddr).to(equal(0x2BF7))  // 0b10101111110111
            //         expect(bg.tempAddr) >= 0x2Bc0 // begin address in second attribute table
            //         expect(bg.tempAddr) <= 0x2BFF // end address in second attribute table
            //     }
            // }

            // describe("addressTileBitmapLow") {
            //     context("controller bgTableAddr off") {
            //         it("set pattern table address to tempAddr") {
            //             let v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
            //             bg.nameTableEntry = 0x03

            //             bg.addressTileBitmapLow(using: v, controller: [])

            //             expect(bg.tempAddr).to(equal(0x0035))
            //         }
            //     }

            //     context("controller bgTableAddr on") {
            //         it("set pattern table address to tempAddr") {
            //             let v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
            //             bg.nameTableEntry = 0x03

            //             bg.addressTileBitmapLow(using: v, controller: .bgTableAddr)

            //             expect(bg.tempAddr).to(equal(0x1035))
            //         }
            //     }
            // }

            // describe("getPaletteIndex") {

            //     it("return pallete index at fineX from tile patterns and attributes") {
            //         bg.tilePatternFirst  = 0b0101010101010101
            //         bg.tilePatternSecond = 0b0110110110110110
            //         bg.tileAttrLow       = 0b10110011
            //         bg.tileAttrHigh      = 0b00100101

            //         // NOTE: fine X is a value in range of 0...7
            //         expect(bg.getPaletteIndex(fineX: 0)).to(equal(0b0000))
            //         expect(bg.getPaletteIndex(fineX: 1)).to(equal(0b0011))
            //         expect(bg.getPaletteIndex(fineX: 2)).to(equal(0b1110))
            //         expect(bg.getPaletteIndex(fineX: 3)).to(equal(0b0101))
            //         expect(bg.getPaletteIndex(fineX: 4)).to(equal(0b0010))
            //         expect(bg.getPaletteIndex(fineX: 5)).to(equal(0b1011))
            //         expect(bg.getPaletteIndex(fineX: 6)).to(equal(0b0000))
            //         expect(bg.getPaletteIndex(fineX: 7)).to(equal(0b1111))
            //     }
            // }
        }
    }
}
