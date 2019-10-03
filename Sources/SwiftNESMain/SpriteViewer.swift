import CSDL2
import SDL

import SwiftNES

final class SpriteViewer {
    private let window: SDLWindow

    init(windowScale: Int) throws {
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
        let driver = SDLRenderer.Driver.default

        let renderer = try SDLRenderer(window: window, driver: driver, options: [.accelerated, .presentVsync])
        renderer.setLogicalSize(w: Int32(windowSize.width), h: Int32(windowSize.height))

        let screenRect = SDL_Rect(x: 0, y: 0, w: Int32(windowSize.width), h: Int32(windowSize.height))
    }
}
