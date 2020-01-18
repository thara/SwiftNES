import Quick
import Nimble

@testable import SwiftNES

class PPUPortSpec: QuickSpec {
    override func spec() {
        var nes: NES!
        beforeEach {
            nes = NES()
        }

        describe("PPUCTRL") {
            let address: UInt16 = 0x2000

            context("write") {
                it("set controller register") {
                    writePPURegister(0b01010000, to: address, on: &nes)
                    expect(nes.ppu.controller).to(equal([.slave, .bgTableAddr]))

                    writePPURegister(0b00000111, to: address, on: &nes)
                    expect(nes.ppu.controller).to(equal([.vramAddrIncr, .nameTableAddrHigh, .nameTableAddrLow]))
                }
            }
        }

        describe("PPUMASK") {
            let address: UInt16 = 0x2001
            context("write") {
                it("set mask register") {
                    writePPURegister(0b01010000, to: address, on: &nes)
                    expect(nes.ppu.mask).to(equal([.green, .sprite]))

                    writePPURegister(0b00000111, to: address, on: &nes)
                    expect(nes.ppu.mask).to(equal([.spriteLeft, .backgroundLeft, .greyscale]))
                }
            }
        }

        describe("PPUSTATUS") {
            let address: UInt16 = 0x2002

            context("read") {
                it("read status and clear vblank and write toggle") {
                    nes.ppu.status = [.vblank, .spriteZeroHit]
                    nes.ppu.writeToggle = true
                    expect(readPPURegister(from: address, on: &nes)).to(equal(0b11000000))
                    expect(nes.ppu.writeToggle).to(beFalsy())

                    expect(readPPURegister(from: address, on: &nes)).to(equal(0b01000000))
                }
            }
        }

        describe("OAMADDR") {
            let address: UInt16 = 0x2003

            context("write") {
                it("write oam address") {
                    writePPURegister(255, to: address, on: &nes)
                    expect(nes.ppu.objectAttributeMemoryAddress).to(equal(255))
                }
            }
        }

        describe("OAMDATA") {
            let address: UInt16 = 0x2004

            context("read") {
                it("read oam data") {
                    nes.ppu.primaryOAM[0x09] = 0xA3
                    writePPURegister(0x09, to: 0x2003, on: &nes)

                    expect(readPPURegister(from: address, on: &nes)).to(equal(0xA3))
                }
            }

            context("write") {
                it("write oam data") {
                    writePPURegister(0xAB, to: 0x2003, on: &nes)
                    writePPURegister(0x32, to: address, on: &nes)

                    expect(nes.ppu.primaryOAM[0xAB]).to(equal(0x32))
                }
            }
        }

        describe("PPUSCROLL") {
            let address: UInt16 = 0x2005

            context("write") {
                it("set scroll position by two write") {
                    writePPURegister(0x1F, to: address, on: &nes)
                    expect(nes.ppu.writeToggle).to(beTruthy())
                    expect(nes.ppu.t.coarseXScroll).to(equal(3))
                    expect(nes.ppu.fineX).to(equal(0x1F & 0b111))

                    writePPURegister(0x0E, to: address, on: &nes)
                    expect(nes.ppu.writeToggle).to(beFalsy())
                    expect(nes.ppu.t.coarseYScroll).to(equal(1))
                }
            }
        }

        describe("PPUADDR") {
            let address: UInt16 = 0x2006

            context("write") {
                it("set current address by two write") {
                    writePPURegister(0x3F, to: address, on: &nes)
                    expect(nes.ppu.writeToggle).to(beTruthy())

                    writePPURegister(0x91, to: address, on: &nes)
                    expect(nes.ppu.writeToggle).to(beFalsy())

                    expect(nes.ppu.v).to(equal(0x3F91))
                    expect(nes.ppu.t).to(equal(0x3F91))
                }
            }
        }

        describe("PPUDATA") {
            let address: UInt16 = 0x2007

            context("write") {
                it("write data at currentAddress in memory") {
                    writePPURegister(0x2F, to: 0x2006, on: &nes)
                    writePPURegister(0x11, to: 0x2006, on: &nes)

                    writePPURegister(0x83, to: address, on: &nes)

                    expect(readPPU(at: 0x2F11, from: &nes)).to(equal(0x83))
                }
            }
        }
    }
}
