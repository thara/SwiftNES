extension Emulator {

    var frameInterruptInhibit: Bool {
        nes.apu.frameCounterControl[6] == 1
    }

    enum FrameSequenceMode {
        case fourStep, fiveStep
    }
    var frameSequenceMode: FrameSequenceMode {
        nes.apu.frameCounterControl[7] == 0 ? .fourStep : .fiveStep
    }

    mutating func apuStep() -> Bool {
        nes.apu.cycles &+= 1

        // Down sampling
        if cycles % nes.apu.sampleRate == 0 {
            audioBuffer.write(apuSample())
        }

        var cpuStall = false
        if cycles % 2 == 0 {
            nes.apu.pulse1.clockTimer()
            nes.apu.pulse2.clockTimer()
            nes.apu.noise.clockTimer()
            cpuStall = dmcClockTimer()
        }

        nes.apu.triangle.clockTimer()

        if cycles % nes.apu.framePeriod == 0 {
            switch frameSequenceMode {
            case .fourStep:
                nes.apu.pulse1.clockEnvelope()
                nes.apu.pulse2.clockEnvelope()
                nes.apu.triangle.clockLinearCounter()
                nes.apu.noise.clockEnvelope()

                if nes.apu.frameSequenceStep == 1 || nes.apu.frameSequenceStep == 3 {
                    nes.apu.pulse1.clockLengthCounter()
                    nes.apu.pulse1.clockSweepUnit()
                    nes.apu.pulse2.clockLengthCounter()
                    nes.apu.pulse2.clockSweepUnit()
                    nes.apu.triangle.clockLengthCounter()
                    nes.apu.noise.clockLengthCounter()
                }

                if nes.apu.frameSequenceStep == 3 && !frameInterruptInhibit {
                    nes.apu.frameInterrupted = true
                }

                nes.apu.frameSequenceStep = (nes.apu.frameSequenceStep + 1) % 4
            case .fiveStep:
                if nes.apu.frameSequenceStep < 4 || nes.apu.frameSequenceStep == 5 {
                    nes.apu.pulse1.clockEnvelope()
                    nes.apu.pulse2.clockEnvelope()
                    nes.apu.triangle.clockLinearCounter()
                    nes.apu.noise.clockEnvelope()
                }

                if nes.apu.frameSequenceStep == 1 || nes.apu.frameSequenceStep == 4 {
                    nes.apu.pulse1.clockLengthCounter()
                    nes.apu.pulse1.clockSweepUnit()
                    nes.apu.pulse2.clockLengthCounter()
                    nes.apu.pulse2.clockSweepUnit()
                    nes.apu.triangle.clockLengthCounter()
                    nes.apu.noise.clockLengthCounter()
                }

                nes.apu.frameSequenceStep = (nes.apu.frameSequenceStep + 1) % 5
            }

            if nes.apu.dmc.interrupted {
                nes.apu.frameInterrupted = true
            }
        }

        return cpuStall
    }

    mutating func apuSample() -> Float {
        let p1 = Float(nes.apu.pulse1.output())
        let p2 = Float(nes.apu.pulse2.output())
        let triangle = Float(nes.apu.triangle.output())
        let noise = Float(nes.apu.noise.output())
        let dmc = Float(nes.apu.dmc.output())

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
}

extension Emulator {
    mutating func reset() {
        apuWrite(0, to: 0x4017)  // frame irq enabled
        apuWrite(0, to: 0x4015)  // all channels disabled
        for addr in 0x4000...0x400F {
            apuWrite(0, to: UInt16(addr))
        }
        for addr in 0x4010...0x4013 {
            apuWrite(0, to: UInt16(addr))
        }
    }

    mutating func apuRead(from address: UInt16) -> UInt8 {
        switch address {
        case 0x4015:
            var value: UInt8 = 0
            if nes.apu.dmc.interrupted {
                value |= 0x80
            }
            if nes.apu.frameInterrupted && !frameInterruptInhibit {
                value |= 0x40
            }
            if 0 < nes.apu.dmc.bytesRemainingCounter {
                value |= 0x20
            }
            if 0 < nes.apu.noise.lengthCounter {
                value |= 0x08
            }
            if 0 < nes.apu.triangle.lengthCounter {
                value |= 0x04
            }
            if 0 < nes.apu.pulse2.lengthCounter {
                value |= 0x02
            }
            if 0 < nes.apu.pulse1.lengthCounter {
                value |= 0x01
            }

            nes.apu.frameInterrupted = false

            return value
        default:
            return 0x00
        }
    }

    mutating func apuWrite(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x4000...0x4003:
            nes.apu.pulse1.write(value, at: address)
        case 0x4004...0x4007:
            nes.apu.pulse2.write(value, at: address)
        case 0x4008...0x400B:
            nes.apu.triangle.write(value, at: address)
        case 0x400C...0x400F:
            nes.apu.noise.write(value, at: address)
        case 0x4010...0x4013:
            nes.apu.dmc.write(value, at: address)
        case 0x4015:
            nes.apu.pulse1.enable(value[0] == 1)
            nes.apu.pulse2.enable(value[1] == 1)
            nes.apu.triangle.enable(value[2] == 1)
            nes.apu.noise.enable(value[3] == 1)
            nes.apu.dmc.enabled = value[4] == 1
        case 0x4017:
            nes.apu.frameCounterControl = value
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
                    changeAmount = ~changeAmount + 1  // swiftlint:disable shorthand_operator
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

    mutating func start() {
        outputLevel = directLoad
        addressCounter = sampleAddress
        bytesRemainingCounter = sampleLength
    }

    func output() -> UInt8 {
        silence ? 0 : (outputLevel & 0b01111111)
    }
}

extension Emulator {

    mutating func dmcClockTimer() -> Bool {
        var cpuStall = false

        if 0 < nes.apu.dmc.timerCounter {
            nes.apu.dmc.timerCounter &-= 1
        } else {
            // the output cycle ends
            nes.apu.dmc.timerCounter = 8

            // Memory Reader
            if nes.apu.dmc.sampleBufferEmpty && nes.apu.dmc.bytesRemainingCounter != 0 {
                nes.apu.dmc.sampleBuffer = M.cpuRead(at: nes.apu.dmc.addressCounter, from: &nes)
                nes.apu.dmc.addressCounter &+= 1
                if nes.apu.dmc.addressCounter == 0 {
                    nes.apu.dmc.addressCounter = 0x8000
                }
                nes.apu.dmc.bytesRemainingCounter &-= 1

                if nes.apu.dmc.bytesRemainingCounter == 0 {
                    if nes.apu.dmc.loopFlag {
                        nes.apu.dmc.start()
                    }
                    if nes.apu.dmc.irqEnabled {
                        nes.apu.dmc.interrupted = true
                    }
                }

                cpuStall = true
            }

            // Output unit
            if nes.apu.dmc.sampleBufferEmpty {
                nes.apu.dmc.silence = true
            } else {
                nes.apu.dmc.silence = false
                nes.apu.dmc.shiftRegister = nes.apu.dmc.sampleBuffer
                nes.apu.dmc.sampleBufferEmpty = true
                nes.apu.dmc.sampleBuffer = 0
            }

            if !nes.apu.dmc.silence {
                if nes.apu.dmc.shiftRegister[0] == 1 {
                    if nes.apu.dmc.outputLevel < nes.apu.dmc.outputLevel &+ 2 {
                        nes.apu.dmc.outputLevel &+= 2
                    }
                } else {
                    if nes.apu.dmc.outputLevel &- 2 < nes.apu.dmc.outputLevel {
                        nes.apu.dmc.outputLevel &-= 2
                    }
                }
            }
            nes.apu.dmc.shiftRegister >>= 1
            nes.apu.dmc.bitsRemainingCounter &-= 1
        }
        return cpuStall
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
