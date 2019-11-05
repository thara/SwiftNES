// http://wiki.nesdev.com/w/index.php/APU_Sweep
struct SweepUnit {

    var divider: Divider
    var reloadFlag = false

    var enabled = false
    var negate = false
    var shiftCount: UInt16 = 0

    var targetPeriod: UInt16 = 0

    var timer: Timer? = nil

    init() {
        divider = Divider {
            timer?.clock()
        }
    }

    func connect(to timer: Timer) -> UInt16 {
        self.timer = timer
    }

    func calculateTargetPeriod(_ period: UInt16) -> UInt16 {
        // TODO
        // Pulse 1 adds the ones' complement (−c − 1). Making 20 negative produces a change amount of −21.
        // Pulse 2 adds the two's complement (−c). Making 20 negative produces a change amount of −20.
        let changeAmount = (period >> shiftCount) * (negate ? -1 : 1)
        return period &+ changeAmount
    }

    var mutating: Bool {
        return 0x7FF < targetPeriod
    }

    func clock(rawTimerPeriod: UInt16) {
        if divider.zero && enabled && !mutating {
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

        } else {
            return input
        }
    }
}
