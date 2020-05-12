struct APU {
    let sampleRate: UInt
    let framePeriod: UInt

    var pulse1 = PulseChannel(carryMode: .onesComplement)
    var pulse2 = PulseChannel(carryMode: .twosComplement)
    var triangle = TriangleChannel()
    var noise = NoiseChannel()
    var dmc = DMC()

    var cycles: UInt = 0

    var frameCounterControl: UInt8 = 0
    var frameSequenceStep = 0
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

struct TriangleChannel {
    var linearCounterSetup: UInt8 = 0
    var low: UInt8 = 0
    var high: UInt8 = 0

    var linearCounterReloadFlag = false

    var timerCounter: UInt16 = 0
    var sequencer: UInt8 = 0

    var linearCounter: UInt8 = 0
    var lengthCounter: UInt = 0

    var enabled: Bool = false
}

struct NoiseChannel {
    var envelope: UInt8 = 0
    var period: UInt8 = 0

    var envelopeCounter: UInt8 = 0
    var envelopeDecayLevelCounter: UInt8 = 0
    var envelopeStart: Bool = false

    var shiftRegister: UInt16 = 1
    var lengthCounter: UInt = 0

    var timerCounter: UInt16 = 0
    var timerPeriod: UInt16 = 0

    var enabled: Bool = false
}

struct DMC {
    var flags: UInt8 = 0
    var direct: UInt8 = 0
    var address: UInt8 = 0
    var length: UInt8 = 0

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
