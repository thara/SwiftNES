import Foundation

let soundBufferSize = 2048
let soundBufferCount = 3

public class SoundQueue {
    var buffer = [Int16](repeating: 0x00, count: soundBufferSize * soundBufferCount)

    var readBufferIndex = 0
    var writeBufferIndex = 0

    var currentWritePosition = 0

    let semaphore = DispatchSemaphore(value: 0)

    public func write(_ values: inout [Int16], count: Int) {
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
                semaphore.wait()
            }
        }
    }

    public func read(count: Int) -> [Int16] {
        if semaphore.signal() < currentWritePosition - 1 {
            let start = readBufferIndex * soundBufferSize
            let result = Array(buffer[start..<(start &+ count)])
            readBufferIndex = (readBufferIndex &+ 1) % soundBufferCount
            return result
        } else {
            return [Int16](repeating: 0, count: count)
        }
    }
}
