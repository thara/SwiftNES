import CSDL2
import SDL

import SwiftNES

struct VirtualStandardController {
    let nesController: StandardController = StandardController()

    func press(down key: Int) {
        if let button = keyMap[key] {
            nesController.press(down: button)
        }
    }

    func press(up key: Int) {
        if let button = keyMap[key] {
            nesController.press(up: button)
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
