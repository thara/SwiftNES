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
    }
}
