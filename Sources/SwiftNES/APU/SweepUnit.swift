// http://wiki.nesdev.com/w/index.php/APU_Sweep
class SweepUnit {

    var reloadFlag = false

    var enabled = false
    var negate = false
    var shiftCount: UInt16 = 0

    var targetPeriod: UInt16 = 0

    lazy var divider: Divider = {
        Divider { self.timer?.update(newPeriod: self.targetPeriod) }
    }()
    var timer: Timer? = nil

    init() {
    }

    func connect(to timer: Timer) -> Timer {
        self.timer = timer
        return timer
    }

    func calculateTargetPeriod(_ period: UInt16) -> UInt16 {
        // TODO
        // Pulse 1 adds the ones' complement (−c − 1). Making 20 negative produces a change amount of −21.
        // Pulse 2 adds the two's complement (−c). Making 20 negative produces a change amount of −20.
        let changeAmount = Int(period >> shiftCount) * (negate ? -1 : 1)
        return UInt16(Int(period) &+ changeAmount)
    }

    var mutated: Bool {
        return 0x7FF < targetPeriod
    }

    func clock(rawTimerPeriod: UInt16) {
        if divider.zero && enabled && !mutated {
            // The pulse's period is adjusted.
            targetPeriod = calculateTargetPeriod(rawTimerPeriod)
        }
        //FIXME Modify divider internal state
        if divider.zero || reloadFlag {
            reloadFlag = false
            divider.reload()
            divider.nextClock()
        } else {
            divider.counter &-= 1
        }
    }

    func gate(input: UInt16) -> UInt16 {
        if enabled {
            return input
        } else {
            return 0
        }
    }
}
