public class LineBuffer {

    public static let displayedDots = 256

    private var buffer: [UInt32]
    private(set) var lineNumber: Int = 0
    private(set) var dot: Int = 0

    private var frames: UInt = 0

    let maxDot: Int
    let maxLine: Int

    private let renderer: Renderer

    public init(pixels: UInt16, lines: UInt16, renderer: Renderer) {
        self.buffer = [UInt32](repeating: 0x00, count: Int(pixels))

        maxDot = Int(pixels)
        maxLine = Int(lines)

        self.renderer = renderer
    }

    func clear() {
        lineNumber = 0
        dot = 0
        buffer = [UInt32](repeating: 0x00, count: buffer.count)
    }

    func skip() {
        dot &+= 1
    }

    func nextDot() {
        dot &+= 1
        if maxDot <= dot {
            flush()

            dot %= 341
            lineNumber &+= 1
        }
    }

    func write(pixel: UInt32) {
        buffer[dot] = pixel
    }

    func flush() {
        renderer.newLine(number: lineNumber, pixels: &buffer)

        if maxLine <= (lineNumber &+ 1) {
            renderer.newFrame(frames: Int(frames))

            lineNumber = 0
            frames &+= 1
        }
    }
}

public protocol LineBufferFactory {

    func make(pixels: UInt16, lines: UInt16) -> LineBuffer
}
