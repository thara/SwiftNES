import Foundation

typealias OpCode = UInt8

typealias Operand = UInt16

struct CPU {
    /// Accumulator
    var A: UInt8 = 0x00 { didSet { P.setZN(A) } }
    /// Index register
    var X: UInt8 = 0x00 { didSet { P.setZN(X) } }
    /// Index register
    var Y: UInt8 = 0x00 { didSet { P.setZN(Y) } }
    /// Stack pointer
    var S: UInt8 = 0xFF
    /// Status register
    struct Status: OptionSet {
        let rawValue: UInt8
        /// Negative
        static let N = Status(rawValue: 1 << 7)
        /// Overflow
        static let V = Status(rawValue: 1 << 6)
        static let R = Status(rawValue: 1 << 5)
        static let B = Status(rawValue: 1 << 4)
        /// Decimal mode
        static let D = Status(rawValue: 1 << 3)
        /// IRQ prevention
        static let I = Status(rawValue: 1 << 2)
        /// Zero
        static let Z = Status(rawValue: 1 << 1)
        /// Carry
        static let C = Status(rawValue: 1 << 0)
        // https://wiki.nesdev.com/w/index.php/Status_flags#The_B_flag
        static let operatedB = Status(rawValue: 0b110000)
        static let interruptedB = Status(rawValue: 0b100000)
    }
    var P: Status = []
    /// Program Counter
    var PC: UInt16 = 0x00

    var cycles: UInt = 0

}

extension CPU.Status {
    mutating func setZN(_ value: UInt8) {
        if value == 0 {
            formUnion(.Z)
        } else {
            remove(.Z)
        }
        if value[7] == 1 {
            formUnion(.N)
        } else {
            remove(.N)
        }
    }

    mutating func setZN(_ value: Int16) {
        if value == 0 {
            formUnion(.Z)
        } else {
            remove(.Z)
        }
        if value[7] == 1 {
            formUnion(.N)
        } else {
            remove(.N)
        }
    }
}
