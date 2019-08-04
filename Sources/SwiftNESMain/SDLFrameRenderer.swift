import CSDL2
import SDL

import SwiftNES

let rowPixels = NES.width

final class SDLFrameRenderer: Renderer {

    private let renderer: SDLRenderer

    private let screenRect: SDL_Rect

    private let frameTexture: SDLTexture

    private var frameBuffer: [UInt32]

    private var line = 0

    private let pitch = rowPixels * MemoryLayout<UInt32>.stride

    init(renderer: SDLRenderer, screenRect: SDL_Rect) throws {
        self.renderer = renderer
        self.screenRect = screenRect

        frameTexture = try SDLTexture(
            renderer: renderer, format: .argb8888, access: .streaming, width: 256, height: 240
        )

        frameBuffer = [UInt32](repeating: 0x00, count: 256 * 240)
    }

    func newLine(number: Int, pixels: [UInt32]) {
        guard number < NES.height else {
            return
        }
        frameBuffer[(number * rowPixels)..<((number + 1) * rowPixels)] = pixels[..<rowPixels]
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
            // try frameRenderer.setDrawColor(red: 0x00, green: 0x00, blue: 0x00, alpha: 0xFF)
            //FIXME for test
            try renderer.setDrawColor(red: 0x85, green: 0x19, blue: 0x19, alpha: 0xFF)

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
