import Nimble
import Quick

@testable import SwiftNES

class CPUSpec: QuickSpec {
    override func spec() {
        describe("registers") {
            it("Sync N to bit 7 of A") {
                var cpu = CPU()

                cpu.A = 0b00101111
                expect(cpu.P.contains(.N)).to(beFalsy())

                cpu.A = 0b10101111
                expect(cpu.P.contains(.N)).to(beTruthy())
            }
        }
    }
}
