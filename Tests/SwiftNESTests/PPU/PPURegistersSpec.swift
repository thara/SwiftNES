import Quick
import Nimble

@testable import SwiftNES

class PPURegistersSpec: QuickSpec {
    override func spec() {

        describe("incrCoarseX") {
            var registers: PPURegisters!
            beforeEach {
                registers = PPURegisters()
            }

            it("increment coarse X") {
                registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11101)
                expect(registers.v.coarseX).to(equal(29))

                registers.incrCoarseX()
                expect(registers.v.coarseX).to(equal(30))
            }

            context("the next tile is reached") {
                it("switch horizontal nametable") {
                    registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 0b11001, coarseXScroll: 0b11111)
                    expect(registers.v.coarseX).to(equal(31))
                    expect(registers.v.nameTableNo).to(equal(2))

                    registers.incrCoarseX()

                    expect(registers.v.coarseX).to(equal(0))
                    expect(registers.v.nameTableNo).to(equal(3))
                }
            }
        }

        describe("incrY") {
            var registers: PPURegisters!
            beforeEach {
                registers = PPURegisters()
            }

            it("increment fine Y") {
                registers.v = vramAddress(fineYScroll: 0b101, nameTableNo: 2, coarseYScroll: 0b10101, coarseXScroll: 0b11101)

                registers.incrY()
                expect(registers.v).to(equal(0b0110101010111101))
            }

            context("if fine Y == 7") {
                context("the last row of tiles in a nametable") {
                    it("switch vertical nametable") {
                        registers.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 29, coarseXScroll: 0b11101)

                        registers.incrY()
                        expect(registers.v.fineYScroll).to(equal(0))
                        expect(registers.v.nameTableNo).to(equal(0))
                        expect(registers.v.coarseYScroll).to(equal(0))
                        expect(registers.v.coarseXScroll).to(equal(0b11101))
                    }
                }

                context("out of range") {
                    it("clear coarse Y") {
                        registers.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 31, coarseXScroll: 0b11101)

                        registers.incrY()
                        expect(registers.v.fineYScroll).to(equal(0))
                        expect(registers.v.nameTableNo).to(equal(2))
                        expect(registers.v.coarseYScroll).to(equal(0))
                        expect(registers.v.coarseXScroll).to(equal(0b11101))
                    }
                }

                it("increment coarse Y") {
                    registers.v = vramAddress(fineYScroll: 7, nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 0b11101)

                    registers.incrY()
                    expect(registers.v.fineYScroll).to(equal(0))
                    expect(registers.v.nameTableNo).to(equal(2))
                    expect(registers.v.coarseYScroll).to(equal(12))
                    expect(registers.v.coarseXScroll).to(equal(0b11101))
                }
            }
        }

        describe("copyX") {
            var registers: PPURegisters!
            beforeEach {
                registers = PPURegisters()
            }

            it("update coarse X and name table select of VRAM address") {
                registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 29)

                registers.t = 0b110101000101
                expect(registers.t.nameTableNo).to(equal(3))
                expect(registers.t.coarseXScroll).to(equal(5))
                expect(registers.t.coarseYScroll).to(equal(10))

                registers.copyX()

                expect(registers.v.nameTableNo).to(equal(3))
                expect(registers.v.coarseXScroll).to(equal(5))
                expect(registers.v.coarseYScroll).to(equal(11))
            }
        }

        describe("copyY") {
            var registers: PPURegisters!
            beforeEach {
                registers = PPURegisters()
            }

            it("update coarse Y and name table select of VRAM address") {
                registers.v = vramAddress(nameTableNo: 2, coarseYScroll: 11, coarseXScroll: 29)

                registers.t = 0b010101000101
                expect(registers.t.nameTableNo).to(equal(1))
                expect(registers.t.coarseXScroll).to(equal(5))
                expect(registers.t.coarseYScroll).to(equal(10))

                registers.copyY()

                expect(registers.v.nameTableNo).to(equal(0))
                expect(registers.v.coarseXScroll).to(equal(29))
                expect(registers.v.coarseYScroll).to(equal(10))
            }
        }
    }
}
