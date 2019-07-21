import CSDL2
import SDL

func main() throws {
    try SDL.initialize(subSystems: [.video])
    defer { SDL.quit() }

    let windowSize = (width: 256 * 3, height: 240 * 3)
    let window = try SDLWindow(title: "SwiftNES",
                               frame: (
                                   x: .centered,
                                   y: .centered,
                                   width: windowSize.width,
                                   height: windowSize.height),
                               options: [.resizable, .shown])

    let fps = try window.displayMode().refreshRate

    let frameRenderer = try SDLFrameRenderer(window: window, windowSize: windowSize)

    var isRunning = true

    let color = SDLColor(format: try SDLPixelFormat(format: .argb8888), red: 0x85, green: 0x19, blue: 0x19)
    let pixels = [UInt32](repeating: color.rawValue, count: 256)
    for n in 0..<240 {
        frameRenderer.renderLine(number: n, pixels: pixels)
    }

    var event = SDL_Event()
    while isRunning {
        SDL_PollEvent(&event)

        let startTime = SDL_GetTicks()
        let eventType = SDL_EventType(rawValue: event.type)

        switch eventType {
        case SDL_QUIT, SDL_APP_TERMINATING:
            isRunning = false
        default:
            break
        }

        try frameRenderer.update()

        let endTime = SDL_GetTicks()
        let frameDuration = endTime - startTime

        // sleep to save energy
        if frameDuration < 1000 / UInt32(fps) {
            SDL_Delay((1000 / UInt32(fps)) - frameDuration)
        }
    }
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
