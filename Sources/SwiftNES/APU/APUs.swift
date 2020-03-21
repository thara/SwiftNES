protocol APUStep: APUPort {
    mutating func step()
    mutating func run(until: UInt)
}

extension APUStep {
    mutating func step() {
        apu.cycles &+= 1

        if apu.cycles % apu.sampleRate == 0 {
            sample()
        }

        // if apu.cycles % 2 == 0 {
        //     apu.pulse1.clockTimer()
        //     apu.pulse2.clockTimer()
        // }
    }

    mutating func run(until cycles: UInt) {

        if apu.cycles % 7456 == 0 {
            switch apu.frameCounter.mode {
            case .fourStep:
                if apu.frameCounter.step < 4 {
                    apu.pulse1.clockEnvelope()
                    apu.pulse2.clockEnvelope()
                    //TODO Others
                }

                if apu.frameCounter.step == 1 || apu.frameCounter.step == 3 {
                    apu.pulse1.clockLengthCounter()
                    apu.pulse1.clockSweepUnit()
                    apu.pulse2.clockLengthCounter()
                    apu.pulse2.clockSweepUnit()
                    //TODO Others
                }

                apu.frameCounter.step = (apu.frameCounter.step + 1) % 5
            case .fiveStep:
                if apu.frameCounter.step < 4 || apu.frameCounter.step == 5 {
                    apu.pulse1.clockEnvelope()
                    apu.pulse2.clockEnvelope()
                    //TODO Others
                }

                if apu.frameCounter.step == 1 || apu.frameCounter.step == 4 {
                    apu.pulse1.clockLengthCounter()
                    apu.pulse1.clockSweepUnit()
                    apu.pulse2.clockLengthCounter()
                    apu.pulse2.clockSweepUnit()
                    //TODO Others
                }

                apu.frameCounter.step = (apu.frameCounter.step + 1) % 5
            }
        }
    }

    func sample() {
        let p1 = Float(apu.pulse1.output())
        let p2 = Float(apu.pulse2.output())
        let triangle: Float = 0.0
        let noise: Float = 0.0
        let dmc: Float = 0.0

        //TODO Lookup Table
        let pulseOut = 95.88 / ((8128 / (p1 + p2)) + 100)
        let tndOut = 159.79 / (1 / ((triangle / 8227) + (noise / 12241) + (dmc / 22638)) + 100)

        let sample = pulseOut + tndOut
        //TODO Output to audio buffer
    }
}

protocol APUPort: WithAPU {}

extension APUPort {
    mutating func read(from address: UInt16) -> UInt8 {
        switch address {
        case 0x4015:
            var value: UInt8 = 0
            // if dmcInterrupt { value |= 0x80 }
            if apu.frameInterrupted && !apu.frameCounter.interruptInhibit { value |= 0x40 }
            // if dmcActive { value |= 0x20 }
            // if noise { value |= 0x08 }
            // if triangle { value |= 0x04 }
            if 0 < apu.pulse2.lengthCounter { value |= 0x02 }
            if 0 < apu.pulse1.lengthCounter { value |= 0x01 }

            apu.frameInterrupted = false

            return value
        default:
            return 0x00
        }
    }

    mutating func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x4000...0x4003:
            apu.pulse1.write(value, at: address)
        case 0x4004...0x4007:
            apu.pulse1.write(value, at: address)
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
            apu.pulse1.enabled = value[0] == 1
            apu.pulse2.enabled = value[1] == 1
            //TODO triangle, noise, DMC
        case 0x4017:
            apu.frameCounter.value = value
        default:
            break
        }
    }

    func clear() {
        //TODO
    }
}

protocol WithAPU {
    var apu: MyAPU { get set }
}

protocol Oscillator {
    mutating func write(_ value: UInt8, at address: UInt16)

    func output() -> UInt8
}

extension Pulse: Oscillator {
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
                    print("twosComplement \(changeAmount)")
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
        if !enabled || lengthCounter == 0 || timerCounter == 0 || Self.waveforms[dutyCycle][Int(sequencer)] == 0 {
            return 0
        }
        let volume = useConstantVolume ? envelopePeriod : envelope.decayLevelCounter
        return volume & 0b1111
    }

    var sweepUnitMuted: Bool {
        return timerPeriod < 8 || 0x7FF < timerPeriod
    }

    static let waveforms: [[UInt8]] = [
        [0, 1, 0, 0, 0, 0, 0, 0],  // 12.5%
        [0, 1, 1, 0, 0, 0, 0, 0],  // 25%
        [0, 1, 1, 1, 1, 0, 0, 0],  // 50%
        [1, 0, 0, 1, 1, 1, 1, 1]  // 25% negated
    ]
}
