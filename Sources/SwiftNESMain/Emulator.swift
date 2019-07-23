import CSDL2
import SDL

import SwiftNES

final class Emulator {

    private let window: SDLWindow

    private let fps: UInt32

    private var event: SDL_Event

    private var isRunning = true

    let nes: NES

    init(windowTitle: String, windowScale: Int) throws {
        try SDL.initialize(subSystems: [.video])

        let windowSize = (width: 256 * windowScale, height: 240 * windowScale)
        window = try SDLWindow(title: windowTitle,
                               frame: (
                                   x: .centered,
                                   y: .centered,
                                   width: windowSize.width,
                                   height: windowSize.height),
                               options: [.resizable, .shown])
        fps = UInt32(try window.displayMode().refreshRate)

        let frameRenderer = try SDLFrameRenderer(window: window, windowSize: windowSize)

        let lineBufferFactory = SDLLineBufferFactory(renderer: frameRenderer)

        nes = makeNES(lineBufferFactory)

        event = SDL_Event()
    }

    deinit {
         SDL.quit()
    }

    func runLoop() throws {
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

            nes.runFrame()

            let endTime = SDL_GetTicks()
            let frameDuration = endTime - startTime

            mainLogger.debug("Frame Duration: \(frameDuration)")

            // sleep to save energy
            if frameDuration < 1000 / fps {
                SDL_Delay((1000 / fps) - frameDuration)
            }
        }
    }
}
