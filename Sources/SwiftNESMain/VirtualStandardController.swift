import CSDL2
import SDL

import SwiftNES

struct VirtualStandardController {
    let nesController: StandardController = StandardController()

    func press(key: Int) {
        mainLogger.info("Press \(key)")

        if let button = keyMap[key] {
            nesController.press(button: button)
        }
    }

    let keyMap: [Int: StandardController.Button] = [
        SDLK_w: .up,
        SDLK_a: .left,
        SDLK_s: .down,
        SDLK_d: .right,
        SDLK_LSHIFT: .start,
        SDLK_LCTRL: .select,
        SDLK_j: .B,
        SDLK_k: .A
    ]
}
