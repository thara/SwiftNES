import Foundation
import SoundIO

let soundBufferSize = 2048
let soundBufferCount = 3

public class SoundQueue {
    var ringBuffer: RingBuffer
    let soundBufferSize: Int32

    var writePtr: UnsafeMutablePointer<Int8>
    public var readPtr: UnsafeMutablePointer<Int8>

    public init(ringBuffer: RingBuffer) {
        self.ringBuffer = ringBuffer
        soundBufferSize = ringBuffer.capacity
        writePtr = ringBuffer.writePointer!
        readPtr = ringBuffer.readPointer!
    }

    func write(_ values: inout [Int16], count: Int) {
        memcpy(writePtr, values, count)
    }
}
