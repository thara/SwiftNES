extension APU {

    mutating func step() {
        cycles &+= 1

        // Down sampling
        if cycles % sampleRate == 0 {
            sample()
        }

        if cycles % 2 == 0 {
            pulse1.clockTimer()
            pulse2.clockTimer()
        }

        if cycles % framePeriod == 0 {
            switch frameCounter.mode {
            case .fourStep:
                if frameCounter.step < 4 {
                    pulse1.clockEnvelope()
                    pulse2.clockEnvelope()
                    //TODO Others
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
                    //TODO Others
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

    func sample() {
        let p1 = Float(pulse1.output())
        let p2 = Float(pulse2.output())
        let triangle: Float = 0.0
        let noise: Float = 0.0
        let dmc: Float = 0.0

        let pulseOut = 95.88 / ((8128 / (p1 + p2)) + 100)
        let tndOut = 159.79 / (1 / ((triangle / 8227) + (noise / 12241) + (dmc / 22638)) + 100)

        let sample = pulseOut + tndOut
        //TODO Output to audio buffer
        print(sample)
    }
}

extension APU {
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
            //TODO Triangle
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
            //TODO triangle, noise, DMC
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
            timerCounter = timer
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
        print("clockSweepUnit \(sweepUnit.counter) \(sweepEnabled) \(sweepUnitMuted)")
        if sweepUnit.counter == 0 && sweepEnabled && !sweepUnitMuted {
            var changeAmount = timerPeriod >> sweepShift
            print("changeAmount \(changeAmount)")
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
    func write(_ sample: Double)
}
