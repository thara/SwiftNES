import Quick
import Nimble

@testable import SwiftNES

class PPUPortSpec: QuickSpec {
    override func spec() {
        var ppu: PPUEmulator!
        beforeEach {
            ppu = PPUEmulator(sendNMI: {})
        }

        describe("PPUCTRL") {
            let address: UInt16 = 0x2000

            context("write") {
                it("set controller register") {
                    ppu.write(addr: address, data: 0b01010000)
                    expect(ppu.registers.controller).to(equal([.slave, .bgTableAddr]))

                    ppu.write(addr: address, data: 0b00000111)
                    expect(ppu.registers.controller).to(equal([.vramAddrIncr, .nameTableAddrHigh, .nameTableAddrLow]))
                }
            }
        }

        describe("PPUMASK") {
            let address: UInt16 = 0x2001
            context("write") {
                it("set mask register") {
                    ppu.write(addr: address, data: 0b01010000)
                    expect(ppu.registers.mask).to(equal([.green, .sprite]))

                    ppu.write(addr: address, data: 0b00000111)
                    expect(ppu.registers.mask).to(equal([.spriteLeft, .backgroundLeft, .greyscale]))
                }
            }
        }

        describe("PPUSTATUS") {
            let address: UInt16 = 0x2002

            context("read") {
                it("read status and clear vblank and latch") {
                    ppu.registers.status = [.vblank, .spriteZeroHit]
                    ppu.latch = true
                    expect(ppu.read(addr: address)).to(equal(0b11000000))
                    expect(ppu.latch).to(beFalsy())

                    expect(ppu.read(addr: address)).to(equal(0b01000000))
                }
            }
        }

        describe("OAMADDR") {
            let address: UInt16 = 0x2003

            context("write") {
                it("write oam address") {
                    ppu.write(addr: address, data: 255)
                    expect(ppu.registers.objectAttributeMemoryAddress).to(equal(255))
                }
            }
        }

        describe("OAMDATA") {
            let address: UInt16 = 0x2004

            context("read") {
                it("read oam data") {
                    ppu.oam[0x09] = 0xA3
                    ppu.write(addr: 0x2003, data: 0x09)

                    expect(ppu.read(addr: address)).to(equal(0xA3))
                }
            }

            context("write") {
                it("write oam data") {
                    ppu.write(addr: 0x2003, data: 0xAB)
                    ppu.write(addr: address, data: 0x32)

                    expect(ppu.oam[0xAB]).to(equal(0x32))
                }
            }
        }

        describe("PPUSCROLL") {
            let address: UInt16 = 0x2005

            context("write") {
                it("set scroll position by two write") {
                    ppu.write(addr: address, data: 0x3F)
                    expect(ppu.latch).to(beTruthy())

                    ppu.write(addr: address, data: 0x91)
                    expect(ppu.latch).to(beFalsy())

                    expect(ppu.scrollPosition.x).to(equal(0x3F))
                    expect(ppu.scrollPosition.y).to(equal(0x91))
                }
            }
        }

        describe("PPUADDR") {
            let address: UInt16 = 0x2006

            context("write") {
                it("set current address by two write") {
                    ppu.write(addr: address, data: 0x3F)
                    expect(ppu.latch).to(beTruthy())

                    ppu.write(addr: address, data: 0x91)
                    expect(ppu.latch).to(beFalsy())

                    expect(ppu.currentAddress).to(equal(0x3F91))
                }
            }
        }

        describe("PPUDATA") {
            let address: UInt16 = 0x2007

            context("write") {
                it("write data at currentAddress in memory") {
                    ppu.write(addr: 0x2006, data: 0x0F)
                    ppu.write(addr: 0x2006, data: 0x11)

                    ppu.write(addr: address, data: 0x83)

                    expect(ppu.memory.read(addr: 0x0F11)).to(equal(0x83))
                }
            }
        }
    }
}
