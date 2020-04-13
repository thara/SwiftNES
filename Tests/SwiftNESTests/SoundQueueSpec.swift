import Nimble
import Quick

@testable import SwiftNES

class SoundQueueSpec: QuickSpec {
    override func spec() {
        var soundQueue: SoundQueue!
        beforeEach {
            soundQueue = SoundQueue()
        }

        describe("read") {
            it("return a part of buffer at readBufferIndex") {
                soundQueue.buffer[0] = 0x12
                soundQueue.buffer[soundBufferSize] = 0x34
                soundQueue.buffer[soundBufferSize * 2] = 0x56

                var buffer = soundQueue.read(count: 1)
                expect(buffer[buffer.startIndex]) == 0x12

                soundQueue.readBufferIndex = 1
                buffer = soundQueue.read(count: 1)
                expect(buffer[buffer.startIndex]) == 0x34

                soundQueue.readBufferIndex = 2
                buffer = soundQueue.read(count: 1)
                expect(buffer[buffer.startIndex]) == 0x56
            }
        }

        describe("write") {
            it("update a part of buffer at writeBufferIndex") {
                var buffer = [UInt16](1...100)
                soundQueue.write(&buffer, count: 2)

                expect(soundQueue.buffer[0]) == 1
                expect(soundQueue.buffer[1]) == 2
                expect(soundQueue.buffer[2]) == 0

                soundQueue.write(&buffer, count: 4)

                expect(soundQueue.buffer[2]) == 1
                expect(soundQueue.buffer[3]) == 2
                expect(soundQueue.buffer[4]) == 3
                expect(soundQueue.buffer[5]) == 4
                expect(soundQueue.buffer[6]) == 0

                soundQueue.writeBufferIndex = 2
                soundQueue.currentWritePosition = 0
                soundQueue.write(&buffer, count: 3)

                expect(soundQueue.buffer[2 * soundBufferSize + 0]) == 1
                expect(soundQueue.buffer[2 * soundBufferSize + 1]) == 2
                expect(soundQueue.buffer[2 * soundBufferSize + 2]) == 3
                expect(soundQueue.buffer[2 * soundBufferSize + 3]) == 0
            }

            it("update a buffer over different buffer indexes") {
                soundQueue.writeBufferIndex = 1
                soundQueue.currentWritePosition = soundBufferSize - 10

                var buffer = [UInt16](1...15)
                soundQueue.write(&buffer, count: 12)

                expect(soundQueue.buffer[2 * soundBufferSize - 12]) == 0
                expect(soundQueue.buffer[2 * soundBufferSize - 11]) == 0
                expect(soundQueue.buffer[2 * soundBufferSize - 10]) == 1
                expect(soundQueue.buffer[2 * soundBufferSize - 1]) == 10

                expect(soundQueue.buffer[2 * soundBufferSize + 0]) == 11
                expect(soundQueue.buffer[2 * soundBufferSize + 1]) == 12
                expect(soundQueue.buffer[2 * soundBufferSize + 2]) == 0
            }
        }
    }
}
