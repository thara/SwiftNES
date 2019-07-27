public class LineBuffer {

    private var buffer: [UInt32]

    private let renderer: Renderer

    public init(renderer: Renderer) {
        self.buffer = [UInt32](repeating: 0x00, count: NES.maxDot)
        self.renderer = renderer
    }

    func clear() {
        buffer = [UInt32](repeating: 0x00, count: buffer.count)
    }

    func write(pixel: UInt32, at x: Int) {
        buffer[x] = pixel
    }

    func flush(lineNumber: Int) {
        renderer.newLine(number: lineNumber, pixels: &buffer)
    }
}
