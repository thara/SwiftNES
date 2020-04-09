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

struct PulseChannel {
    var volume: UInt8 = 0
    var sweep: UInt8 = 0
    var low: UInt8 = 0
    var high: UInt8 = 0 {
        didSet {
            if enabled {
                lengthCounter = UInt(lookupLength((high & 0b11111000) >> 3))
            }
        }
    }

    var lengthCounter: UInt = 0

    var enabled: Bool = false {
        didSet {
            if !enabled { lengthCounter = 0 }
        }
    }

    var timerCounter: UInt16 = 0
    var sequencer: UInt = 0
    var timerPeriod: Int16 = 0

    var envelope = Envelope()

    var dutyCycle: Int { Int(volume >> 6) }
    var lengthCounterHalt: Bool { volume[5] == 1 }
    var useConstantVolume: Bool { volume[4] == 1 }
    var envelopePeriod: UInt8 { volume & 0b1111 }

    var sweepUnit = Sweep()

    var sweepEnabled: Bool { sweep[7] == 1 }
    var sweepPeriod: UInt8 { (sweep & 0b01110000) >> 4 }
    var sweepNegate: Bool { sweep[3] == 1 }
    var sweepShift: UInt8 { sweep & 0b111 }

    var timerHigh: UInt8 { high & 0b111 }

    var timerReload: UInt16 { low.u16 | (timerHigh.u16 << 8) }

    enum CarryMode {
        case onesComplement, twosComplement
    }
    let carryMode: CarryMode

    init(carryMode: CarryMode) {
        self.carryMode = carryMode
    }
}

struct Envelope {
    var counter: UInt8 = 0
    var decayLevelCounter: UInt8 = 0
    var start: Bool = false
    var loop: Bool = false
}

struct Sweep {
    var counter: UInt8 = 0
    var reload = false
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
                lengthCounter = UInt(lookupLength((high & 0b11111000) >> 3))
            }
        }
    }

    var controlFlag: Bool { linearCounterSetup[7] == 1 }
    var lengthCounterHalt: Bool { linearCounterSetup[7] == 1 }
    var linearCounterReload: UInt8 { linearCounterSetup & 0b01111111 }

    var timerLow: UInt8 { low }
    var timerHigh: UInt8 { high & 0b111 }

    var linearCounterReloadFlag: Bool = false

    var timerReload: UInt16 { low.u16 | (timerHigh.u16 << 8) }

    var timerCounter: UInt16 = 0
    var sequencer: UInt8 = 0

    var linearCounter: UInt8 = 0
    var lengthCounter: UInt = 0

    var enabled: Bool = false {
        didSet {
            if !enabled { lengthCounter = 0 }
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

    var shiftRegister: UInt16 = 0
    var lengthCounter: UInt = 0

    var enabled: Bool = false {
        didSet {
            if !enabled { lengthCounter = 0 }
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
