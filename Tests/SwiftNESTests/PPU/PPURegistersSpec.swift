import Quick
import Nimble

@testable import SwiftNES

class PPURegistersSpec: QuickSpec {
    override func spec() {

        describe("incrCoarseX") {
            var ppu: PPU!
            beforeEach {
                ppu = PPU()
            }

            it("increment coarse X") {
                ppu.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
                expect(ppu.v.coarseX).to(equal(29))

                ppu.incrCoarseX()
                expect(ppu.v.coarseX).to(equal(30))
            }

            context("the next tile is reached") {
                it("switch horizontal nametable") {
                    ppu.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11111)
                    expect(ppu.v.coarseX).to(equal(31))
                    expect(ppu.v.nameTableNo).to(equal(2))

                    ppu.incrCoarseX()

                    expect(ppu.v.coarseX).to(equal(0))
                    expect(ppu.v.nameTableNo).to(equal(3))
                }
            }
        }

        describe("incrY") {
            var ppu: PPU!
            beforeEach {
                ppu = PPU()
            }

            it("increment fine Y") {
                ppu.v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b10101, coarseXScroll: 0b11101)

                ppu.incrY()
                expect(ppu.v).to(equal(0b0110101010111101))
            }

            context("if fine Y == 7") {
                context("the last row of tiles in a nametable") {
                    it("switch vertical nametable") {
                        ppu.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 29, coarseXScroll: 0b11101)

                        ppu.incrY()
                        expect(ppu.v.fineYScroll).to(equal(0))
                        expect(ppu.v.nameTableNo).to(equal(0))
                        expect(ppu.v.coarseYScroll).to(equal(0))
                        expect(ppu.v.coarseXScroll).to(equal(0b11101))
                    }
                }

                context("out of range") {
                    it("clear coarse Y") {
                        ppu.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 31, coarseXScroll: 0b11101)

                        ppu.incrY()
                        expect(ppu.v.fineYScroll).to(equal(0))
                        expect(ppu.v.nameTableNo).to(equal(2))
                        expect(ppu.v.coarseYScroll).to(equal(0))
                        expect(ppu.v.coarseXScroll).to(equal(0b11101))
                    }
                }

                it("increment coarse Y") {
                    ppu.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 0b11101)

                    ppu.incrY()
                    expect(ppu.v.fineYScroll).to(equal(0))
                    expect(ppu.v.nameTableNo).to(equal(2))
                    expect(ppu.v.coarseYScroll).to(equal(12))
                    expect(ppu.v.coarseXScroll).to(equal(0b11101))
                }
            }
        }

        describe("copyX") {
            var ppu: PPU!
            beforeEach {
                ppu = PPU()
            }

            it("update coarse X and name table select of VRAM address") {
                ppu.v = vramAddress(nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 29)

                ppu.t = 0b110101000101
                expect(ppu.t.nameTableNo).to(equal(3))
                expect(ppu.t.coarseXScroll).to(equal(5))
                expect(ppu.t.coarseYScroll).to(equal(10))

                ppu.copyX()

                expect(ppu.v.nameTableNo).to(equal(3))
                expect(ppu.v.coarseXScroll).to(equal(5))
                expect(ppu.v.coarseYScroll).to(equal(11))
            }
        }

        describe("copyY") {
            var ppu: PPU!
            beforeEach {
                ppu = PPU()
            }

            it("update coarse Y and name table select of VRAM address") {
                ppu.v = vramAddress(nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 29)

                ppu.t = 0b010101000101
                expect(ppu.t.nameTableNo).to(equal(1))
                expect(ppu.t.coarseXScroll).to(equal(5))
                expect(ppu.t.coarseYScroll).to(equal(10))

                ppu.copyY()

                expect(ppu.v.nameTableNo).to(equal(0))
                expect(ppu.v.coarseXScroll).to(equal(29))
                expect(ppu.v.coarseYScroll).to(equal(10))
            }
        }
    }
}
