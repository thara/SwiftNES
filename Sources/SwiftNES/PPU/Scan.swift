struct Scan: CustomDebugStringConvertible {
    enum Update: Equatable {
        case dot
        case line(lastLine: Int)
        case frame(lastLine: Int)
    }

    var dot: Int = 0
    var line: Int = 0

    mutating func clear() {
        dot = 0
        line = 0
    }

    mutating func skip() {
        dot &+= 1
    }

    mutating func nextDot() -> Update {
        dot &+= 1
        if NES.maxDot <= dot {
            dot %= NES.maxDot

            let last = line

            line &+= 1
            if NES.maxLine < line {
                line = 0
                return .frame(lastLine: last)
            } else {
                return .line(lastLine: last)
            }
        } else {
            return .dot
        }
    }

    var debugDescription: String {
        return "dot:\(dot), line:\(line)"
    }
}
