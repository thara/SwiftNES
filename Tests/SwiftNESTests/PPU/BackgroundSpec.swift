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

        describe("incrCoarseX") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("increment coarse X") {
                ppu.registers.vramAddr = 0b1101101100111101
                expect(ppu.registers.vramAddr.coarseX).to(equal(29))

                ppu.incrCoarseX()
                expect(ppu.registers.vramAddr.coarseX).to(equal(30))
            }

            context("the next tile is reached") {
                it("switch horizontal nametable") {
                    ppu.registers.vramAddr = 0b1101101100111111
                    expect(ppu.registers.vramAddr.coarseX).to(equal(31))
                    expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))

                    ppu.incrCoarseX()

                    expect(ppu.registers.vramAddr.coarseX).to(equal(0))
                    expect(ppu.registers.vramAddr.nameTableNo).to(equal(3))
                }
            }
        }

        describe("incrY") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("increment fine Y") {
                ppu.registers.vramAddr = 0b0101101010111101
                ppu.incrY()
                expect(ppu.registers.vramAddr).to(equal(0b0110101010111101))
            }

            context("if fine Y == 7") {
                context("the last row of tiles in a nametable") {
                    it("switch vertical nametable") {
                        ppu.registers.vramAddr = 0b0111101110111101
                        expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))
                        expect(ppu.registers.vramAddr.fineYScroll).to(equal(7))
                        expect(ppu.registers.vramAddr.coarseYScroll).to(equal(29))

                        ppu.incrY()
                        expect(ppu.registers.vramAddr.nameTableNo).to(equal(0))
                        expect(ppu.registers.vramAddr.fineYScroll).to(equal(0))
                        expect(ppu.registers.vramAddr.coarseYScroll).to(equal(0))
                    }
                }

                context("out of range") {
                    it("clear coarse Y") {
                        ppu.registers.vramAddr = 0b0111101111111101
                        expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))
                        expect(ppu.registers.vramAddr.fineYScroll).to(equal(7))
                        expect(ppu.registers.vramAddr.coarseYScroll).to(equal(31))

                        ppu.incrY()
                        expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))
                        expect(ppu.registers.vramAddr.fineYScroll).to(equal(0))
                        expect(ppu.registers.vramAddr.coarseYScroll).to(equal(0))
                    }
                }

                it("increment coarse Y") {
                    ppu.registers.vramAddr = 0b0111100101111101
                    expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))
                    expect(ppu.registers.vramAddr.fineYScroll).to(equal(7))
                    expect(ppu.registers.vramAddr.coarseYScroll).to(equal(11))

                    ppu.incrY()
                    expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))
                    expect(ppu.registers.vramAddr.fineYScroll).to(equal(0))
                    expect(ppu.registers.vramAddr.coarseYScroll).to(equal(12))
                }
            }

        }

        describe("updateHorizontalPosition") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("update coarse X and name table select of VRAM address") {
                ppu.registers.vramAddr = 0b100101111101
                expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))
                expect(ppu.registers.vramAddr.coarseXScroll).to(equal(29))
                expect(ppu.registers.vramAddr.coarseYScroll).to(equal(11))

                ppu.registers.tempAddr = 0b110101000101
                expect(ppu.registers.tempAddr.nameTableNo).to(equal(3))
                expect(ppu.registers.tempAddr.coarseXScroll).to(equal(5))
                expect(ppu.registers.tempAddr.coarseYScroll).to(equal(10))

                ppu.updateHorizontalPosition()

                expect(ppu.registers.vramAddr.nameTableNo).to(equal(3))
                expect(ppu.registers.vramAddr.coarseXScroll).to(equal(5))
                expect(ppu.registers.vramAddr.coarseYScroll).to(equal(11))
            }
        }

        describe("updateVerticalPosition") {
            beforeEach {
                ppu.registers.mask = [.background]
            }

            it("update coarse Y and name table select of VRAM address") {
                ppu.registers.vramAddr = 0b100101111101
                expect(ppu.registers.vramAddr.nameTableNo).to(equal(2))
                expect(ppu.registers.vramAddr.coarseXScroll).to(equal(29))
                expect(ppu.registers.vramAddr.coarseYScroll).to(equal(11))

                ppu.registers.tempAddr = 0b010101000101
                expect(ppu.registers.tempAddr.nameTableNo).to(equal(1))
                expect(ppu.registers.tempAddr.coarseXScroll).to(equal(5))
                expect(ppu.registers.tempAddr.coarseYScroll).to(equal(10))

                ppu.updateVerticalPosition()

                expect(ppu.registers.vramAddr.nameTableNo).to(equal(0))
                expect(ppu.registers.vramAddr.coarseXScroll).to(equal(29))
                expect(ppu.registers.vramAddr.coarseYScroll).to(equal(10))
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
