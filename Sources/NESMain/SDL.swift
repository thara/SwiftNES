import CSDL2
import SDL
import NES

let windowTitle = "SwiftNES"
let windowScale = 3

let screenWidth = NES.width
let screenHeight = 224

func runEmulator(romPath: String) throws {
    try SDL.initialize(subSystems: [.video, .audio])
    defer {
        SDL.quit()
    }

    let windowSize = (
        width: screenWidth * windowScale,
        height: screenHeight * windowScale
    )
    let window = try SDLWindow(
        title: windowTitle,
        frame: (
            x: .centered,
            y: .centered,
            width: windowSize.width,
            height: windowSize.height
        ),
        options: [.shown, .inputFocus])

    let driver = SDLRenderer.Driver.default
    let renderer = try SDLRenderer(window: window, driver: driver, options: [.accelerated, .presentVsync])
    try renderer.setLogicalSize(width: Int32(windowSize.width), height: Int32(windowSize.height))

    let screenRect = SDL_Rect(x: 0, y: 0, w: Int32(windowSize.width), h: Int32(windowSize.height))

    let controller = VirtualStandardController()

    let rom = try ROM(file: try NESFile(path: romPath))

    let frameRenderer = try SDLFrameRenderer(renderer: renderer, screenRect: screenRect)
    let audioBuffer = SDLAudioBuffer(sampleRate: 44100, channels: 1, bufferSize: 4096)

    let nes = SwiftNES(lineRenderer: frameRenderer, audioBuffer: audioBuffer)
    nes.connect(controller1: controller.nesController, controller2: nil)
    nes.insert(cartridge: rom)

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

    var event = SDL_Event()
    var isRunning = true

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

        nes.runFrame()

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

struct VirtualStandardController {
    let nesController: StandardController = StandardController()

    func update(keys: UnsafeBufferPointer<UInt8>) {
        var state: UInt8 = 0
        for (scancode, button) in self.keys where 0 < keys[scancode] {
            state |= button
        }
        nesController.update(button: StandardController.Button(rawValue: state))
    }

    let keys: [Int: UInt8] = [
        Int(SDL_SCANCODE_W.rawValue): StandardController.Button.up.rawValue,
        Int(SDL_SCANCODE_A.rawValue): StandardController.Button.left.rawValue,
        Int(SDL_SCANCODE_S.rawValue): StandardController.Button.down.rawValue,
        Int(SDL_SCANCODE_D.rawValue): StandardController.Button.right.rawValue,

        Int(SDL_SCANCODE_LSHIFT.rawValue): StandardController.Button.start.rawValue,
        Int(SDL_SCANCODE_LCTRL.rawValue): StandardController.Button.select.rawValue,

        Int(SDL_SCANCODE_J.rawValue): StandardController.Button.B.rawValue,
        Int(SDL_SCANCODE_K.rawValue): StandardController.Button.A.rawValue,
    ]
}

private let rowPixels = screenWidth
private let pitch = {
    rowPixels * MemoryLayout<UInt32>.stride
}()

private let safeAreaHeight = (NES.height &- screenHeight) / 2

final class SDLFrameRenderer: LineRenderer {

    private let renderer: SDLRenderer
    private let screenRect: SDL_Rect
    private let frameTexture: SDLTexture

    private var frameBuffer: [UInt32]

    private var line = 0

    public enum RenderingMode {
        case prioring, backgroundOnly, spriteOnly
    }
    private let renderingMode: RenderingMode

    init(renderer: SDLRenderer, screenRect: SDL_Rect, renderingMode: RenderingMode = .prioring) throws {
        self.renderer = renderer
        self.screenRect = screenRect
        self.renderingMode = renderingMode

        frameTexture = try SDLTexture(
            renderer: renderer, format: .argb8888, access: .streaming, width: screenWidth, height: screenHeight
        )

        frameBuffer = [UInt32](repeating: 0x00, count: rowPixels * screenHeight)
    }

    func rednerLine(at number: Int, by lineBuffer: inout LineBuffer) {
        switch renderingMode {
        case .prioring:
            newLine(number: number, pixels: lineBuffer.buffer)
        case .backgroundOnly:
            newLine(number: number, pixels: lineBuffer.backgroundBuffer)
        case .spriteOnly:
            newLine(number: number, pixels: lineBuffer.spriteBuffer)
        }
    }

    func newLine(number: Int, pixels: [UInt32]) {
        switch number {
        case 0..<safeAreaHeight:
            // in top safe area
            break
        case (NES.height &- safeAreaHeight)...Int.max:
            // in bottom safe area
            if NES.maxLine <= line {
                line = 0
                render()
            }
        default:
            let row = number &- safeAreaHeight

            let start = row * rowPixels
            let end = (row + 1) * rowPixels
            frameBuffer[start..<end] = pixels[..<rowPixels]

            line &+= 1
        }
    }

    func render() {
        do {
            let p = frameBuffer.withUnsafeBufferPointer { $0.baseAddress! }
            try frameTexture.update(pixels: UnsafeMutableRawPointer(mutating: p), pitch: pitch)

            // background
            try renderer.setDrawColor(red: 0x00, green: 0x00, blue: 0x00, alpha: 0xFF)

            try renderer.clear()
            try renderer.copy(frameTexture, destination: screenRect)
            renderer.present()
        } catch {
            print("Error: \(error)")
        }
    }
}

func toString(_ d: Double) -> String {
    return String(format: "%.0f", d)
}

let bufferCount: UInt32 = 3

class SDLAudioBuffer: AudioBuffer {

    var samples = [Float](repeating: 0.0, count: 4096 * 2)
    var index: Int = 0
    var prev: Float = 0.0

    var audioSpec = SDLAudioSpec()

    init(sampleRate: Int32, channels: UInt8, bufferSize: UInt16) {
        audioSpec.freq = sampleRate
        audioSpec.format = UInt16(AUDIO_F32LSB)
        audioSpec.channels = channels
        audioSpec.silence = 0
        audioSpec.samples = bufferSize
        audioSpec.size = 0

        audioSpec.setCallback(userdata: self) { (buf, samples, count) in
            buf.fill(into: samples, count: count)
        }
    }

    func write(_ sample: Float) {
        guard index < samples.count else {
            return
        }

        samples[index] = sample
        index &+= 1
    }

    func fill(into buffer: UnsafeMutablePointer<UInt8>, count: Int32) {
        let bufferCount = Int(count) / MemoryLayout<Float>.size

        buffer.withMemoryRebound(to: Float.self, capacity: bufferCount) { p in
            var p = p

            var writeIndex = 0
            for _ in 0..<bufferCount {
                let sample: Float
                if self.index <= writeIndex {
                    sample = prev
                } else {
                    sample = samples[writeIndex]
                }

                p.pointee = sample
                p += 1

                prev = sample
                writeIndex &+= 1
            }

            var index = 0
            if bufferCount < index {
                for i in stride(from: bufferCount, to: index, by: 1) {
                    samples[index] = samples[i]
                    index &+= 1
                }
            }
            self.index = index
        }
    }
}
