// http://wiki.nesdev.com/w/index.php/APU_Envelope
class EnvelopeGenerator {

    var startFlag: Bool

    var divider: Divider
    var decayLevelCounter: UInt = 0

    var constantVolumeFlag: Bool = false

    init() {
        decalLevelCounter = DecalLevelCounter()
        divider = Divider {
            loadV()
            decalLevelCounter.clock()
        }
    }

    func loadV() {
        // constantVolumeFlag = XXXX
    }

    func clock() {
        if startFlag {
            startFlag = false
            decalLevelCounter.reload()
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

struct DecalLevelCounter: APUComponent {
    var counter: UInt16 = 0

    var loopFlag: Bool = false

    func reload() {
        counter = 15
    }

    func clock() {
        if counter != 0 {
            counter &- 1
            if loopFlag {
                counter = 15
            }
        }
    }
}
