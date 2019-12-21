class APU {

    let sequencer = Sequencer()
    let pulse1: PluseWaveChannel = .pulse1()
    let pulse2: PluseWaveChannel = .pulse2()
    let frameCounter = FrameCounter()

    let mixer = Mixer()

    static let sampleRate: Double = 96000

    private var cycles: UInt = 0

    init() {
        frameCounter.envelopeGenerators.append(pulse1.envelope)
        frameCounter.sweepUnits.append(pulse1.sweepUnit)
        frameCounter.timers.append(pulse1.timer)
    }

    func step() {
        let before = cycles
        cycles &+= 1
        let after = cycles

        if cycles % 2 == 0 {
            pulse1.timer.clock()
        }

        frameCounter.clock()

        if Double(before) / APU.sampleRate != Double(after) / APU.sampleRate {
            let p1 = pulse1.output()
            let p2 = pulse2.output()
            //TODO Write to audio buffer
            _ = mixer.mix(pulse1: p1, pulse2: p2)
        }
    }
}

// MARK: - Memory Map
extension APU: Memory {

    @inline(__always)
    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x4015:
            let dmcInterrupt: UInt8 = 0
            let frameInterrupt = unsafeBitCast(frameCounter.frameInterruptFlag, to: UInt8.self)
            let dmcActive: UInt8 = 0
            let noiseLength: UInt8 = 0
            let triangleLength: UInt8 = 0
            let pulse2: UInt8 = 0
            let pulse1 = unsafeBitCast(0 < self.pulse1.lengthCounter.counter, to: UInt8.self)
            return ((dmcInterrupt << 7) | (frameInterrupt << 6) | (dmcActive << 4) | (noiseLength << 3) | (triangleLength << 2) | (pulse2 << 1) | pulse1
            )
        default:
            break
        }
        return 0x00
    }

    @inline(__always)
    func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x4000:
            sequencer.update(duty: value.dutyCycle)
            pulse1.lengthCounter.halt = value.lengthCounterHalt
            pulse1.envelope.update(by: value)
        case 0x4001:
            pulse1.sweepUnit.update(by: value)
        case 0x4002:
            pulse1.timer.low = value
        case 0x4003:
            pulse1.lengthCounter.reload(by: value)
            pulse1.timer.high = value & 0b111
            pulse1.envelope.restart()

        //TODO Pulse 2
        case 0x4004...0x4007:
            break
        //TODO Triangle
        case 0x4008...0x400B:
            break
        //TODO Noise
        case 0x400C...0x400F:
            break
        //TODO DMC
        case 0x4010...0x4013:
            break

        case 0x4015:
            pulse1.lengthCounter.enabled = value[0] == 1
            //TODO pulse2, triangle, noise, DMC

        case 0x4017:
            frameCounter.update(by: value)

        default:
            break
        }
    }

    func clear() {
        //TODO
    }
}
