import Foundation
import Nimble
import Quick

@testable import SwiftNES

class NESFileSpec: QuickSpec {
    override func spec() {
        describe("NESFileHeader") {
            context("correct header format") {
                it("valid") {
                    let data: [UInt8] = [
                        0x4E, 0x45, 0x53, 0x1A,
                        0x93, 0x34,
                        0xF1, 0xF2, 0xF3, 0xF4, 0xF5,
                        0x00, 0x00, 0x00, 0x00, 0x00,
                    ]
                    let header = NESFileHeader(bytes: data)

                    expect(header.valid()).to(beTruthy())
                    expect(header.programROMSizeOfUnit).to(equal(0x93))
                    expect(header.characterROMSizeOfUnit).to(equal(0x34))
                    expect(header.flags6).to(equal(0xF1))
                    expect(header.flags7).to(equal(0xF2))
                    expect(header.flags8).to(equal(0xF3))
                    expect(header.flags9).to(equal(0xF4))
                    expect(header.flags10).to(equal(0xF5))
                }
            }

            context("incorrect header format") {
                it("invalid") {
                    let data: [UInt8] = [
                        0x4E, 0x45, 0x53, 0x1B,
                        0x93, 0x34,
                        0xF1, 0xF2, 0xF3, 0xF4, 0xF5,
                        0x00, 0x00, 0x00, 0x00, 0x00,
                    ]
                    let header = NESFileHeader(bytes: data)

                    expect(header.valid()).to(beFalsy())
                }
            }
        }

        describe("NESFile") {
            it("can load sample ROM") {
                let path = "Tests/SwiftNESTests/fixtures/helloworld/sample1.nes"

                expect({
                    do {
                        let f = try NESFile(path: path)

                        expect(f.header.valid()).to(beTruthy())
                    } catch let error {
                        return .failed(reason: (error as NSError).localizedDescription)
                    }
                    return .succeeded
                }).to(succeed())
            }
        }
    }
}
