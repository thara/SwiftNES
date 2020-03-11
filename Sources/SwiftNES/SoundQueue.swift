import Foundation
import SoundIO

let soundBufferSize = 2048
let soundBufferCount = 3

fileprivate let range = Double(Int16.max) - Double(Int16.min)

public class SoundQueue {
    public var ringBuffer: RingBuffer
    let soundBufferSize: Int32

    public init(ringBuffer: RingBuffer) {
        self.ringBuffer = ringBuffer
        soundBufferSize = ringBuffer.capacity
    }

    func write(_ values: inout [Int16], count: Int) {
        let writePtr = ringBuffer.writePointer!.withMemoryRebound(to: Int16.self, capacity: count) { $0 }
        memcpy(writePtr, values, count)
        ringBuffer.advanceWritePointer(by: Int32(count))
    }
}
