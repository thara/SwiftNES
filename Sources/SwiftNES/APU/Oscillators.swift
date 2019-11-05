
class PluseWaveChannel {

    var envelopGenerator: EnvelopGenerator
    var sweepUnit: SweepUnit
    var timer: Timer
    var sequencer: Sequencer
    var lengthCounter: LengthCounter

    init() {
        envelopGenerator = EnvelopGenerator()
        sweepUnit = SweepUnit()
        timer = Timer()
        sequencer = Sequencer()
        lengthCounter = LengthCounter()

        sweepUnit.connect(to: timer).connect(to: sequencer)
    }

    func output() -> UInt8 {
        return envelopGenerator.output()
            |> sweepUnit.gate
            |> sequencer.gate
            |> lengthCounter.gate
    }
}
