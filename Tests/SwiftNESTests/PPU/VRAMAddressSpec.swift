import Quick
import Nimble

@testable import SwiftNES

class VRAMAddressSpec: QuickSpec {
    override func spec() {
        describe("coarseXScroll") {
            it("returns coarse X scroll in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.coarseXScroll).to(equal(0b11101))
            }
        }

        describe("coarseYScroll") {
            it("returns coarse Y scroll in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.coarseYScroll).to(equal(0b11001))
            }
        }

        describe("fineYScroll") {
            it("returns fine Y scroll in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.fineYScroll).to(equal(0b101))
            }
        }

        describe("nameTableAddressIndex") {
            it("returns name table index in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.nameTableAddressIndex).to(equal(0b101100111101))
            }
        }

        describe("nameTableSelect") {
            it("returns name table no in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.nameTableSelect).to(equal(0b100000000000))
            }
        }

        describe("attributeAddressIndex") {
            it("returns attribute table index in VRAM address") {
                let addr: UInt16 = 0b1101101100111101
                expect(addr.attributeAddressIndex).to(equal(0b100000110111))
            }
        }
    }
}
