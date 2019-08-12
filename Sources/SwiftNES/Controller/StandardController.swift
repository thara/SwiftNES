// http://wiki.nesdev.com/w/index.php/Standard_controller
public final class StandardController: Controller {

    public struct Button: OptionSet {
        public let rawValue: UInt8

        public static let A = Button(rawValue: 1 << 0)
        public static let B = Button(rawValue: 1 << 1)
        public static let select = Button(rawValue: 1 << 2)
        public static let start = Button(rawValue: 1 << 3)
        public static let up = Button(rawValue: 1 << 4)
        public static let down = Button(rawValue: 1 << 5)
        public static let left = Button(rawValue: 1 << 6)
        public static let right = Button(rawValue: 1 << 7)

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        func shift() -> Button? {
            if self == Button.right {
                return nil
            }
            return Button(rawValue: rawValue &<< 1)
        }
    }

    var state: UInt8 = 0
    var strobe: Button?

    var polling: Bool = false {
        didSet {
            strobe = .A
        }
    }

    func read() -> UInt8 {
        if polling {
            return 0x40 & state[Button.A.rawValue]
        }

        let input: UInt8
        if let button = strobe {
            input = state[button.rawValue]
        } else {
            input = 1
        }

        strobe = strobe?.shift()
        return 0x40 & input
    }

    func press(button: Button) {
        guard polling else { return }
        state = button.rawValue
    }
}
