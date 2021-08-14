// swiftlint:disable file_length cyclomatic_complexity
extension APU {

    mutating func step<A: AudioBuffer, M: DMCMemoryReader>(audioBuffer: A, memoryReader: M) -> Bool {
        cycles &+= 1

        // Down sampling
        if cycles % sampleRate == 0 {
            audioBuffer.write(sample())
        }

        var cpuStall = false
        if cycles % 2 == 0 {
            pulse1.clockTimer()
            pulse2.clockTimer()
            noise.clockTimer()
            cpuStall = dmc.clockTimer(memoryReader)
        }

        triangle.clockTimer()

        if cycles % framePeriod == 0 {
            switch frameSequenceMode {
            case .fourStep:
                pulse1.clockEnvelope()
                pulse2.clockEnvelope()
                triangle.clockLinearCounter()
                noise.clockEnvelope()

                if frameSequenceStep == 1 || frameSequenceStep == 3 {
                    pulse1.clockLengthCounter()
                    pulse1.clockSweepUnit()
                    pulse2.clockLengthCounter()
                    pulse2.clockSweepUnit()
                    triangle.clockLengthCounter()
                    noise.clockLengthCounter()
                }

                if frameSequenceStep == 3 && !frameInterruptInhibit {
                    frameInterrupted = true
                }

                frameSequenceStep = (frameSequenceStep + 1) % 4
            case .fiveStep:
                if frameSequenceStep < 4 || frameSequenceStep == 5 {
                    pulse1.clockEnvelope()
                    pulse2.clockEnvelope()
                    triangle.clockLinearCounter()
                    noise.clockEnvelope()
                }

                if frameSequenceStep == 1 || frameSequenceStep == 4 {
                    pulse1.clockLengthCounter()
                    pulse1.clockSweepUnit()
                    pulse2.clockLengthCounter()
                    pulse2.clockSweepUnit()
                    triangle.clockLengthCounter()
                    noise.clockLengthCounter()
                }

                frameSequenceStep = (frameSequenceStep + 1) % 5
            }

            if dmc.interrupted {
                frameInterrupted = true
            }
        }

        return cpuStall
    }

    private mutating func sample() -> Float {
        let p1 = Float(pulse1.output())
        let p2 = Float(pulse2.output())
        let triangle = Float(self.triangle.output())
        let noise = Float(self.noise.output())
        let dmc = Float(self.dmc.output())

        let pulseOut: Float
        if p1 != 0.0 || p2 != 0.0 {
            pulseOut = 95.88 / ((8128.0 / (p1 + p2)) + 100.0)
        } else {
            pulseOut = 0.0
        }

        let tndOut: Float
        if triangle != 0.0 || noise != 0.0 || dmc != 0.0 {
            tndOut = 159.79 / (1 / ((triangle / 8227) + (noise / 12241) + (dmc / 22638)) + 100)
            // tndOut = 0.0
        } else {
            tndOut = 0.0
        }

        return pulseOut + tndOut
    }

    var frameInterruptInhibit: Bool { frameCounterControl[6] == 1 }

    enum FrameSequenceMode { case fourStep, fiveStep }
    var frameSequenceMode: FrameSequenceMode { frameCounterControl[7] == 0 ? .fourStep : .fiveStep }
}

extension APUPort {

    func step<A: AudioBuffer, M: DMCMemoryReader>(audioBuffer: A, memoryReader: M) -> Bool {
        apu.step(audioBuffer: audioBuffer, memoryReader: memoryReader)
    }

    func reset() {
        write(0, to: 0x4017)  // frame irq enabled
        write(0, to: 0x4015)  // all channels disabled
        for addr in 0x4000...0x400F {
            write(0, to: UInt16(addr))
        }
        for addr in 0x4010...0x4013 {
            write(0, to: UInt16(addr))
        }
    }

    func read(from address: UInt16) -> UInt8 {
        switch address {
        case 0x4015:
            var value: UInt8 = 0
            if apu.dmc.interrupted {
                value |= 0x80
            }
            if apu.frameInterrupted && !apu.frameInterruptInhibit {
                value |= 0x40
            }
            if 0 < apu.dmc.bytesRemainingCounter {
                value |= 0x20
            }
            if 0 < apu.noise.lengthCounter {
                value |= 0x08
            }
            if 0 < apu.triangle.lengthCounter {
                value |= 0x04
            }
            if 0 < apu.pulse2.lengthCounter {
                value |= 0x02
            }
            if 0 < apu.pulse1.lengthCounter {
                value |= 0x01
            }

            apu.frameInterrupted = false

            return value
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x4000...0x4003:
            apu.pulse1.write(value, at: address)
        case 0x4004...0x4007:
            apu.pulse2.write(value, at: address)
        case 0x4008...0x400B:
            apu.triangle.write(value, at: address)
        case 0x400C...0x400F:
            apu.noise.write(value, at: address)
        case 0x4010...0x4013:
            apu.dmc.write(value, at: address)
        case 0x4015:
            apu.pulse1.enable(value[0] == 1)
            apu.pulse2.enable(value[1] == 1)
            apu.triangle.enable(value[2] == 1)
            apu.noise.enable(value[3] == 1)
            apu.dmc.enabled = value[4] == 1
        case 0x4017:
            apu.frameCounterControl = value
        default:
            break
        }
    }
}

protocol Oscillator {
    var enabled: Bool { get set }
    var lengthCounter: UInt { get set }
}

extension Oscillator {
    mutating func enable(_ value: Bool) {
        enabled = value
        if !enabled {
            lengthCounter = 0
        }
    }
}

extension PulseChannel: Oscillator {

    var dutyCycle: Int { Int(volume >> 6) }

    var envelopeLoop: Bool { volume[5] == 1 }
    var lengthCounterHalt: Bool { volume[5] == 1 }
    var useConstantVolume: Bool { volume[4] == 1 }

    var envelopePeriod: UInt8 { volume & 0b1111 }

    var sweepEnabled: Bool { sweep[7] == 1 }
    var sweepPeriod: UInt8 { (sweep & 0b01110000) >> 4 }
    var sweepNegate: Bool { sweep[3] == 1 }
    var sweepShift: UInt8 { sweep & 0b111 }

    var timerHigh: UInt8 { high & 0b111 }
    var lengthCounterLoad: UInt8 { (high & 0b11111000) >> 3 }

    var timerReload: UInt16 { low.u16 | (timerHigh.u16 << 8) }

    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x4000:
            volume = value
        case 0x4001:
            sweep = value
            sweepReload = true
        case 0x4002:
            low = value
            timerPeriod = timerReload
        case 0x4003:
            high = value
            if enabled {
                lengthCounter = lengthTable[Int(lengthCounterLoad)]
            }
            timerPeriod = timerReload
            timerSequencer = 0
            envelopeStart = true
        default:
            break
        }
    }

    mutating func clockTimer() {
        if 0 < timerCounter {
            timerCounter &-= 1
        } else {
            timerCounter = timerReload
            timerSequencer &+= 1
            if timerSequencer == 8 {
                timerSequencer = 0
            }
        }
    }

    mutating func clockEnvelope() {
        if envelopeStart {
            envelopeDecayLevelCounter = 15
            envelopeCounter = envelopePeriod
            envelopeStart = false
        } else {
            if 0 < envelopeCounter {
                envelopeCounter &-= 1
            } else {
                envelopeCounter = envelopePeriod
                if 0 < envelopeDecayLevelCounter {
                    envelopeDecayLevelCounter &-= 1
                } else if envelopeDecayLevelCounter == 0 && envelopeLoop {
                    envelopeDecayLevelCounter = 15
                }
            }
        }
    }

    mutating func clockSweepUnit() {
        // Updating the period
        if sweepCounter == 0 && sweepEnabled && sweepShift != 0 && !sweepUnitMuted {
            var changeAmount = timerPeriod >> sweepShift
            if sweepNegate {
                switch carryMode {
                case .onesComplement:
                    changeAmount = ~changeAmount
                case .twosComplement:
                    changeAmount = ~changeAmount + 1
                }
            }
            timerPeriod &+= changeAmount
        }

        if sweepCounter == 0 || sweepReload {
            sweepCounter = sweepPeriod
            sweepReload = false
        } else {
            sweepCounter &-= 1
        }
    }

    mutating func clockLengthCounter() {
        if 0 < lengthCounter && !lengthCounterHalt {
            lengthCounter &-= 1
        }
    }

    func output() -> UInt8 {
        if lengthCounter == 0 || sweepUnitMuted || dutyTable[dutyCycle][timerSequencer] == 0 {
            return 0
        }
        let volume = useConstantVolume ? envelopePeriod : envelopeDecayLevelCounter
        return volume & 0b1111
    }

    var sweepUnitMuted: Bool {
        return timerPeriod < 8 || 0x7FF < timerPeriod
    }
}

extension TriangleChannel: Oscillator {

    var controlFlag: Bool { linearCounterSetup[7] == 1 }
    var lengthCounterHalt: Bool { linearCounterSetup[7] == 1 }
    var linearCounterReload: UInt8 { linearCounterSetup & 0b01111111 }

    var timerLow: UInt8 { low }
    var timerHigh: UInt8 { high & 0b111 }
    var lengthCounterLoad: UInt8 { (high & 0b11111000) >> 3 }

    var timerReload: UInt16 { low.u16 | (timerHigh.u16 << 8) }

    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x4008:
            linearCounterSetup = value
        case 0x400A:
            low = value
        case 0x400B:
            high = value
            linearCounterReloadFlag = true
            if enabled {
                lengthCounter = lengthTable[Int(lengthCounterLoad)]
            }
        default:
            break
        }
    }

    mutating func clockTimer() {
        if 0 < timerCounter {
            timerCounter &-= 1
        } else {
            timerCounter = timerReload
            if 0 < linearCounter && 0 < lengthCounter {
                sequencer &+= 1
                if sequencer == 32 {
                    sequencer = 0
                }
            }
        }
    }

    mutating func clockLengthCounter() {
        if 0 < lengthCounter && !lengthCounterHalt {
            lengthCounter &-= 1
        }
    }

    mutating func clockLinearCounter() {
        if linearCounterReloadFlag {
            linearCounter = linearCounterReload
        } else {
            linearCounter &-= 1
        }

        if controlFlag {
            linearCounterReloadFlag = false
        }
    }

    func output() -> UInt8 {
        guard !controlFlag && enabled && 0 < linearCounter && 0 < lengthCounter else {
            return 0
        }
        // 15, 14, 13, 12, 11, 10,  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
        //  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
        let s = Int(sequencer)
        return UInt8(abs(Int(s) - 15 - (s / 16)))
    }
}

extension NoiseChannel: Oscillator {

    var envelopeLoop: Bool { envelope[5] == 1 }
    var lengthCounterHalt: Bool { envelope[5] == 1 }
    var useConstantVolume: Bool { envelope[4] == 1 }
    var envelopePeriod: UInt8 { envelope & 0b1111 }

    var mode: Bool { period[7] == 1 }
    var timerEntry: UInt8 { period & 0b1111 }

    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x400C:
            envelope = value
        case 0x400E:
            period = value
            timerPeriod = noiseTimerPeriodTable[Int(timerEntry)]
        case 0x400F:
            if enabled {
                lengthCounter = lengthTable[Int((value & 0b11111000) >> 3)]
            }
            envelopeStart = true
        default:
            break
        }
    }

    mutating func clockTimer() {
        if 0 < timerCounter {
            timerCounter &-= 1
        } else {
            timerCounter = timerPeriod

            // LFSR
            let feedback = shiftRegister ^ shiftRegister[mode ? 6 : 1]
            shiftRegister &>>= 1
            shiftRegister |= (feedback << 14)
        }
    }

    mutating func clockEnvelope() {
        if envelopeStart {
            envelopeDecayLevelCounter = 15
            envelopeCounter = envelopePeriod
            envelopeStart = false
        } else {
            if 0 < envelopeCounter {
                envelopeCounter &-= 1
            } else {
                envelopeCounter = envelopePeriod
                if 0 < envelopeDecayLevelCounter {
                    envelopeDecayLevelCounter &-= 1
                } else if envelopeLoop {
                    envelopeDecayLevelCounter = 15
                }
            }
        }
    }

    mutating func clockLengthCounter() {
        if 0 < lengthCounter && !lengthCounterHalt {
            lengthCounter &-= 1
        }
    }

    func output() -> UInt8 {
        guard shiftRegister[0] == 0 || lengthCounter == 0 else {
            return 0
        }
        let volume = useConstantVolume ? envelopePeriod : envelopeDecayLevelCounter
        return volume & 0b1111
    }
}

extension DMC {
    var irqEnabled: Bool { flags[7] == 1 }
    var loopFlag: Bool { flags[6] == 1 }
    var rateIndex: UInt8 { flags & 0b1111 }

    var directLoad: UInt8 { direct & 0b01111111 }

    var sampleAddress: UInt16 { 0xC000 + UInt16(address) * 64 }
    var sampleLength: UInt16 { UInt16(length) * 16 + 1 }

    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x4010:
            flags = value
        case 0x4011:
            direct = value
            outputLevel = directLoad
        case 0x4012:
            self.address = value
        case 0x4013:
            length = value
        default:
            break
        }
    }

    mutating func clockTimer<M: DMCMemoryReader>(_ memoryReader: M) -> Bool {
        var cpuStall = false

        if 0 < timerCounter {
            timerCounter &-= 1
        } else {
            // the output cycle ends
            timerCounter = 8

            // Memory Reader
            if sampleBufferEmpty && bytesRemainingCounter != 0 {
                sampleBuffer = memoryReader.read(at: addressCounter)
                addressCounter &+= 1
                if addressCounter == 0 {
                    addressCounter = 0x8000
                }
                bytesRemainingCounter &-= 1

                if bytesRemainingCounter == 0 {
                    if loopFlag {
                        start()
                    }
                    if irqEnabled {
                        interrupted = true
                    }
                }

                cpuStall = true
            }

            // Output unit
            if sampleBufferEmpty {
                silence = true
            } else {
                silence = false
                shiftRegister = sampleBuffer
                sampleBufferEmpty = true
                sampleBuffer = 0
            }

            if !silence {
                if shiftRegister[0] == 1 {
                    if outputLevel < outputLevel &+ 2 {
                        outputLevel &+= 2
                    }
                } else {
                    if outputLevel &- 2 < outputLevel {
                        outputLevel &-= 2
                    }
                }
            }
            shiftRegister >>= 1
            bitsRemainingCounter &-= 1
        }
        return cpuStall
    }

    mutating func start() {
        outputLevel = directLoad
        addressCounter = sampleAddress
        bytesRemainingCounter = sampleLength
    }

    func output() -> UInt8 {
        silence ? 0 : (outputLevel & 0b01111111)
    }
}

let dutyTable: [[UInt8]] = [
    [0, 1, 0, 0, 0, 0, 0, 0],  // 12.5%
    [0, 1, 1, 0, 0, 0, 0, 0],  // 25%
    [0, 1, 1, 1, 1, 0, 0, 0],  // 50%
    [1, 0, 0, 1, 1, 1, 1, 1],  // 25% negated
]

let lengthTable: [UInt] = [
    10, 254, 20, 2, 40, 4, 80, 6, 160, 8, 60, 10, 14, 12, 26, 14,
    12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30,
]

let noiseTimerPeriodTable: [UInt16] = [
    4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068,
]

private let dmcRates = [428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54]

public protocol AudioBuffer {
    func write(_ sample: Float)
}

public protocol DMCMemoryReader {
    func read(at address: UInt16) -> UInt8
}
