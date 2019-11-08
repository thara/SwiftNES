
class PluseWaveChannel {

    var envelopeGenerator: EnvelopeGenerator
    var sweepUnit: SweepUnit
    var timer: Timer
    var sequencer: Sequencer
    var lengthCounter: LengthCounter

    init() {
        envelopeGenerator = EnvelopeGenerator()
        sweepUnit = SweepUnit()
        timer = Timer()
        sequencer = Sequencer()
        lengthCounter = LengthCounter()

        sweepUnit.connect(to: timer).connect(to: sequencer)
    }

    func output() -> UInt16 {
        return envelopeGenerator.output()
            |> sweepUnit.gate
            |> sequencer.gate
            |> lengthCounter.gate
    }
}
