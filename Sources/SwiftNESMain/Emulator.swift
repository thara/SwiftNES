import CSDL2
import SDL

import SwiftNES

final class Emulator {

    private let nes: NES

    private let window: SDLWindow
    private let windowTitle: String
    private var event: SDL_Event

    private let fps: UInt32
    private var isRunning = true

    private let controller: VirtualStandardController

    init(windowTitle: String, windowScale: Int) throws {
        try SDL.initialize(subSystems: [.video])

        self.windowTitle = windowTitle

        let windowSize = (
            width: NES.width * windowScale,
            height: NES.height * windowScale)
        window = try SDLWindow(title: windowTitle,
                               frame: (
                                   x: .centered,
                                   y: .centered,
                                   width: windowSize.width,
                                   height: windowSize.height),
                               options: [.shown, .inputFocus])
        fps = UInt32(try window.displayMode().refreshRate)

        let driver = SDLRenderer.Driver.default

        let renderer = try SDLRenderer(window: window, driver: driver, options: [.accelerated, .presentVsync])
        renderer.setLogicalSize(w: Int32(windowSize.width), h: Int32(windowSize.height))

        let screenRect = SDL_Rect(x: 0, y: 0, w: Int32(windowSize.width), h: Int32(windowSize.height))

        let frameRenderer = try SDLFrameRenderer(renderer: renderer, screenRect: screenRect)

        controller = VirtualStandardController()

        nes = makeNES(renderer: frameRenderer)
        nes.connect(controller1: controller.nesController, controller2: nil)

        event = SDL_Event()
    }

    deinit {
         SDL.quit()
    }

    func loadNESFile(path: String) throws {
        guard let cartridge = Cartridge(file: try NESFile(path: path)) else {
            fatalError("Unsupported mapper")
        }
        nes.insert(cartridge: cartridge)
    }

    func runLoop() throws {
        window.raise()

        let delay = 1000 / fps

        let keyboardState = SDL_GetKeyboardState(nil)
        let currentKeys = UnsafeBufferPointer(start: keyboardState, count: 226)

        while isRunning {
            let startTime = SDL_GetTicks()
            let eventType = SDL_EventType(rawValue: event.type)

            while SDL_PollEvent(&event) != 0 {
                switch eventType {
                case SDL_QUIT, SDL_APP_TERMINATING:
                    isRunning = false
                default:
                    break
                }
            }

            controller.update(keys: currentKeys)

            nes.runFrame()

            let endTime = SDL_GetTicks()
            let frameDuration = endTime - startTime

            //  Wait to mantain framerate
            if frameDuration < delay {
                SDL_Delay(delay - frameDuration)
            }

            window.setWindowTitle("\(windowTitle) - \(1000 / frameDuration) fps")
        }
    }
}
