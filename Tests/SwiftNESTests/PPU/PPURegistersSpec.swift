import Quick
import Nimble

@testable import SwiftNES

class PPURegistersSpec: QuickSpec {
    override func spec() {
        describe("nameTableIdx") {
            it("returns name table index in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.nameTableIdx).to(equal(0b101100111101))
            }
        }

        describe("coarseXScroll") {
            it("returns coarse X scroll in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.coarseXScroll).to(equal(0b11101))
            }
        }

        describe("attrX") {
            it("returns attribute table X index in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.attrX).to(equal(0b111))
            }
        }

        describe("coarseYScroll") {
            it("returns coarse Y scroll in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.coarseYScroll).to(equal(0b11001))
            }
        }

        describe("attrY") {
            it("returns attribute table Y index in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.attrY).to(equal(0b110))
            }
        }

        describe("nameTableSelect") {
            it("returns name table no in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.nameTableSelect).to(equal(0b100000000000))
            }
        }

        describe("fineYScroll") {
            it("returns fine Y scroll in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.fineYScroll).to(equal(0b101))
            }
        }
    }
}

