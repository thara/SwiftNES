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

        describe("sweepUnitMuted") {
            context("timerPeriod < 8") {
                it("returns true") {
                    pulse.timerPeriod = 7
                    expect(pulse.sweepUnitMuted) == true
                }
            }

            context("0x7FF < timerPeriod") {
                it("returns true") {
                    pulse.timerPeriod = 0x800
                    expect(pulse.sweepUnitMuted) == true
                }
            }

            context("8 <= timerPeriod") {
                it("returns true") {
                    pulse.timerPeriod = 8
                    expect(pulse.sweepUnitMuted) == false
                }
            }

            context("timerPeriod <= 0x7FF") {
                it("returns true") {
                    pulse.timerPeriod = 0x7FE
                    expect(pulse.sweepUnitMuted) == false
                }
            }
        }

        describe("clockSweepUnit") {
            beforeEach {
                pulse.sweep = 0b10101000
            }

            context("sweep unit counter is not 0") {
                beforeEach {
                    pulse.sweepUnit.counter = 3
                }

                it("decrements sweep unit counter") {
                    let before = pulse.sweepUnit.counter

                    pulse.clockSweepUnit()

                    expect(pulse.sweepUnit.counter) == before - 1
                }
            }

            context("sweep unit counter is 0") {
                beforeEach {
                    pulse.sweepUnit.counter = 0
                    pulse.sweepUnit.reload = true
                }

                it("reloads sweep unit counter and clear reload flag") {
                    pulse.clockSweepUnit()

                    expect(pulse.sweepUnit.counter) == pulse.sweepPeriod
                    expect(pulse.sweepUnit.reload) == false
                }
            }

            context("sweep unit reload is true") {
                beforeEach {
                    pulse.sweepUnit.counter = 1
                    pulse.sweepUnit.reload = true
                }

                it("reloads sweep unit counter and clear reload flag") {
                    pulse.clockSweepUnit()

                    expect(pulse.sweepUnit.counter) == pulse.sweepPeriod
                    expect(pulse.sweepUnit.reload) == false
                }
            }

            context("sweep unit couner is zero and enabled and not muted") {
                beforeEach {
                    pulse.sweep = 0b10000001
                    pulse.sweepUnit.counter = 0
                    // not muted
                    pulse.timerPeriod = 0b1000
                }

                it("reloads sweep unit counter and clear reload flag") {
                    let before = pulse.timerPeriod

                    pulse.clockSweepUnit()

                    expect(pulse.timerPeriod) == before + 0b100
                }
            }
        }

    }
}
