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
                envelope.update(by: 0b00010000)

                expect(envelope.parameter) == 0b00010000
            }

            context("constant valume flag off") {
                envelope.update(by: 0b11101111)

                expect(envelope.parameter) == 0
            }
        }
    }
}

