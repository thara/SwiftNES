import CSDL2
import SDL
import SwiftNES

let screenWidth = NES.width
let screenHeight = 224

final class Emulator {

    private let nes: NES

    private let window: SDLWindow
    private let windowTitle: String
    private var event: SDL_Event

    private let fps: UInt32
    private var isRunning = true

    private let controller: VirtualStandardController

    private let frameRenderer: SDLFrameRenderer

    private let audioBuffer: SDLAudioBuffer

    init(windowTitle: String, windowScale: Int) throws {
        try SDL.initialize(subSystems: [.video, .audio])

        self.windowTitle = windowTitle

        let windowSize = (
            width: screenWidth * windowScale,
            height: screenHeight * windowScale
        )
        window = try SDLWindow(
            title: windowTitle,
            frame: (
                x: .centered,
                y: .centered,
                width: windowSize.width,
                height: windowSize.height
            ),
            options: [.shown, .inputFocus])
        fps = UInt32(try window.displayMode().refreshRate)

        let driver = SDLRenderer.Driver.default

        let renderer = try SDLRenderer(window: window, driver: driver, options: [.accelerated, .presentVsync])
        try renderer.setLogicalSize(width: Int32(windowSize.width), height: Int32(windowSize.height))

        let screenRect = SDL_Rect(x: 0, y: 0, w: Int32(windowSize.width), h: Int32(windowSize.height))

        frameRenderer = try SDLFrameRenderer(renderer: renderer, screenRect: screenRect)

        controller = VirtualStandardController()

        nes = NES()
        nes.connect(controller1: controller.nesController, controller2: nil)

        event = SDL_Event()

        audioBuffer = SDLAudioBuffer(sampleRate: 96000, channels: 2, bufferSize: 4096)
    }

    deinit {
        SDL.quit()
    }

    func loadNESFile(path: String) throws {
        let cartridge = try Cartridge(file: try NESFile(path: path))
        nes.insert(cartridge: cartridge)
    }

    func runLoop() throws {
        window.raise()

        let keyboardState = SDL_GetKeyboardState(nil)
        let currentKeys = UnsafeBufferPointer(start: keyboardState, count: 226)

        var obtained: SDLAudioSpec?
        try openAudio(desired: &audioBuffer.audioSpec, obtained: &obtained)
        pauseAudio(false)

        defer {
            pauseAudio(true)
            closeAudio()
        }

        while isRunning {
            let startTicks = SDL_GetTicks()
            let startPerf = SDL_GetPerformanceCounter()

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

            nes.runFrame(withRenderer: frameRenderer, withAudio: audioBuffer)

            let endPerf = SDL_GetPerformanceCounter()

            let framePerf = Double(endPerf - startPerf) / Double(SDL_GetPerformanceFrequency()) * 1000
            if 0 < 16.666 - framePerf {
                // Capping 60 FPS
                SDL_Delay(UInt32(16.666 - framePerf))
            }

            let endTicks = SDL_GetTicks()
            let frameTicks = Double(endTicks - startTicks) / 1000

            if 0 < frameTicks {
                window.title = "\(windowTitle) - \(toString(1 / frameTicks)) fps"
            }
        }
    }
}

func toString(_ d: Double) -> String {
    return String(format: "%.0f", d)
}
