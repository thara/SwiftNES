import Quick
import Nimble

@testable import SwiftNES

class SweepUnitSpec: QuickSpec {
    override func spec() {
        var sweepUnit: SweepUnit!
        beforeEach {
            sweepUnit = SweepUnit(carryMode: .onesComplement)
        }

        describe("update") {
            it("updates properties from passed data") {
                sweepUnit.update(by: 0b10101010)

                expect(sweepUnit.enabled) == true
                expect(sweepUnit.divider.period) == 0b011
                expect(sweepUnit.negate) == true
                expect(sweepUnit.shiftCount) == 0b010
                expect(sweepUnit.reloadFlag) == true
            }
        }

        describe("calculateTargetPeriod") {

            context("if not negated") {
                    beforeEach {
                        sweepUnit.update(by: 0b10100011)
                        // negate = false, shift count = 3
                    }
                it("adds changed amount with the period") {
                    let result = sweepUnit.calculateTargetPeriod(0b101010010)
                    // 0b101010010 >> 3 -> 0b101010
                    // 0b101010010 + 42 -> 380
                    expect(result) == 380
                }
            }

            context("if negated") {
                context("carry mode is ones' complement") {
                    beforeEach {
                        sweepUnit = SweepUnit(carryMode: .onesComplement)
                        sweepUnit.update(by: 0b10101010)
                        // negate = true, shift count = 2
                    }
                    it("negated by ones' complement") {
                        let result = sweepUnit.calculateTargetPeriod(0b101010010)
                        // 0b101010010 >> 2 -> 0b1010100
                        // 0b1010100 * -1 - 1 -> -85
                        // 0b101010010 - 85 -> 253
                        expect(result) == 253
                    }
                }

                context("carry mode is twos' complement") {
                    beforeEach {
                        sweepUnit = SweepUnit(carryMode: .twosComplement)
                        sweepUnit.update(by: 0b10101010)
                        // negate = true, shift count = 2
                    }
                    it("negated by ones' complement") {
                        let result = sweepUnit.calculateTargetPeriod(0b101010010)
                        // 0b101010010 >> 2 -> 0b1010100
                        // 0b1010100 * -1 -> -84
                        // 0b101010010 - 84 -> 254
                        expect(result) == 254
                    }
                }
            }
        }

        //TODO WIP
    }
}
