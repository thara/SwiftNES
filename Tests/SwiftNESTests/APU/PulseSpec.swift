import Quick
import Nimble

@testable import SwiftNES

class PulseSpec: QuickSpec {
    override func spec() {
        var pulse: PulseChannel!
        beforeEach {
            pulse = PulseChannel(carryMode: .onesComplement)
        }

        describe("clockTimer") {
            beforeEach {
                pulse.low = 0b11
                pulse.high = 0

                pulse.timerCounter = 3
            }

            context("if timerCounter is greater than zero") {

                it("decrements timerCounter") {
                    pulse.clockTimer()

                    expect(pulse.timerCounter) == 2
                }
            }

            context("if counter is zero") {

                beforeEach {
                    for _ in 0..<3 {
                        pulse.clockTimer()
                    }
                    expect(pulse.timerCounter) == 0
                }

                it("reloads timerCounter and increments sequencer") {
                    let before = pulse.sequencer

                    pulse.clockTimer()

                    expect(pulse.timerCounter) == 0b11
                    expect(pulse.sequencer) == before + 1
                }

                context("if sequencer become over 8") {
                    beforeEach {
                        pulse.sequencer = 7
                    }

                    it("reset sequencer") {
                        pulse.clockTimer()

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

                context("if negated") {
                    context("carry mode is ones' complement") {
                        beforeEach {
                            pulse.sweep = 0b10101010
                            // negate = true, shift count = 2
                            pulse.timerPeriod = 0b101010010
                        }

                        it("negated by ones' complement") {
                            pulse.clockSweepUnit()
                            // 0b101010010 >> 2 -> 0b1010100
                            // 0b1010100 * -1 - 1 -> -85
                            // 0b101010010 - 85 -> 253
                            expect(pulse.timerPeriod) == 253
                        }
                    }
                    context("carry mode is twos' complement") {
                        beforeEach {
                            pulse = PulseChannel(carryMode: .twosComplement)
                            pulse.sweep = 0b10101010
                            pulse.sweepUnit.counter = 0
                            // negate = true, shift count = 2
                            pulse.timerPeriod = 0b101010010
                        }

                        it("negated by ones' complement") {
                            pulse.clockSweepUnit()
                            // 0b101010010 >> 2 -> 0b1010100
                            // 0b1010100 * -1 -> -84
                            // 0b101010010 - 84 -> 254
                            expect(pulse.timerPeriod) == 254
                        }
                    }
                }
            }
        }

        describe("clockLengthCounter") {
            context("length counter over 0") {
                beforeEach {
                    pulse.lengthCounter = 3
                }

                context("length counter is halt") {
                    beforeEach {
                        pulse.volume = 0b0100000
                    }

                    it("doesn't decrements the length counter") {
                        let before = pulse.lengthCounter
                        pulse.clockLengthCounter()
                        expect(pulse.lengthCounter) == before
                    }
                }

                context("length counter is not halt") {
                    beforeEach {
                        pulse.volume = 0b1011111
                    }

                    it("decrements the length counter") {
                        let before = pulse.lengthCounter
                        pulse.clockLengthCounter()
                        expect(pulse.lengthCounter) == before &- 1
                    }
                }
            }

            context("length counter is 0") {
                beforeEach {
                    pulse.lengthCounter = 0
                }

                it("doesn't decrements the length counter") {
                    let before = pulse.lengthCounter
                    pulse.clockLengthCounter()
                    expect(pulse.lengthCounter) == before
                }
            }
        }

        describe("high did set") {
            context("if pulse is enabled") {
                beforeEach {
                    pulse.enabled = true
                }

                it("reloads the length counter by lookup table") {
                    pulse.high = 0b10101000
                    // 1 0101 (15)
                    expect(pulse.lengthCounter) == 0x0A
                }
            }

            context("if pulse is disabled") {
                beforeEach {
                    pulse.enabled = false
                }

                it("does't reload the length counter") {
                    let before = pulse.lengthCounter

                    pulse.high = 0b11

                    expect(pulse.lengthCounter) == before
                }
            }
        }
    }
}
