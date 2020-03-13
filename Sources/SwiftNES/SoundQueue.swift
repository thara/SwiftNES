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
        let writeCount = min(Int(ringBuffer.freeCount), count)
        let writePtr = ringBuffer.writePointer!.withMemoryRebound(to: Int16.self, capacity: writeCount) { $0 }
        print("write before \(writePtr.pointee) \(values[0])")
        memcpy(writePtr, values, writeCount)
        print("write after \(writePtr.pointee) \(values[0])")
        ringBuffer.advanceWritePointer(by: Int32(writeCount))
    }
}
