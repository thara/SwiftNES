// http://wiki.nesdev.com/w/index.php/APU#Glossary timer
class Timer {
    var low: UInt8 = 0
    var high: UInt8 = 0

    lazy var divider: Divider = {
        Divider { self.sequencer?.clock() }
    }()
    var sequencer: Sequencer?

    func update(newPeriod: UInt16) {
        divider.period = UInt(newPeriod)
    }

    var value: UInt16 {
        // HHHLLLLLLLL
        return ((high.u16 & 0b111) << 8) | low.u16
    }

    func load() {
        // new value of t loaded
        divider.period = UInt(value)
    }

    func connect(to sequencer: Sequencer) {
        self.sequencer = sequencer
    }

    func clock() {
        divider.clock()
    }
}
