/// Status register details
struct Status: OptionSet {
    let rawValue: UInt8

    /// Negative
    static let N = Status(rawValue: 1 << 7)
    /// Overflow
    static let V = Status(rawValue: 1 << 6)
    /// Decimal mode
    static let D = Status(rawValue: 1 << 3)
    /// IRQ prevention
    static let I = Status(rawValue: 1 << 2)
    /// Zero
    static let Z = Status(rawValue: 1 << 1)
    /// Carry
    static let C = Status(rawValue: 1 << 0)

    mutating func setZN(_ value: UInt8) {
        if value == 0 { formUnion(.Z) } else { remove(.Z) }
        if value[7] == 1 { formUnion(.N) } else { remove(.N) }
    }

    mutating func setZN(_ value: Int16) {
        if value == 0 { formUnion(.Z) } else { remove(.Z) }
        if value[7] == 1 { formUnion(.N) } else { remove(.N) }
    }

    // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
    static let operatedB = Status(rawValue: 0b110000)
    static let interruptedB = Status(rawValue: 0b100000)

    static let R = Status(rawValue: 1 << 5)
    static let B = Status(rawValue: 1 << 4)
}
