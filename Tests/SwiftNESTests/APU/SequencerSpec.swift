import Quick
import Nimble

@testable import SwiftNES

class SequencerSpec: QuickSpec {
    override func spec() {
        describe("clock") {
            var sequencer: Sequencer!
            beforeEach {
                sequencer = Sequencer()
            }

            context("position is not 7") {
                it("increases the position") {
                    let before = sequencer.position

                    sequencer.clock()

                    let after = sequencer.position
                    expect(after) == before + 1
                }
            }

            context("position is 7") {
                it("reset counter to 0") {
                    for _ in 0..<7 {
                        sequencer.clock()
                    }
                    sequencer.clock()

                    expect(sequencer.position) == 0
                }
            }
        }

        describe("gate") {
            var sequencer: Sequencer!
            beforeEach {
                sequencer = Sequencer()
            }

            let input: UInt16 = 0x1F

            context("duty is 0") {
                beforeEach {
                    sequencer.update(duty: 0)
                }

                it("makes 12.5% wafeform") {
                    for _ in 0..<3 {
                        expect(sequencer.gate(input: input)) == 0

                        sequencer.clock()
                        expect(sequencer.gate(input: input)) == input

                        for _ in 0..<6 {
                            sequencer.clock()
                            expect(sequencer.gate(input: input)) == 0
                        }

                        sequencer.clock()
                    }
                }
            }

            context("duty is 1") {
                beforeEach {
                    sequencer.update(duty: 1)
                }

                it("makes 25% wafeform") {
                    for _ in 0..<3 {
                        expect(sequencer.gate(input: input)) == 0

                        for _ in 0..<2 {
                            sequencer.clock()
                            expect(sequencer.gate(input: input)) == input
                        }

                        for _ in 0..<5 {
                            sequencer.clock()
                            expect(sequencer.gate(input: input)) == 0
                        }

                        sequencer.clock()
                    }
                }
            }

            context("duty is 2") {
                beforeEach {
                    sequencer.update(duty: 2)
                }

                it("makes 50% wafeform") {
                    for _ in 0..<3 {
                        expect(sequencer.gate(input: input)) == 0

                        for _ in 0..<4 {
                            sequencer.clock()
                            expect(sequencer.gate(input: input)) == input
                        }

                        for _ in 0..<3 {
                            sequencer.clock()
                            expect(sequencer.gate(input: input)) == 0
                        }

                        sequencer.clock()
                    }
                }
            }

            context("duty is 3") {
                beforeEach {
                    sequencer.update(duty: 3)
                }

                it("makes 25% negated wafeform") {
                    for _ in 0..<3 {
                        expect(sequencer.gate(input: input)) == input

                        for _ in 0..<2 {
                            sequencer.clock()
                            expect(sequencer.gate(input: input)) == 0
                        }

                        for _ in 0..<5 {
                            sequencer.clock()
                            expect(sequencer.gate(input: input)) == input
                        }

                        sequencer.clock()
                    }
                }
            }
        }
    }
}
