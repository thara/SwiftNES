class PluseWaveChannel {

    var envelope: EnvelopeGenerator
    var sweepUnit: SweepUnit
    var timer: Timer
    var sequencer: Sequencer
    var lengthCounter: LengthCounter

    static func pulse1() -> PluseWaveChannel {
        return PluseWaveChannel(sweepUnitCarryMode: .onesComplement)
    }

    static func pulse2() -> PluseWaveChannel {
        return PluseWaveChannel(sweepUnitCarryMode: .twosComplement)
    }

    init(sweepUnitCarryMode: SweepUnit.CarryMode) {
        envelope = EnvelopeGenerator()
        sweepUnit = SweepUnit(carryMode: sweepUnitCarryMode)
        timer = Timer()
        sequencer = Sequencer()
        lengthCounter = LengthCounter()

        sweepUnit.connect(to: timer).connect(to: sequencer)
    }

    func output() -> UInt16 {
        return envelope.output()
            |> sweepUnit.gate
            |> sequencer.gate
            |> lengthCounter.gate
    }
}
