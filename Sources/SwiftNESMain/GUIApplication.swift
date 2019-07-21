import CSDL2
import SDL

import SwiftNES

class GUIApplication {

    let window: SDLWindow
    let frameRenderer: SDLFrameRenderer

    let fps: UInt32

    var event: SDL_Event

    var isRunning = true

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

        frameRenderer = try SDLFrameRenderer(window: window, windowSize: windowSize)

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

            do {
                try frameRenderer.update()
            } catch let error as SDLError {
                print("Frame Rendering Error: \(error.debugDescription)")
                throw error
            } catch {
                print("Frame Rendering Error: \(error)")
                throw error
            }

            let endTime = SDL_GetTicks()
            let frameDuration = endTime - startTime

            // sleep to save energy
            if frameDuration < 1000 / fps {
                SDL_Delay((1000 / fps) - frameDuration)
            }
        }
    }
}
