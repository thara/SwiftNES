import Quick
import Nimble

@testable import SwiftNES

class RegisterSpec: QuickSpec {
    override func spec() {

        describe("Registers") {

            it("Sync N to bit 7 of A") {
                var reg = Registers(A: 0, X: 0, Y: 0, S: 0, P: [], PC: 0)

                reg.A = 0b00101111
                expect(reg.P.contains(.N)).to(beFalsy())

                reg.A = 0b10101111
                expect(reg.P.contains(.N)).to(beTruthy())
            }
        }

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
