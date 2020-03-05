import SoundQueueCppWrapper

public class SoundQueue {
    var rawPointer: UnsafeMutableRawPointer

    init(rawPointer: UnsafeRawPointer) {
        self.rawPointer = UnsafeMutableRawPointer(mutating: rawPointer)
    }

    public init() {
        self.rawPointer = UnsafeMutableRawPointer(mutating: sound_queue_create())
    }

    deinit {
        sound_queue_destroy(self.rawPointer)
    }
}

extension SoundQueue {
    public func initialize(sampleRate: Int, channelCount: Int32 = 1) {
        sound_queue_init(self.rawPointer, sampleRate, channelCount)
    }

    public var sampleCount: Int32 {
        sound_queue_sample_count(self.rawPointer)
    }

    public func write(in buffer: UnsafePointer<Int16>, count: Int32) {
        sound_queue_write(self.rawPointer, buffer, count)
    }
}
