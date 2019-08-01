import Foundation
import Quick
import Nimble

@testable import SwiftNES

class Mapper0Spec: QuickSpec {
    override func spec() {
        describe("initialize") {
            it("load programROM & characterROM") {
                let path = "Tests/SwiftNESTests/fixtures/helloworld/sample1.nes"
                let mapper = Mapper0(file: try! NESFile(path: path))

                expect(mapper.program.count).to(beGreaterThan(0))
                expect(mapper.characterData.count).to(beGreaterThan(0))
            }
        }
    }
}
