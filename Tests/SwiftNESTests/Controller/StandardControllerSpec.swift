import Nimble
import Quick

@testable import SwiftNES

class StandardControllerSpec: QuickSpec {
    override func spec() {
        var controller: StandardController!
        beforeEach {
            controller = StandardController()
        }

        describe("read") {
            context("strobe off") {
                beforeEach {
                    controller.update(button: .A)
                }

                it("returns always 0") {
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                }
            }

            context("strobe on") {
                beforeEach {
                    controller.write(1)
                    controller.write(0)
                    controller.update(button: [.A, .B, .up, .left])
                }

                it("returns button state sequentially") {
                    expect(controller.read()) == 0x40 | 1
                    expect(controller.read()) == 0x40 | 1
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 1
                    expect(controller.read()) == 0x40 | 0
                    expect(controller.read()) == 0x40 | 1
                    expect(controller.read()) == 0x40 | 0
                }
            }
        }
    }
}
