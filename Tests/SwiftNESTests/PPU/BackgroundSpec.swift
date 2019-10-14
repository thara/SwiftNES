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
                    tile.currentPattern.low = 0b10101001
                    tile.currentPattern.high = 0b00101101
                    tile.currentAttribute.low = 0b11001010
                    tile.currentAttribute.high = 0b01111100

                    tile.currentAttribute.lowLatch = true
                    tile.currentAttribute.highLatch = false

                    tile.shift()

                    expect(tile.currentPattern.low).to(equal(0b101010010))
                    expect(tile.currentPattern.high).to(equal(0b01011010))
                    expect(tile.currentAttribute.low).to(equal(0b10010101))
                    expect(tile.currentAttribute.high).to(equal(0b11111000))
                }
            }

            describe("reloadShift") {
                it("reload shift registers") {
                    tile.currentPattern.low = 0b1010100100101101
                    tile.currentPattern.high = 0b1110110100011001
                    tile.currentAttribute.lowLatch = false
                    tile.currentAttribute.highLatch = false

                    var nextPattern = BackgroundTileShiftRegisters()
                    nextPattern.low = 0b11111111
                    nextPattern.high = 0b00000000

                    tile.reload(for: nextPattern, with: 0b1010110)

                    expect(tile.currentPattern.low).to(equal(0b1010100111111111))
                    expect(tile.currentPattern.high).to(equal(0b1110110100000000))
                    expect(tile.currentAttribute.lowLatch).to(beFalsy())
                    expect(tile.currentAttribute.highLatch).to(beTruthy())
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

            //     it("return pallete index at fineX from tile.currentPatterns and attributes") {
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
