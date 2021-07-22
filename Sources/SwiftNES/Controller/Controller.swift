public protocol Controller: AnyObject {
    func write(_ value: UInt8)
    func read() -> UInt8
}

class ControllerPort {

    var port1: Controller?
    var port2: Controller?

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
