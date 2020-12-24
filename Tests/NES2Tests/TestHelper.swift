@testable import NES2

struct CPUStub: CPU {
    typealias Bus = [UInt8]
    var cpuCycles: UInt = 0

    mutating func cpuTick() -> UInt {
        cpuCycles += 1
        return cpuCycles
    }

    mutating func cpuTick(count: UInt) -> UInt {
        cpuCycles += count
        return cpuCycles
    }
}

extension Array: CPUBus where Element == UInt8 {

    public func read(at address: UInt16) -> UInt8 {
        return self[Int(address)]
    }

    public mutating func write(_ value: UInt8, at address: UInt16) {
        self[Int(address)] = value
    }
}
