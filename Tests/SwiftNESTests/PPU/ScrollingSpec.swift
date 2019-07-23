import Quick
import Nimble

@testable import SwiftNES

class ScrollingSpec: QuickSpec {
    override func spec() {
        describe("PPU extensions") {
            var ppu: PPU!
            beforeEach {
                ppu = PPU()
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
        }
    }
}
