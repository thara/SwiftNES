final class Iterator {
    fileprivate var pointer = 0

    private let limit: Int

    init(limit: Int) {
        self.limit = limit
    }

    @inline(__always)
    var hasNext: Bool {
        return pointer < limit
    }
}

extension Array where Element == UInt8 {

    @inline(__always)
    subscript(iterator: SwiftNES.Iterator) -> UInt8 {
        get {
            let value = self[iterator.pointer]
            iterator.pointer += 1
            return value
        }
        set {
            self[iterator.pointer] = newValue
            iterator.pointer += 1
        }
    }
}
