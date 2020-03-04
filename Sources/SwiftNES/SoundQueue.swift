import Foundation
import SoundIO

let soundBufferSize = 2048
let soundBufferCount = 3

fileprivate let range = Double(Int16.max) - Double(Int16.min)

public class SoundQueue {
    public var ringBuffer: RingBuffer
    let soundBufferSize: Int32

    var writePtr: UnsafeMutablePointer<Int16>
    public var readPtr: UnsafeMutablePointer<Int8>


    public init(ringBuffer: RingBuffer) {
        self.ringBuffer = ringBuffer
        soundBufferSize = ringBuffer.capacity
        writePtr = ringBuffer.writePointer!.withMemoryRebound(to: Int16.self, capacity: Int(ringBuffer.capacity)) { $0 }
        readPtr = ringBuffer.readPointer!
    }

    func write(_ values: inout [Int16], count: Int) {
        for i in 0..<count {
            let v = values[i]
            // let x = Int16(truncatingIfNeeded: Double(v) * range / 2.0)
            writePtr.pointee = v
            ringBuffer.advanceWritePointer(by: 1)
        }
    }
}
