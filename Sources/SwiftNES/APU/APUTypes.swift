struct APU {
    let sampleRate: UInt
    let framePeriod: UInt

    var pulse1 = PulseChannel(carryMode: .onesComplement)
    var pulse2 = PulseChannel(carryMode: .twosComplement)
    var triangle = TriangleChannel()
    var noise = NoiseChannel()
    var dmc = DMC()

    var cycles: UInt = 0

    var frameCounter = FrameCounter()
    var frameInterrupted = false
}

final class APUPort: IOPort {
    var apu: APU

    init(apu: APU) {
        self.apu = apu
    }
}

struct PulseChannel {
    var volume: UInt8 = 0
    var sweep: UInt8 = 0
    var low: UInt8 = 0
    var high: UInt8 = 0

    var lengthCounter: UInt = 0

    var enabled: Bool = false

    var timerCounter: UInt16 = 0
    var timerSequencer: Int = 0
    var timerPeriod: UInt16 = 0

    var envelopeCounter: UInt8 = 0
    var envelopeDecayLevelCounter: UInt8 = 0
    var envelopeStart: Bool = false

    var sweepCounter: UInt8 = 0
    var sweepReload = false

    enum CarryMode {
        case onesComplement, twosComplement
    }
    let carryMode: CarryMode
}

struct FrameCounter {
    var value: UInt8 = 0

    enum SequenceMode { case fourStep, fiveStep }

    var interruptInhibit: Bool { value[6] == 1 }
    var mode: SequenceMode { value[7] == 0 ? .fourStep : .fiveStep }

    var step = 0
}

struct TriangleChannel {
    var linearCounterSetup: UInt8 = 0
    var low: UInt8 = 0
    var high: UInt8 = 0 {
        didSet {
            linearCounterReloadFlag = true
            if enabled {
                lengthCounter = UInt(lookupLength(lengthCounterLoad))
            }
        }
    }

    var controlFlag: Bool { linearCounterSetup[7] == 1 }
    var lengthCounterHalt: Bool { linearCounterSetup[7] == 1 }
    var linearCounterReload: UInt8 { linearCounterSetup & 0b01111111 }

    var timerLow: UInt8 { low }
    var timerHigh: UInt8 { high & 0b111 }
    var lengthCounterLoad: UInt8 { (high & 0b11111000) >> 3 }

    var linearCounterReloadFlag: Bool = false

    var timerReload: UInt16 { low.u16 | (timerHigh.u16 << 8) }

    var timerCounter: UInt16 = 0
    var sequencer: UInt8 = 0

    var linearCounter: UInt8 = 0
    var lengthCounter: UInt = 0

    var enabled: Bool = false {
        didSet {
            if !enabled {
                lengthCounter = 0
            }
        }
    }
}

struct NoiseChannel {
    var envelope: UInt8 = 0
    var period: UInt8 = 0
    var envelopeRestart: UInt8 = 0 {
        didSet {
            if enabled {
                lengthCounter = UInt(lookupLength((envelopeRestart & 0b11111000) >> 3))
            }
        }
    }

    var lengthCounterHalt: Bool { envelope[5] == 1 }
    var useConstantVolume: Bool { envelope[4] == 1 }
    var envelopePeriod: UInt8 { envelope & 0b1111 }

    var mode: Bool { period[7] == 1 }
    var timerPeriod: UInt8 { period & 0b1111 }

    var shiftRegister: UInt16 = 1
    var lengthCounter: UInt = 0

    var enabled: Bool = false {
        didSet {
            if !enabled {
                lengthCounter = 0
            }
        }
    }
}

struct DMC {
    var flags: UInt8 = 0
    var direct: UInt8 = 0 {
        didSet {
            outputLevel = directLoad
        }
    }
    var address: UInt8 = 0
    var length: UInt8 = 0

    var irqEnabled: Bool { flags[7] == 1 }
    var loopFlag: Bool { flags[6] == 1 }
    var rateIndex: UInt8 { flags & 0b1111 }

    var directLoad: UInt8 { direct & 0b01111111 }

    var sampleAddress: UInt16 { 0xC000 + UInt16(address) * 64 }
    var sampleLength: UInt16 { UInt16(length) * 16 + 1 }

    var timerCounter: UInt8 = 0

    var bitsRemainingCounter: UInt8 = 0

    var enabled: Bool = false

    var sampleBuffer: UInt8 = 0

    // Memory reader
    var addressCounter: UInt16 = 0
    var bytesRemainingCounter: UInt16 = 0

    var outputLevel: UInt8 = 0

    var silence = false
    var sampleBufferEmpty = false

    var shiftRegister: UInt8 = 0

    var interrupted = false
}
