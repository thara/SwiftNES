public struct Pattern {
    var low = [UInt8](repeating: 0x00, count: 8)
    var high = [UInt8](repeating: 0x00, count: 8)

    subscript(row: Int, column: Int) -> Int {
        get {
            let col = UInt8(7 &- column)
            let l = low[row]
            let h = high[row]
            return Int((h[col] &<< 1) | l[col])
        }
    }

    public func toArray() -> [(x: Int, y: Int, pixel: Int)] {
        var data: [(x: Int, y: Int, pixel: Int)] = Array(repeating: (x: 0, y: 0, pixel: 0), count: 64)
        for y in 0..<8 {
            for x in 0..<8 {
                data[y * 8 + x] = (x: x, y: y, pixel: self[y, x])
            }
        }
        return data
    }
}

public func loadCharacterPattern(from cartridge: Cartridge) -> [Pattern] {
    let data = cartridge.mapper.characterData

    var patterns = [Pattern](repeating: Pattern(), count: data.count / 16)

    for (i, data) in data.enumerated() {
        if i % 16 < 8 {
            patterns[i / 16].low[i % 16] |= data
        } else {
            patterns[i / 16].high[i % 16 - 8] |= data
        }
    }
    return patterns
}
