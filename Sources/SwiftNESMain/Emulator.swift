import CSDL2
import SDL
import SoundIO

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

    init(windowTitle: String, windowScale: Int) throws {
        try SDL.initialize(subSystems: [.video])

        self.windowTitle = windowTitle

        let windowSize = (
            width: screenWidth * windowScale,
            height: screenHeight * windowScale)
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
        try renderer.setLogicalSize(width: Int32(windowSize.width), height: Int32(windowSize.height))

        let screenRect = SDL_Rect(x: 0, y: 0, w: Int32(windowSize.width), h: Int32(windowSize.height))

        frameRenderer = try SDLFrameRenderer(renderer: renderer, screenRect: screenRect)

        controller = VirtualStandardController()

        nes = NES()
        nes.connect(controller1: controller.nesController, controller2: nil)

        event = SDL_Event()
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

        var secondsOffset: Float = 0.0

        let soundio = try SoundIO()
        try soundio.connect()
        soundio.flushEvents()

        let outputDeviceIndex = try soundio.defaultOutputDeviceIndex()
        let device = try soundio.getOutputDevice(at: outputDeviceIndex)
        let outstream = try OutStream(to: device)
        outstream.format = .float32bitLittleEndian

        outstream.writeCallback { (outstream, _, frameCountMax) in
            let layout = outstream.layout
            let secondsPerFrame = 1.0 / Float(outstream.sampleRate)

            try! outstream.write(frameCount: frameCountMax) { (areas, frameCount) in
                let pitch: Float = 440.0
                let radiansPerSecond = pitch * 2.0 * .pi
                for frame in 0..<frameCount {
                    let sample = sin((secondsOffset + Float(frame) * secondsPerFrame) * radiansPerSecond)
                    for area in areas.iterate(over: layout.channelCount) {
                        area.write(sample, stepBy: frame)
                    }
                }
                secondsOffset = (secondsOffset + secondsPerFrame * Float(frameCount)).truncatingRemainder(dividingBy: 1)
            }
        }

        try outstream.open()
        try outstream.start()

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

            nes.runFrame(onLineEnd: frameRenderer.newLine)

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

            soundio.flushEvents()
        }
    }
}

func toString(_ d: Double) -> String {
    return String(format: "%.0f", d)
}
