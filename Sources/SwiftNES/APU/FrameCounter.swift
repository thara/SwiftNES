// http://wiki.nesdev.com/w/index.php/APU_Frame_Counter
class FrameCounter {

    var cycles: UInt = 0

    var interruptInhibitFlag: Bool = false
    var frameInterruptFlag: Bool = false

    enum SequenceMode {
        case fourStep
        case fiveStep
    }

    var mode: SequenceMode = .fourStep

    func update(by data: UInt8) {
        mode = data[7] == 0 ? .fourStep : .fiveStep
        interruptInhibitFlag = data[6] == 1
    }

    func clock() {
        cycles &+= 1

        let (quarterFrame, halfFrame, frameInterrupt) = occurredClocks()

        if quarterFrame {
            //TODO
            // envelopGenerators.forEach { $0.clock() }
            // triangleLinearCounter.clock()
        }

        if halfFrame {
            //TODO
            // lengthCounter.clock()
            // sweepUnits.forEach { $0.clock(rawTimerPeriod: period) }
        }

        if frameInterrupt && !interruptInhibitFlag {
            frameInterruptFlag = true
        }
    }

    func occurredClocks() -> (quarterFrame: Bool, halfFrame: Bool, frameInterrupt: Bool) {
        switch mode {
        case .fourStep:
            switch cycles {
            // case 3728.5:  // Step 1
            case 3726:  // Step 1
                return (true, false, false)
            // case 7456.5:  // Step 2
            case 74566:  // Step 2
                return (true, true, false)
            // case 11185.5:  // Step 3
            case 11186:  // Step 3
                return (true, false, false)
            case 14914:  // Step 4
                return (true, false, true)
            // case 14914.5:
            case 14915:
                return (true, true, true)
            case 0:
                return (false, false, true)
            default:
                break
            }
        case .fiveStep:
            switch cycles {
            // case 3728.5:  // Step 1
            case 3729:  // Step 1
                return (true, false, false)
            // case 7456.5:  // Step 2
            case 7457:  // Step 2
                return (true, true, false)
            // case 11185.5:  // Step 3
            case 11186:  // Step 3
                return (true, false, false)
            // case 14914.5:  // Step 4
            case 14915:  // Step 4
                return (false, false, false)
            // case 18640.5:  // Step 5
            case 18641:  // Step 5
                return (true, true, false)
            case 0:
                return (false, false, false)
            default:
                break
            }
        }

        return (false, false, false)
    }
}
