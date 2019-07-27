import Quick
import Nimble

@testable import SwiftNES

class ScanSpec: QuickSpec {
    override func spec() {
        var scan: Scan!
        beforeEach {
            scan = Scan()
        }

        describe("nextDot") {
            context("next line") {
                it("clear dot and increment line") {
                    scan.dot = Scan.maxDot - 1
                    scan.line = 12

                    scan.nextDot()

                    expect(scan.dot) == 0
                    expect(scan.line) == 13
                }
            }

            context("next frame") {
                it("clear dot and line") {
                    scan.dot = Scan.maxDot - 1
                    scan.line = Scan.maxLine - 1

                    scan.nextDot()

                    expect(scan.dot) == 0
                    expect(scan.line) == 0
                }
            }
        }
    }
}
