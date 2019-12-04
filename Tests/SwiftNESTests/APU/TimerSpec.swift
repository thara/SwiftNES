import Quick
import Nimble

@testable import SwiftNES

class TimerSpec: QuickSpec {
    override func spec() {
        var timer: Timer!
        beforeEach {
            timer = Timer()
        }

        describe("value") {
            it("returns HHHLLLLLLLL") {
                timer.low = 0b11010111
                timer.high = 0b01010101

                expect(timer.value) == 0b10111010111
            }
        }

        describe("clock") {
            beforeEach {
                timer.sequencer = Sequencer()

                timer.low = 0b11
                timer.high = 0

                timer.load()

                //FIXME ???
                timer.divider.reload()
            }

            context("if counter is zero when clocked") {

                it("sequencer.clocked") {
                    expect(timer.divider.counter) == 3

                    let before = timer.sequencer!.position

                    for _ in 0..<3 {
                        timer.clock()
                    }
                    expect(timer.divider.counter) == 0

                    timer.clock()
                    expect(timer.divider.counter) == 0b11

                    let after = timer.sequencer!.position
                    expect(after) == before + 1
                }
            }
        }
    }
}
