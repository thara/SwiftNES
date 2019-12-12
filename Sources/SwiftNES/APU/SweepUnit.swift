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
    var timer: Timer?

    enum CarryMode {
        case onesComplement, twosComplement
    }
    let carryMode: CarryMode

    init(carryMode: CarryMode) {
        self.carryMode = carryMode
    }

    func update(by data: UInt8) {
        enabled = data[7] == 1
        divider.updatePeriod(using: (data & 0b01110000) >> 4)
        negate = data[3] == 1
        shiftCount = UInt16(data & 0b111)

        reloadFlag = true
    }

    func connect(to timer: Timer) -> Timer {
        self.timer = timer
        return timer
    }

    func calculateTargetPeriod(_ period: UInt16) -> UInt16 {
        var changeAmount = Int16(period >> shiftCount)
        if negate {
            switch carryMode {
            case .onesComplement:
                changeAmount = changeAmount * -1 - 1
            case .twosComplement:
                changeAmount = changeAmount * -1      // swiftlint:disable shorthand_operator
            }
        }
        return UInt16(Int16(period) &+ changeAmount)
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
