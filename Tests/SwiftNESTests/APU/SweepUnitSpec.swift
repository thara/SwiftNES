import Quick
import Nimble

@testable import SwiftNES

class SweepUnitSpec: QuickSpec {
    override func spec() {
        var sweepUnit: SweepUnit!
        beforeEach {
            sweepUnit = SweepUnit()
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

        //TODO WIP
    }
}

