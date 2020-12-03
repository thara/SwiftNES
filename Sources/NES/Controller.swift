extension ControllerPort {

    func write(_ value: UInt8) {
        port1?.write(value)
        port2?.write(value)
    }

    func read(at addr: UInt16) -> UInt8 {
        switch addr {
        case 0x4016:
            return port1?.read() ?? 0x00
        case 0x4017:
            return port2?.read() ?? 0x00
        default:
            return 0x00
        }
    }
}

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
    }

    public init() {}

    var state: UInt8 = 0
    var current: UInt8 = 0
    var strobe: Bool = false

    public func write(_ value: UInt8) {
        strobe = value[0] == 1
        current = 1
    }

    public func read() -> UInt8 {
        if strobe {
            return 0x40 & state[Button.A.rawValue]
        }

        let input = state & current

        current &<<= 1
        return 0x40 | (0 < input ? 1 : 0)
    }

    public func update(button: Button) {
        state = button.rawValue
    }
}

