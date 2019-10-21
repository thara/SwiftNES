import CSDL2
import SDL

import SwiftNES

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
        Int(SDL_SCANCODE_K.rawValue): StandardController.Button.A.rawValue
    ]
}
