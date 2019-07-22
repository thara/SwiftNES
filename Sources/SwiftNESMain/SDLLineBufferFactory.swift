import SwiftNES

struct SDLLineBufferFactory: LineBufferFactory {

    let renderer: SDLFrameRenderer

    func make(pixels: UInt16, lines: UInt16) -> LineBuffer {
        return LineBuffer(pixels: pixels, lines: lines, renderer: renderer)
    }
}
