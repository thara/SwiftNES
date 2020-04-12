import CSDL2
import SDL

import SwiftNES

private let rowPixels = screenWidth
private let pitch = {
    rowPixels * MemoryLayout<UInt32>.stride
}()

private let safeAreaHeight = (NES.height &- screenHeight) / 2

final class SDLFrameRenderer {

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

    func newLine(number: Int, lineBuffer: inout LineBuffer) {
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

    static func printDriverInfo() {
        let renderDrivers = SDLRenderer.Driver.all
        if renderDrivers.isEmpty == false {
            print("=======")
            for driver in renderDrivers {
                do {
                    let info = try SDLRenderer.Info(driver: driver)
                    print("Driver: \(driver.rawValue)")
                    print("Name: \(info.name)")
                    print("Options:")
                    info.options.forEach { print("  \($0)") }
                    print("Formats:")
                    info.formats.forEach { print("  \($0)") }
                    if info.maximumSize.width > 0 || info.maximumSize.height > 0 {
                        print("Maximum Size:")
                        print("  Width: \(info.maximumSize.width)")
                        print("  Height: \(info.maximumSize.height)")
                    }
                    print("=======")
                } catch {
                    print("Could not get information for driver \(driver.rawValue)")
                }
            }
        }
    }
}
