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
            switch frameCounter.mode {
            case .fourStep:
                if frameCounter.step < 4 {
                    pulse1.clockEnvelope()
                    pulse2.clockEnvelope()
                    triangle.clockLinearCounter()
                }

                if frameCounter.step == 1 || frameCounter.step == 3 {
                    pulse1.clockLengthCounter()
                    pulse1.clockSweepUnit()
                    pulse2.clockLengthCounter()
                    pulse2.clockSweepUnit()
                    triangle.clockLengthCounter()
                    noise.clockLengthCounter()
                }

                if frameCounter.step == 3 && !frameCounter.interruptInhibit {
                    frameInterrupted = true
                }

                frameCounter.step = (frameCounter.step + 1) % 5
            case .fiveStep:
                if frameCounter.step < 4 || frameCounter.step == 5 {
                    pulse1.clockEnvelope()
                    pulse2.clockEnvelope()
                    triangle.clockLinearCounter()
                }

                if frameCounter.step == 1 || frameCounter.step == 4 {
                    pulse1.clockLengthCounter()
                    pulse1.clockSweepUnit()
                    pulse2.clockLengthCounter()
                    pulse2.clockSweepUnit()
                    triangle.clockLengthCounter()
                    noise.clockLengthCounter()
                }

                frameCounter.step = (frameCounter.step + 1) % 5
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
        let triangle: Float = Float(self.triangle.output())
        let noise: Float = Float(self.noise.output())
        let dmc: Float = Float(self.dmc.output())

        let pulseOut: Float
        if p1 != 0.0 || p2 != 0.0 {
            pulseOut = 95.88 / ((8128 / (p1 + p2)) + 100)
        } else {
            pulseOut = 0.0
        }

        let tndOut: Float
        if triangle != 0.0 || noise != 0.0 || dmc != 0.0 {
            tndOut = 159.79 / (1 / ((triangle / 8227) + (noise / 12241) + (dmc / 22638)) + 100)
        } else {
            tndOut = 0.0
        }

        return pulseOut
        // return pulseOut + tndOut
    }
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
            if apu.frameInterrupted && !apu.frameCounter.interruptInhibit {
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
            apu.triangle.enabled = value[2] == 1
            apu.noise.enabled = value[3] == 1
            apu.dmc.enabled = value[4] == 1
        case 0x4017:
            apu.frameCounter.value = value
        default:
            break
        }
    }
}

extension PulseChannel {

    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x4000:
            volume = value
        case 0x4001:
            sweep = value
        case 0x4002:
            low = value
        case 0x4003:
            high = value
            if enabled {
                lengthCounter = UInt(lookupLength(lengthCounterLoad))
            }
        default:
            break
        }
    }

    mutating func enable(_ value: Bool) {
        enabled = value
        if !enabled {
            lengthCounter = 0
        }
    }

    mutating func clockTimer() {
        if 0 < timerCounter {
            timerCounter &-= 1
        } else {
            timerCounter = timerReload
            sequencer &+= 1
            if 8 <= sequencer {
                sequencer = 0
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
                } else if envelopeLoop {
                    envelopeDecayLevelCounter = 15
                }
            }
        }
    }

    mutating func clockSweepUnit() {
        // Updating the period
        if sweepCounter == 0 && sweepEnabled && !sweepUnitMuted {
            var changeAmount = timerPeriod >> sweepShift
            if sweepNegate {
                switch carryMode {
                case .onesComplement:
                    changeAmount = ~changeAmount
                case .twosComplement:
                    changeAmount = -changeAmount  // swiftlint:disable shorthand_operator
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
        // print(carryMode, enabled, lengthCounter, timerCounter, dutyCycle, sequencer)
        if !enabled || lengthCounter == 0 || timerCounter == 0 || waveforms[dutyCycle][Int(sequencer)] == 0 {
            return 0
        }
        let volume = useConstantVolume ? envelopePeriod : envelopeDecayLevelCounter
        return volume & 0b1111
    }

    var sweepUnitMuted: Bool {
        return timerPeriod < 8 || 0x7FF < timerPeriod
    }
}

extension TriangleChannel {
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x4008:
            linearCounterSetup = value
        case 0x400A:
            low = value
        case 0x400B:
            high = value
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

extension NoiseChannel {
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x400C:
            envelope = value
        case 0x400E:
            period = value
        case 0x400F:
            envelopeRestart = value
        default:
            break
        }
    }

    mutating func clockTimer() {
        // LFSR
        let feedback = shiftRegister ^ shiftRegister[mode ? 6 : 1]
        shiftRegister &>>= 1
        shiftRegister |= (feedback << 14)
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
        return UInt8(shiftRegister[0])
    }
}

extension DMC {
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x4010:
            flags = value
        case 0x4011:
            direct = value
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

let waveforms: [[UInt8]] = [
    [0, 1, 0, 0, 0, 0, 0, 0],  // 12.5%
    [0, 1, 1, 0, 0, 0, 0, 0],  // 25%
    [0, 1, 1, 1, 1, 0, 0, 0],  // 50%
    [1, 0, 0, 1, 1, 1, 1, 1],  // 25% negated
]

func lookupLength(_ bitPattern: UInt8) -> Int {
    let tableIndex = Int(bitPattern & 0b11110000 >> 4)
    let lengthIndex = Int(bitPattern[4])
    return lookupTable[tableIndex][lengthIndex]
}

private let lookupTable = [
    [0x0A, 0xFE],
    [0x14, 0x02],
    [0x28, 0x04],
    [0x50, 0x06],
    [0xA0, 0x08],
    [0x3C, 0x0A],
    [0x0E, 0x0C],
    [0x1A, 0x0E],
    [0x0C, 0x10],
    [0x18, 0x12],
    [0x30, 0x14],
    [0x60, 0x16],
    [0xC0, 0x18],
    [0x48, 0x1A],
    [0x10, 0x1C],
    [0x20, 0x1E],
]

private let dmcRates = [428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54]

public protocol AudioBuffer {
    func write(_ sample: Float)
}

public protocol DMCMemoryReader {
    func read(at address: UInt16) -> UInt8
}
