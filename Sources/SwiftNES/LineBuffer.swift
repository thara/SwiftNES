public struct LineBuffer {
    public var buffer = [UInt32](repeating: 0x00, count: NES.maxDot)
    public var backgroundBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)
    public var spriteBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)

    mutating func clear() {
        buffer = [UInt32](repeating: 0x00, count: NES.maxDot)
        backgroundBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)
        spriteBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)
    }

    mutating func write(_ pixel: Int, _ background: Int, _ sprite: Int, at x: Int) {
        buffer[x] = palletes[pixel]
        backgroundBuffer[x] = palletes[background]
        spriteBuffer[x] = palletes[sprite]
    }
}
