struct MyAPU {
    let sampleRate: UInt
    let framePeriod: UInt

    var pulse1 = Pulse(carryMode: .onesComplement)
    var pulse2 = Pulse(carryMode: .twosComplement)

    var cycles: UInt = 0

    var frameCounter = FrameCounter2()
    var frameInterrupted = false
}

struct Pulse {
    var volume: UInt8 = 0
    var sweep: UInt8 = 0
    var low: UInt8 = 0
    var high: UInt8 = 0 {
        didSet {
            if enabled {
                lengthCounter = UInt(lookupLength(lengthCounterLoad))
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
    var lengthCounterLoad: UInt8 { (high & 0b11111000) >> 3 }

    var timer: UInt16 { low.u16 | (timerHigh.u16 << 8) }

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

struct FrameCounter2 {
    var value: UInt8 = 0

    enum SequenceMode { case fourStep, fiveStep }

    var interruptInhibit: Bool { value[6] == 1 }
    var mode: SequenceMode { value[7] == 0 ? .fourStep : .fiveStep }

    var step = 0
}
