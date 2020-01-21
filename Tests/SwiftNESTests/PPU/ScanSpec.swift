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
                    scan.dot = NES.maxDot - 1
                    scan.line = 12

                    let update = scan.nextDot()

                    expect(update) == Scan.Update.line(lastLine: 12)
                    expect(scan.dot) == 0
                    expect(scan.line) == 13
                }
            }

            context("next frame") {
                it("clear dot and line") {
                    scan.dot = NES.maxDot - 1
                    scan.line = NES.maxLine

                    let update = scan.nextDot()

                    expect(update) == Scan.Update.frame(lastLine: NES.maxLine)
                    expect(scan.dot) == 0
                    expect(scan.line) == 0
                }
            }
        }
    }
}
