import CSDL2
import SDL

func main() throws {
    let app = try GUIApplication(windowTitle: "SwiftNES", windowScale: 3)

    let color = SDLColor(format: try SDLPixelFormat(format: .argb8888), red: 0x85, green: 0x19, blue: 0x19)
    let pixels = [UInt32](repeating: color.rawValue, count: 256)
    for n in 0..<240 {
        app.frameRenderer.renderLine(number: n, pixels: pixels)
    }

    try app.runLoop()
}

do {
    try main()
} catch let error as SDLError {
    print("Error: \(error.debugDescription)")
    exit(EXIT_FAILURE)
} catch {
    print("Error: \(error)")
    exit(EXIT_FAILURE)
}
