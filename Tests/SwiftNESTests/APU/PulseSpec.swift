import Quick
import Nimble

@testable import SwiftNES

class PulseSpec: QuickSpec {
    override func spec() {
        var pulse: Pulse!
        beforeEach {
            pulse = Pulse(carryMode: .onesComplement)
        }

        describe("clock") {
            beforeEach {
                pulse.low = 0b11
                pulse.high = 0

                pulse.timerCounter = 3
            }

            context("if timerCounter is greater than zero") {

                it("decrements timerCounter") {
                    pulse.clock()

                    expect(pulse.timerCounter) == 2
                }
            }

            context("if counter is zero") {

                beforeEach {
                    for _ in 0..<3 {
                        pulse.clock()
                    }
                    expect(pulse.timerCounter) == 0
                }

                it("reloads timerCounter and increments sequencer") {
                    let before = pulse.sequencer

                    pulse.clock()

                    expect(pulse.timerCounter) == 0b11
                    expect(pulse.sequencer) == before + 1
                }

                context("if sequencer become over 8") {
                    beforeEach {
                        pulse.sequencer = 7
                    }

                    it("reset sequencer") {
                        pulse.clock()

                        expect(pulse.sequencer) == 0
                    }
                }
            }
        }

        describe("clockEnvelope") {
            context("start is on") {
                beforeEach {
                    pulse.volume = 0b111
                    pulse.envelope.start = true
                }

                it("updates envelope") {
                    pulse.clockEnvelope()

                    expect(pulse.envelope.decayLevelCounter) == 15
                    expect(pulse.envelope.counter) == pulse.envelopePeriod
                    expect(pulse.envelope.start) == false
                }
            }

            context("start is off") {
                beforeEach {
                    pulse.volume = 0b111
                    pulse.envelope.counter = pulse.envelopePeriod
                    pulse.envelope.start = false
                }

                it("decrements envelope's couter") {
                    let before = pulse.envelope.counter
                    pulse.clockEnvelope()

                    expect(pulse.envelope.counter) == before - 1
                }

                context("envelope's counter is zero after clocked") {
                    beforeEach {
                        pulse.envelope.counter = 1
                    }

                    it("reloads envelope's counter") {
                        pulse.clockEnvelope()

                        expect(pulse.envelope.counter) == pulse.envelopePeriod
                    }

                    context("envelope's decayLevelCounter become to be greater than 0 after clocked") {
                        beforeEach {
                            pulse.envelope.decayLevelCounter = 2
                        }

                        it("decrements envelope's decayLevelCounter") {
                            let before = pulse.envelope.decayLevelCounter

                            pulse.clockEnvelope()

                            expect(pulse.envelope.decayLevelCounter) == before - 1
                        }
                    }

                    context("envelope's decayLevelCounter become 0 after clocked") {
                        beforeEach {
                            pulse.envelope.decayLevelCounter = 0
                        }

                        it("reload envelope's decayLevelCounter and loop enabled") {
                            pulse.clockEnvelope()

                            expect(pulse.envelope.loop) == true
                            expect(pulse.envelope.decayLevelCounter) == 15
                        }
                    }
                }
            }
        }

    }
}
