import CSDL2
import SDL

import SwiftNES

private let rowPixels = NES.width
private let pitch = {
    rowPixels * MemoryLayout<UInt32>.stride
}()

final class SDLFrameRenderer: Renderer {

    private let renderer: SDLRenderer
    private let screenRect: SDL_Rect
    private let frameTexture: SDLTexture

    private var frameBuffer: [UInt32]

    private var line = 0

    init(renderer: SDLRenderer, screenRect: SDL_Rect) throws {
        self.renderer = renderer
        self.screenRect = screenRect

        frameTexture = try SDLTexture(
            renderer: renderer, format: .argb8888, access: .streaming, width: NES.width, height: NES.height
        )

        frameBuffer = [UInt32](repeating: 0x00, count: NES.width * NES.height)
    }

    func newLine(number: Int, pixels: [UInt32]) {
        guard number < NES.height else {
            return
        }

        let start = number * rowPixels
        let end = (number + 1) * rowPixels
        frameBuffer[start..<end] = pixels[..<rowPixels]

        line &+= 1

        if NES.maxLine <= line {
            line = 0
            render()
        }
    }

    func render() {
        do {
            let p = UnsafePointer(frameBuffer)
            try frameTexture.update(pixels: UnsafeMutablePointer(mutating: p), pitch: pitch)

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
