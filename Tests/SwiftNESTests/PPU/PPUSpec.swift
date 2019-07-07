import Foundation
import Quick
import Nimble

@testable import SwiftNES

class PPUSpec: QuickSpec {
    override func spec() {
        var ppu: PPUEmulator!
        beforeEach {
            ppu = PPUEmulator(memory: RAM(memory: NSMutableArray(array: Array(repeating: 0, count: 65536))), sendNMI: {})
        }

        describe("read status") {
            it("clear vblank & latch") {
                ppu.registers.status.formUnion([.vblank, .spriteZeroHit])
                ppu.latch = true

                let status = ppu.status

                expect(status).to(equal([.vblank, .spriteZeroHit]))
                expect(ppu.registers.status).to(equal(.spriteZeroHit))
                expect(ppu.latch).to(beFalsy())
            }
        }

        describe("write scroll") {
            it("set scroll position by two write") {
                ppu.scroll = 0x3F
                expect(ppu.latch).to(beTruthy())

                ppu.scroll = 0x91
                expect(ppu.latch).to(beFalsy())

                expect(ppu.scrollPosition.x).to(equal(0x3F))
                expect(ppu.scrollPosition.y).to(equal(0x91))
            }
        }

        describe("write address") {
            it("set current address by two write") {
                ppu.address = 0x3F
                expect(ppu.latch).to(beTruthy())

                ppu.address = 0x91
                expect(ppu.latch).to(beFalsy())

                expect(ppu.currentAddress).to(equal(0x3F91))
            }
        }

        describe("write data") {
            it("write data at currentAddress in memory") {
                ppu.address = 0xF0
                ppu.address = 0x11

                ppu.data = 0x83

                expect(ppu.memory.read(addr: 0xF011)).to(equal(0x83))
            }
        }
    }
}
