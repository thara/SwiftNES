
class PluseWaveChannel {

    var envelope: EnvelopeGenerator
    var sweepUnit: SweepUnit
    var timer: Timer
    var sequencer: Sequencer
    var lengthCounter: LengthCounter

    init() {
        envelope = EnvelopeGenerator()
        sweepUnit = SweepUnit()
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
