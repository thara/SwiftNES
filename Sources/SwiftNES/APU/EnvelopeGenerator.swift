// http://wiki.nesdev.com/w/index.php/APU_Envelope
class EnvelopeGenerator {

    var startFlag = false

    var envelopeVolumeLoader: EnvelopeVolumeLoader?

    lazy var divider: Divider = {
        Divider {
            self.parameter = self.envelopeVolumeLoader!.loadEnvelopeVolume()
            self.decayLevelCounter.clock()
        }
    }()
    var decayLevelCounter = DecayLevelCounter()

    var useConstantValume = false

    var parameter: UInt16 = 0

    func update(by value: UInt8) {
        useConstantValume = value.constantVolumeFlag
        if useConstantValume {
            parameter = UInt16(value.value)
        }

        divider.updatePeriod(using: value.value)
    }

    func restart() {
        startFlag = true
    }

    func clock() {
        if startFlag {
            startFlag = false
            decayLevelCounter.reload()
            divider.reload()
        } else {
            divider.clock()
            guard divider.zero else {
                return
            }
            decayLevelCounter.clock()
        }
    }

    func output() -> UInt16 {
        if useConstantValume {
            return parameter
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

protocol EnvelopeVolumeLoader: class {
    func loadEnvelopeVolume() -> UInt16
}
