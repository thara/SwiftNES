import Quick
import Nimble

@testable import SwiftNES

class EnvelopeGeneratorSpec: QuickSpec {
    override func spec() {
        var envelope: EnvelopeGenerator!
        beforeEach {
            envelope = EnvelopeGenerator()
        }

        describe("update") {
            context("constantVolumeFlag is off") {
                it("updates the divider's period") {
                    envelope.update(by: 0b00000111)

                    expect(envelope.divider.period) == 0b1000
                }
            }
            context("constantVolumeFlag is on") {
                it("updates the constant volume and the divider's period") {
                    envelope.update(by: 0b00010101)

                    expect(envelope.constantVolume) == 0b101
                    expect(envelope.divider.period) == 0b110
                }
            }
        }

        describe("clock") {
            context("startFlag is off") {
                beforeEach {
                    envelope.divider.updatePeriod(using: 0b101)
                    envelope.divider.reload()
                    envelope.decayLevelCounter.reload()
                }

                it("clocks the divider") {
                    let before = (envelope.divider.counter, envelope.decayLevelCounter.counter)

                    envelope.clock()

                    let after = (envelope.divider.counter, envelope.decayLevelCounter.counter)

                    expect(after.0) == before.0 - 1
                    expect(after.1) == before.1
                }

                context("divider is zero after clocked") {
                    beforeEach {
                        envelope.divider.updatePeriod(using: 0)
                        envelope.divider.reload()
                        envelope.decayLevelCounter.reload()
                    }

                    it("also clocks the decay level counter") {
                        let before = (envelope.divider.counter, envelope.decayLevelCounter.counter)

                        envelope.clock()

                        let after = (envelope.divider.counter, envelope.decayLevelCounter.counter)

                        expect(after.0) == before.0 - 1
                        expect(after.1) == before.1 - 1
                    }
                }
            }

            context("startFlag is on") {
                beforeEach {
                    envelope.divider.updatePeriod(using: 0b101)
                    envelope.divider.reload()
                    envelope.decayLevelCounter.reload()

                    for _ in 0..<3 {
                        envelope.clock()
                    }

                    envelope.restart()
                }

                it("reloads the divider and the decay level counter") {
                    envelope.clock()

                    expect(envelope.divider.counter) == 0b110
                    expect(envelope.decayLevelCounter.counter) == 15
                }
            }
        }
    }
}
