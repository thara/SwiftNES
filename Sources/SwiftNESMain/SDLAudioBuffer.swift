import Foundation
import SwiftNES
import SDL
import CSDL2

private let bufferCount: UInt32 = 3

class SDLAudioBuffer: AudioBuffer {

    var buffer = [Float](repeating: 0.0, count: 2048 * 2)
    var index: Int = 0
    var prev: UInt8 = 0

    var audioSpec = SDLAudioSpec()

    init(sampleRate: Int32, channels: UInt8, bufferSize: UInt16) {
        audioSpec.freq = sampleRate
        audioSpec.format = UInt16(AUDIO_S16SYS)
        audioSpec.channels = channels
        audioSpec.silence = 0
        audioSpec.samples = bufferSize
        audioSpec.size = 0

        audioSpec.setCallback(userdata: self) { (buf, samples, count) in
            buf.fill(into: samples, count: count)
        }
    }

    func write(_ sample: Float) {
        guard index < buffer.count else {
            return
        }

        buffer[index] = sample
        index &+= 1
    }

    func fill(into samples: UnsafeMutablePointer<UInt8>, count: Int32) {
        let src = buffer.withUnsafeBufferPointer { Data(buffer: $0) }

        let readCount = min(Int(count), index)
        src.copyBytes(to: samples, from: 0..<readCount)

        prev = src.last!

        if readCount == index {
            let base = (samples + index)
            for b in base..<(base + Int(count) - index) {
                b.pointee = prev
            }
        }

        var i = 0

        if Int(count) < index {
            for j in Int(count)..<index {
                buffer[i] = buffer[j]
                i &+= 1
            }
        }

        self.index = i
    }
}
