extension APU {

    mutating func reset() {
        write(0, to: 0x4017)  // frame irq enabled
        write(0, to: 0x4015)  // all channels disabled
        for addr in 0x4000...0x400F {
            write(0, to: UInt16(addr))
        }
        for addr in 0x4010...0x4013 {
            write(0, to: UInt16(addr))
        }
    }

    mutating func step<T: AudioBuffer>(audioBuffer: T) {
        cycles &+= 1

        // Down sampling
        if cycles % sampleRate == 0 {
            audioBuffer.write(sample())
        }

        if cycles % 2 == 0 {
            pulse1.clockTimer()
            pulse2.clockTimer()
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
                    //TODO Others
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
                    //TODO Others
                }

                frameCounter.step = (frameCounter.step + 1) % 5
            }
        }
    }

    private func sample() -> Float {
        let p1 = Float(pulse1.output())
        let p2 = Float(pulse2.output())
        let triangle: Float = 0.0
        let noise: Float = 0.0
        let dmc: Float = 0.0

        let pulseOut = 95.88 / ((8128 / (p1 + p2)) + 100)
        let tndOut = 159.79 / (1 / ((triangle / 8227) + (noise / 12241) + (dmc / 22638)) + 100)

        return pulseOut + tndOut
    }
}

extension APU: IOPort {
    mutating func read(from address: UInt16) -> UInt8 {
        switch address {
        case 0x4015:
            var value: UInt8 = 0
            // if dmcInterrupt { value |= 0x80 }
            if frameInterrupted && !frameCounter.interruptInhibit { value |= 0x40 }
            // if dmcActive { value |= 0x20 }
            // if noise { value |= 0x08 }
            // if triangle { value |= 0x04 }
            if 0 < pulse2.lengthCounter { value |= 0x02 }
            if 0 < pulse1.lengthCounter { value |= 0x01 }

            frameInterrupted = false

            return value
        default:
            return 0x00
        }
    }

    mutating func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x4000...0x4003:
            pulse1.write(value, at: address)
        case 0x4004...0x4007:
            pulse2.write(value, at: address)
        case 0x4008...0x400B:
            triangle.write(value, at: address)
            break
        case 0x400C...0x400F:
            //TODO Noise
            break
        case 0x4010...0x4013:
            //TODO DMC
            break
        case 0x4015:
            pulse1.enabled = value[0] == 1
            pulse2.enabled = value[1] == 1
            triangle.enabled = value[2] == 1
            //TODO noise, DMC
        case 0x4017:
            frameCounter.value = value
        default:
            break
        }
    }

    func clear() {
        //TODO
    }
}

extension PulseChannel {
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address & 0x4003 {
        case 0x4000:
            volume = value
        case 0x4001:
            sweep = value
        case 0x4002:
            low = value
        case 0x4003:
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
            sequencer &+= 1
            if 8 <= sequencer {
                sequencer = 0
            }
        }
    }

    mutating func clockEnvelope() {
        if envelope.start {
            envelope.decayLevelCounter = 15
            envelope.counter = envelopePeriod
            envelope.start = false
        } else {
            envelope.counter &-= 1
            if envelope.counter == 0 {
                envelope.counter = envelopePeriod
                if 0 < envelope.decayLevelCounter {
                    envelope.decayLevelCounter &-= 1
                } else {
                    envelope.loop = true
                    envelope.decayLevelCounter = 15
                }
            }
        }
    }

    mutating func clockSweepUnit() {
        // Updating the period
        if sweepUnit.counter == 0 && sweepEnabled && !sweepUnitMuted {
            var changeAmount = timerPeriod >> sweepShift
            if sweepNegate {
                switch carryMode {
                case .onesComplement:
                    changeAmount = changeAmount * -1 - 1
                case .twosComplement:
                    changeAmount = changeAmount * -1      // swiftlint:disable shorthand_operator
                }
            }
            timerPeriod &+= changeAmount
        }

        if sweepUnit.counter == 0 || sweepUnit.reload {
            sweepUnit.counter = sweepPeriod
            sweepUnit.reload = false
        } else {
            sweepUnit.counter &-= 1
        }
    }

    mutating func clockLengthCounter() {
        if 0 < lengthCounter && !lengthCounterHalt {
            lengthCounter &-= 1
        }
    }

    func output() -> UInt8 {
        if !enabled || lengthCounter == 0 || timerCounter == 0 || waveforms[dutyCycle][Int(sequencer)] == 0 {
            return 0
        }
        let volume = useConstantVolume ? envelopePeriod : envelope.decayLevelCounter
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

let waveforms: [[UInt8]] = [
    [0, 1, 0, 0, 0, 0, 0, 0],  // 12.5%
    [0, 1, 1, 0, 0, 0, 0, 0],  // 25%
    [0, 1, 1, 1, 1, 0, 0, 0],  // 50%
    [1, 0, 0, 1, 1, 1, 1, 1]  // 25% negated
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
    [0x20, 0x1E]
]

public protocol AudioBuffer {
    func write(_ sample: Float)
}
