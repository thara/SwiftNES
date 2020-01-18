import Quick
import Nimble

@testable import SwiftNES

class PPUPortSpec: QuickSpec {
    override func spec() {
        var ppu: PPU!
        beforeEach {
            ppu = PPU()
        }

        describe("PPUCTRL") {
            let address: UInt16 = 0x2000

            context("write") {
                it("set controller register") {
                    ppu.write(0b01010000, to: address)
                    expect(ppu.controller).to(equal([.slave, .bgTableAddr]))

                    ppu.write(0b00000111, to: address)
                    expect(ppu.controller).to(equal([.vramAddrIncr, .nameTableAddrHigh, .nameTableAddrLow]))
                }
            }
        }

        describe("PPUMASK") {
            let address: UInt16 = 0x2001
            context("write") {
                it("set mask register") {
                    ppu.write(0b01010000, to: address)
                    expect(ppu.mask).to(equal([.green, .sprite]))

                    ppu.write(0b00000111, to: address)
                    expect(ppu.mask).to(equal([.spriteLeft, .backgroundLeft, .greyscale]))
                }
            }
        }

        describe("PPUSTATUS") {
            let address: UInt16 = 0x2002

            context("read") {
                it("read status and clear vblank and write toggle") {
                    ppu.status = [.vblank, .spriteZeroHit]
                    ppu.writeToggle = true
                    expect(ppu.read(from: address)).to(equal(0b11000000))
                    expect(ppu.writeToggle).to(beFalsy())

                    expect(ppu.read(from: address)).to(equal(0b01000000))
                }
            }
        }

        describe("OAMADDR") {
            let address: UInt16 = 0x2003

            context("write") {
                it("write oam address") {
                    ppu.write(255, to: address)
                    expect(ppu.objectAttributeMemoryAddress).to(equal(255))
                }
            }
        }

        describe("OAMDATA") {
            let address: UInt16 = 0x2004

            context("read") {
                it("read oam data") {
                    ppu.primaryOAM[0x09] = 0xA3
                    ppu.write(0x09, to: 0x2003)

                    expect(ppu.read(from: address)).to(equal(0xA3))
                }
            }

            context("write") {
                it("write oam data") {
                    ppu.write(0xAB, to: 0x2003)
                    ppu.write(0x32, to: address)

                    expect(ppu.primaryOAM[0xAB]).to(equal(0x32))
                }
            }
        }

        describe("PPUSCROLL") {
            let address: UInt16 = 0x2005

            context("write") {
                it("set scroll position by two write") {
                    ppu.write(0x1F, to: address)
                    expect(ppu.writeToggle).to(beTruthy())
                    expect(ppu.t.coarseXScroll).to(equal(3))
                    expect(ppu.fineX).to(equal(0x1F & 0b111))

                    ppu.write(0x0E, to: address)
                    expect(ppu.writeToggle).to(beFalsy())
                    expect(ppu.t.coarseYScroll).to(equal(1))
                }
            }
        }

        describe("PPUADDR") {
            let address: UInt16 = 0x2006

            context("write") {
                it("set current address by two write") {
                    ppu.write(0x3F, to: address)
                    expect(ppu.writeToggle).to(beTruthy())

                    ppu.write(0x91, to: address)
                    expect(ppu.writeToggle).to(beFalsy())

                    expect(ppu.v).to(equal(0x3F91))
                    expect(ppu.t).to(equal(0x3F91))
                }
            }
        }

        describe("PPUDATA") {
            let address: UInt16 = 0x2007

            context("write") {
                it("write data at currentAddress in memory") {
                    ppu.write(0x2F, to: 0x2006)
                    ppu.write(0x11, to: 0x2006)

                    ppu.write(0x83, to: address)

                    expect(ppu.memory.read(at: 0x2F11)).to(equal(0x83))
                }
            }
        }
    }
}
