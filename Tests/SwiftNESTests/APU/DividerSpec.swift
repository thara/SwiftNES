import Quick
import Nimble

@testable import SwiftNES

class DividerSpec: QuickSpec {
    override func spec() {
        describe("clock") {
            var onNext = false
            let divider = Divider(nextClock: {
                onNext = true
            })

            divider.updatePeriod(using: 3)
            divider.reload()

            context("unless counter is zero") {
                it("decrements counter") {
                    let before = divider.counter

                    divider.clock()

                    let after = divider.counter
                    expect(after) == before - 1
                }
            }

            context("if counter is zero") {
                it("reload counter and run nextClock closure") {
                    for _ in (0..<3) {
                        divider.clock()
                    }
                    let before = divider.counter
                    expect(before) == 0
                    expect(onNext) == false

                    divider.clock()

                    let after = divider.counter
                    expect(after) == 4
                    expect(onNext) == true
                }
            }
        }
    }
}
