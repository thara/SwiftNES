extension BinaryInteger {

    var radix2: String {
        return String(self, radix: 2)
    }

    var radix16: String {
        return String(self, radix: 16)
    }
}

extension UInt8 {

    @inline(__always)
    var u16: UInt16 {
        return UInt16(self)
    }

    @inline(__always)
    var i8: Int8 {
        return Int8(bitPattern: self)
    }

    @inline(__always)
    var i16: Int16 {
        return Int16(Int8(bitPattern: self))
    }

    @inline(__always)
    subscript(n: UInt8) -> UInt8 {
        return (self &>> n) & 1
    }
}

extension UInt16 {
    @inline(__always)
    var i16: Int16 {
        return Int16(bitPattern: self)
    }

    @inline(__always)
    var i8: Int8 {
        return Int8(bitPattern: UInt8(self))
    }

    @inline(__always)
    subscript(n: UInt8) -> UInt16 {
        return (self &>> n) & 1
    }
}

extension Int16 {
    @inline(__always)
    var u16: UInt16 {
        return UInt16(bitPattern: self)
    }

    @inline(__always)
    subscript(n: UInt8) -> Int16 {
        return (self &>> n) & 1
    }
}
