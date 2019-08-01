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

        let driver = SDLRenderer.Driver.default

        let renderer = try SDLRenderer(window: window, driver: driver, options: [.accelerated, .presentVsync])
        renderer.setLogicalSize(w: Int32(windowSize.width), h: Int32(windowSize.height))

        let screenRect = SDL_Rect(x: 0, y: 0, w: Int32(windowSize.width), h: Int32(windowSize.height))

        let frameRenderer = try SDLFrameRenderer(renderer: renderer, screenRect: screenRect)

        nes = makeNES(renderer: frameRenderer)

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
        }
    }
}
