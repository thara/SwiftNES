import CSDL2
import Foundation
import SDL
import SwiftNES

private let bufferCount: UInt32 = 3

class SDLAudioBuffer: AudioBuffer {

    var samples = [Float](repeating: 0.0, count: 4096 * 2)
    var index: Int = 0
    var prev: Float = 0.0

    var audioSpec = SDLAudioSpec()

    init(sampleRate: Int32, channels: UInt8, bufferSize: UInt16) {
        audioSpec.freq = sampleRate
        audioSpec.format = UInt16(AUDIO_F32LSB)
        audioSpec.channels = channels
        audioSpec.silence = 0
        audioSpec.samples = bufferSize
        audioSpec.size = 0

        audioSpec.setCallback(userdata: self) { (buf, samples, count) in
            buf.fill(into: samples, count: count)
        }
    }

    func write(_ sample: Float) {
        guard index < samples.count else {
            return
        }

        samples[index] = sample
        index &+= 1
    }

    func fill(into buffer: UnsafeMutablePointer<UInt8>, count: Int32) {
        let bufferCount = Int(count) / MemoryLayout<Float>.size

        buffer.withMemoryRebound(to: Float.self, capacity: bufferCount) { p in
            var p = p

            var writeIndex = 0
            for _ in 0..<bufferCount {
                let sample: Float
                if self.index <= writeIndex {
                    sample = prev
                } else {
                    sample = samples[writeIndex]
                }

                p.pointee = sample
                p += 1

                prev = sample
                writeIndex &+= 1
            }

            var index = 0
            if bufferCount < index {
                for i in stride(from: bufferCount, to: index, by: 1) {
                    samples[index] = samples[i]
                    index &+= 1
                }
            }
            self.index = index
        }
    }
}
