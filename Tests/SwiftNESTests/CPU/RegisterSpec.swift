import Quick
import Nimble

@testable import SwiftNES

class RegisterSpec: QuickSpec {
    override func spec() {

        describe("UInt8#flagged") {

            context("01010001") {
                let bits = 0b01010001 as UInt8

                it("Carry: on") {
                    expect(bits.flagged(.C)).to(beTruthy())
                }
                it("Zero: on") {
                    expect(bits.flagged(.Z)).to(beFalsy())
                }
                it("IRQ prevention: on") {
                    expect(bits.flagged(.I)).to(beFalsy())
                }
                it("Decimal mode: on") {
                    expect(bits.flagged(.D)).to(beFalsy())
                }
                it("Break mode: on") {
                    expect(bits.flagged(.B)).to(beTruthy())
                }
                it("Reserved: on") {
                    expect(bits.flagged(.R)).to(beFalsy())
                }
                it("Overflow: on") {
                    expect(bits.flagged(.V)).to(beTruthy())
                }
                it("Negative: on") {
                    expect(bits.flagged(.N)).to(beFalsy())
                }
            }

            context("10101110") {
                let bits = 0b10101110 as UInt8

                it("Carry: on") {
                    expect(bits.flagged(.C)).to(beFalsy())
                }
                it("Zero: on") {
                    expect(bits.flagged(.Z)).to(beTruthy())
                }
                it("IRQ prevention: on") {
                    expect(bits.flagged(.I)).to(beTruthy())
                }
                it("Decimal mode: on") {
                    expect(bits.flagged(.D)).to(beTruthy())
                }
                it("Break mode: on") {
                    expect(bits.flagged(.B)).to(beFalsy())
                }
                it("Reserved: on") {
                    expect(bits.flagged(.R)).to(beTruthy())
                }
                it("Overflow: on") {
                    expect(bits.flagged(.V)).to(beFalsy())
                }
                it("Negative: on") {
                    expect(bits.flagged(.N)).to(beTruthy())
                }
            }
        }
    }
}
