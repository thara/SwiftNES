public struct LineBuffer {
    public enum RenderingMode {
        case prioring, backgroundOnly, spriteOnly
    }

    var buffer = [UInt32](repeating: 0x00, count: NES.maxDot)
    var backgroundBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)
    var spriteBuffer = [UInt32](repeating: 0x00, count: NES.maxDot)

    var renderer: Renderer?
    var renderingMode: RenderingMode

    public init(renderer: Renderer? = nil, renderingMode: RenderingMode = .prioring) {
        self.renderer = renderer
        self.renderingMode = renderingMode
    }

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

    func flush(to line: Int) {
        switch renderingMode {
        case .prioring:
            renderer?.newLine(number: line, pixels: buffer)
        case .backgroundOnly:
            renderer?.newLine(number: line, pixels: backgroundBuffer)
        case .spriteOnly:
            renderer?.newLine(number: line, pixels: spriteBuffer)
        }
    }
}
