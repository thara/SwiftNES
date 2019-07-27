struct Scan {
    var dot: Int = 0
    var line: Int = 0

    mutating func clear() {
        dot = 0
        line = 0
    }

    mutating func skip() {
        dot &+= 1
    }

    mutating func nextDot() -> ScanUpdate {
        dot &+= 1
        if NES.maxDot <= dot {
            dot %= NES.maxDot

            let last = line

            line &+= 1
            if NES.maxLine <= line {
                line = 0
            }

            return .line(lastLine: last)
        } else {
            return .dot
        }
    }
}

enum ScanUpdate: Equatable {
    case dot
    case line(lastLine: Int)
}
