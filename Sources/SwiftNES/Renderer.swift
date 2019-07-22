public protocol Renderer {
    func newLine(number: Int, pixels: inout [UInt32])
    func newFrame(frames: Int)
}
