import Quick
import Nimble

@testable import SwiftNES

class LengthCounterSpec: QuickSpec {
    override func spec() {
        var lengthCounter: LengthCounter!
        beforeEach {
            lengthCounter = LengthCounter()
        }

        describe("reload") {
            context("if enabled") {
                beforeEach {
                    lengthCounter.enabled = true
                }
                it("set counter by lookup table") {
                    lengthCounter.reload(by: 0b11111)
                    expect(lengthCounter.counter) == 30
                }
            }

            context("if disabled") {
                it("doesn't set counter by lookup table") {
                    lengthCounter.reload(by: 0b11111)
                    expect(lengthCounter.counter) == 0
                }
            }
        }
        describe("clock") {
            beforeEach {
                lengthCounter.enabled = true
                lengthCounter.reload(by: 0b10111)
            }

            context("if counter is not zero and not halt") {
                it("decreases counter") {
                    let before = lengthCounter.counter

                    lengthCounter.clock()

                    let after = lengthCounter.counter
                    expect(after) == before - 1
                }
            }
        }
    }
}

