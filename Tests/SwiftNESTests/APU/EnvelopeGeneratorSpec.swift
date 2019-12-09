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
            context("constant valume flag on") {
                it("applies the parameter") {
                    envelope.update(by: 0b00011011)

                    expect(envelope.parameter) == 0b1011
                }
            }

            context("constant valume flag off") {
                it("does'nt apply the parameter") {
                    envelope.update(by: 0b11101111)

                    expect(envelope.parameter) == 0
                }
            }
        }
    }
}

