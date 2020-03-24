import SwiftNES
import SDL
import CSDL2

private let bufferCount: UInt32 = 3

class SDLAudioBuffer: AudioBuffer {

    let semaphore = SDLSemaphore(initialValue: bufferCount)

    init(sampleRate: Int32, channels: UInt8, bufferSize: UInt16) {
        var audioSpec = SDLAudioSpec()

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
        //print(sample)
    }

    func fill(into samples: UnsafeMutablePointer<UInt8>, count: Int32) {
        if semaphore.value < bufferCount - 1 {
            try? semaphore.post()
        } else {
            memset(samples, 0, Int(count))
        }
    }
}
