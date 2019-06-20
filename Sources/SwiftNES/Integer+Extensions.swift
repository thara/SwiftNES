extension BinaryInteger {
    func radix16() -> String {
        return String(self, radix: 16)
    }
}

extension UInt8 {

    var u16: UInt16 {
        return UInt16(self)
    }

    var i8: Int8 {
        return Int8(bitPattern: self)
    }

    var i16: Int16 {
        return Int16(Int8(bitPattern: self))
    }
}

extension UInt16 {
    var i16: Int16 {
        return Int16(bitPattern: self)
    }
}

extension Int16 {
    var u16: UInt16 {
        return UInt16(bitPattern: self)
    }
}
