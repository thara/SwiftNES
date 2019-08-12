import Quick
import Nimble

@testable import SwiftNES

class StandardControllerSpec: QuickSpec {
    override func spec() {
        var controller: StandardController!
        beforeEach {
            controller = StandardController()
        }

        describe("read") {
            context("before polling") {
                beforeEach {
                    controller.press(button: .A)
                }

                it("returns always 0") {
                    expect(controller.read()) == 0
                    expect(controller.read()) == 0
                    expect(controller.read()) == 0
                    expect(controller.read()) == 0
                    expect(controller.read()) == 0
                    expect(controller.read()) == 0
                    expect(controller.read()) == 0
                    expect(controller.read()) == 0
                }
            }

            context("duaring polling") {
                beforeEach {
                    controller.polling = true
                    controller.press(button: .A)
                }

                it("returns always A button state") {
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                }
            }

            context("after polling") {
                beforeEach {
                    controller.polling = true
                    controller.press(button: [.A, .B, .up, .left])
                    controller.polling = false
                }

                it("returns button state sequentially") {
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 0
                    expect(controller.read()) == 0x40 & 0
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 0
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 0

                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                    expect(controller.read()) == 0x40 & 1
                }
            }
        }
    }
}
