import Nimble
import Quick

@testable import SwiftNES

class PulseSpec: QuickSpec {
    override func spec() {
        var pulse: PulseChannel!
        beforeEach {
            pulse = PulseChannel(carryMode: .onesComplement)
        }

        describe("registers") {
            describe("0x4000") {
                it("duty, length halt, constant volume, period") {
                    pulse.write(0b10111111, at: 0x4000)

                    expect(pulse.dutyCycle) == 0b10
                    expect(pulse.lengthCounterHalt) == true
                    expect(pulse.useConstantVolume) == true
                    expect(pulse.envelopePeriod) == 0b1111
                }
            }

            describe("0x4001") {
                it("enable sweep, period, negate, amount") {
                    pulse.write(0b10101011, at: 0x4001)

                    expect(pulse.sweepEnabled) == true
                    expect(pulse.sweepPeriod) == 0b010
                    expect(pulse.sweepNegate) == true
                    expect(pulse.sweepShift) == 0b011
                }
            }

            describe("0x4002 & 0x4003") {
                it("timer") {
                    pulse.write(0b00000100, at: 0x4002)
                    pulse.write(0b11111011, at: 0x4003)

                    expect(pulse.timerReload) == 0b011_00000100
                    expect(pulse.lengthCounterLoad) == 0b11111
                }
            }
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
                    let before = pulse.timerSequencer

                    pulse.clockTimer()

                    expect(pulse.timerCounter) == 0b11
                    expect(pulse.timerSequencer) == before + 1
                }

                context("if sequencer become over 8") {
                    beforeEach {
                        pulse.timerSequencer = 7
                    }

                    it("reset sequencer") {
                        pulse.clockTimer()

                        expect(pulse.timerSequencer) == 0
                    }
                }
            }
        }

        describe("clockEnvelope") {
            context("start is on") {
                beforeEach {
                    pulse.volume = 0b111
                    pulse.envelopeStart = true
                }

                it("updates envelope") {
                    pulse.clockEnvelope()

                    expect(pulse.envelopeDecayLevelCounter) == 15
                    expect(pulse.envelopeCounter) == pulse.envelopePeriod
                    expect(pulse.envelopeStart) == false
                }
            }

            context("start is off") {
                beforeEach {
                    pulse.volume = 0b111
                    pulse.envelopeCounter = pulse.envelopePeriod
                    pulse.envelopeStart = false
                }

                context("envelope's counter is greater than zero after clocked") {
                    beforeEach {
                        pulse.envelopeCounter = 2
                    }

                    it("decrements envelope's couter") {
                        let before = pulse.envelopeCounter
                        pulse.clockEnvelope()

                        expect(pulse.envelopeCounter) == before - 1
                    }
                }

                context("envelope's counter is zero after clocked") {
                    beforeEach {
                        pulse.envelopeCounter = 0
                    }

                    it("reloads envelope's counter") {
                        pulse.clockEnvelope()

                        expect(pulse.envelopeCounter) == pulse.envelopePeriod
                    }

                    context("envelope's decayLevelCounter become to be greater than 0 after clocked") {
                        beforeEach {
                            pulse.envelopeDecayLevelCounter = 2
                        }

                        it("decrements envelope's decayLevelCounter") {
                            let before = pulse.envelopeDecayLevelCounter

                            pulse.clockEnvelope()

                            expect(pulse.envelopeDecayLevelCounter) == before - 1
                        }
                    }

                    context("envelope's decayLevelCounter become 0 after clocked") {
                        beforeEach {
                            pulse.volume = 0b100000
                            pulse.envelopeDecayLevelCounter = 0
                        }

                        it("reload envelope's decayLevelCounter and loop enabled") {
                            pulse.clockEnvelope()

                            expect(pulse.envelopeDecayLevelCounter) == 15
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
                    pulse.sweepCounter = 3
                }

                it("decrements sweep unit counter") {
                    let before = pulse.sweepCounter

                    pulse.clockSweepUnit()

                    expect(pulse.sweepCounter) == before - 1
                }
            }

            context("sweep unit counter is 0") {
                beforeEach {
                    pulse.sweepCounter = 0
                    pulse.sweepReload = true
                }

                it("reloads sweep unit counter and clear reload flag") {
                    pulse.clockSweepUnit()

                    expect(pulse.sweepCounter) == pulse.sweepPeriod
                    expect(pulse.sweepReload) == false
                }
            }

            context("sweep unit reload is true") {
                beforeEach {
                    pulse.sweepCounter = 1
                    pulse.sweepReload = true
                }

                it("reloads sweep unit counter and clear reload flag") {
                    pulse.clockSweepUnit()

                    expect(pulse.sweepCounter) == pulse.sweepPeriod
                    expect(pulse.sweepReload) == false
                }
            }

            context("sweep unit couner is zero and enabled and not muted") {
                beforeEach {
                    pulse.sweep = 0b10000001
                    pulse.sweepCounter = 0
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
                            pulse.sweepCounter = 0
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

        describe("enable") {
            context("if pulse is enabled") {
                beforeEach {
                    pulse.enable(true)
                }

                it("reloads the length counter by length table") {
                    pulse.write(0b10101000, at: 0x4003)
                    // 1 0101 (21)
                    expect(pulse.lengthCounter) == 0x14
                }
            }

            context("if pulse is disabled") {
                beforeEach {
                    pulse.enable(false)
                }

                it("does't reload the length counter") {
                    let before = pulse.lengthCounter

                    pulse.write(0b11, at: 0x4003)

                    expect(pulse.lengthCounter) == before
                }
            }
        }
    }
}
