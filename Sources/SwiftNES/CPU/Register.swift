struct Registers {
    /// Accumulator
    var A: UInt8 {
        didSet {
            if A == 0 { P.formUnion(.Z) }
            if A & 0x80 != 0 { P.formUnion(.N) }
        }
    }
    /// Index register
    var X: UInt8 {
        didSet {
            if X == 0 { P.formUnion(.Z) }
            if X & 0x80 != 0 { P.formUnion(.N) }
        }
    }
    /// Index register
    var Y: UInt8 {
        didSet {
            if Y == 0 { P.formUnion(.Z) }
            if Y & 0x80 != 0 { P.formUnion(.N) }
        }
    }
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
