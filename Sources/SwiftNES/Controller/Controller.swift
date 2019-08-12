protocol Controller: class {
    var polling: Bool { get set }

    func read() -> UInt8
}

struct ControllerPort {

    var port1: Controller
    var port2: Controller

    mutating func write(value: UInt8) {
        let latch = value[0] == 1
        port1.polling = latch
        port2.polling = latch
    }

    func read(addr: UInt16) -> UInt8 {
        switch addr {
        case 0x4016:
            return port1.read()
        case 0x4017:
            return port2.read()
        default:
            return 0x00
        }
    }
}
