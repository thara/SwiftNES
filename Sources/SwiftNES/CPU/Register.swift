struct Registers {
    /// Accumulator
    var A: UInt8 {
        didSet {
            if A & 0x80 != 0 {
                P.formUnion(.N)
            }
        }
    }
    /// Index register
    var X: UInt8
    /// Index register
    var Y: UInt8
    /// Stack pointer
    var S: UInt8
    /// Status register
    var P: Status
    /// Program Counter
    var PC: UInt16
}

/// Status register details
struct Status: OptionSet {
    let rawValue: UInt8

    /// Negative
    static let N = Status(rawValue: 1 << 7)
    /// Overflow
    static let V = Status(rawValue: 1 << 6)
    /// Reserved
    static let R = Status(rawValue: 1 << 5)
    /// Break mode
    static let B = Status(rawValue: 1 << 4)
    /// Decimal mode
    static let D = Status(rawValue: 1 << 3)
    /// IRQ prevention
    static let I = Status(rawValue: 1 << 2)
    /// Zero
    static let Z = Status(rawValue: 1 << 1)
    /// Carry
    static let C = Status(rawValue: 1 << 0)
}

extension UInt8 {
    /// Return whether a bit flagged at specified status as status register value
    func flagged(_ s: Status) -> Bool {
        return self & s.rawValue >= 1
    }
}

extension Sequence where Element == Status {
    func toBits() -> UInt8 {
        return reduce(0) { acc, e in acc + e.rawValue }
    }
}
