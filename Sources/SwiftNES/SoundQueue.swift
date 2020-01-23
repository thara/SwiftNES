import Foundation

let soundBufferSize = 2048
let soundBufferCount = 3

public struct SoundQueue {
    var buffer = [UInt16](repeating: 0x00, count: soundBufferSize * soundBufferCount)

    var readBufferIndex = 0
    var writeBufferIndex = 0

    var currentWritePosition = 0

    public mutating func write(_ values: inout [UInt16], count: Int) {
        var count = count

        var input = 0
        while 0 < count {
            let n = min(soundBufferSize &- currentWritePosition, count)

            let base = writeBufferIndex &* soundBufferSize
            let start = base &+ currentWritePosition

            buffer[start..<(start &+ n)] = values[input..<(input &+ n)]

            input &+= n
            currentWritePosition &+= n
            count &-= n

            print("currentWritePosition", currentWritePosition)
            if soundBufferSize <= currentWritePosition {
                currentWritePosition = 0
                writeBufferIndex = (writeBufferIndex &+ 1) % soundBufferCount
                print("writeBufferIndex", writeBufferIndex)
            }
        }
    }

    public mutating func read(count: Int) -> ArraySlice<UInt16> {
        defer {
            readBufferIndex = (readBufferIndex &+ 1) % soundBufferCount
        }
        let start = readBufferIndex * soundBufferSize
        return buffer[start..<(start &+ count)]
    }
}
