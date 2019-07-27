public protocol Renderer {
    func newLine(number: Int, pixels: inout [UInt32])
}
