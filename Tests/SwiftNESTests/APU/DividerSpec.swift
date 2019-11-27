import Quick
import Nimble

@testable import SwiftNES

class DividerSpec: QuickSpec {
    override func spec() {
        describe("clock") {
            var onNext = false
            let divider = Divider() {
                onNext = true
            }

            divider.updatePeriod(using: 3)

            context("unless counter is zero") {
                it("decrement counter") {
                    let before = divider.counter

                    divider.clock()

                    let after = divider.counter
                    expect(after) == before - 1
                }
            }
        }
    }
}
