// http://wiki.nesdev.com/w/index.php/APU_Envelope
class EnvelopeGenerator {

    var startFlag = false

    lazy var divider: Divider = {
        Divider {
            self.loadV()
            self.decayLevelCounter.clock()
        }
    }()
    var decayLevelCounter = DecayLevelCounter()

    var constantVolumeFlag = false

    func loadV() {
        // constantVolumeFlag = XXXX
    }

    func clock() {
        if startFlag {
            startFlag = false
            decayLevelCounter.reload()
            divider.reload()
        } else {
            divider.clock()
            let zero = divider.zero

            guard zero else {
                return
            }

            decayLevelCounter.clock()
        }
    }

    func output() -> UInt16 {
        if constantVolumeFlag {
            // the envelope parameter
            return 0
        } else {
            return decayLevelCounter.counter
        }
    }
}

class DecayLevelCounter {
    var counter: UInt16 = 0

    var loopFlag: Bool = false

    func reload() {
        counter = 15
    }

    func clock() {
        if counter != 0 {
            counter &-= 1
            if loopFlag {
                counter = 15
            }
        }
    }
}
