import CSDL2
import SDL

import SwiftNES

func main() throws {
    let emulator = try Emulator(windowTitle: "SwiftNES", windowScale: 3)

    let path = "Tests/SwiftNESTests/fixtures/helloworld/sample1.nes"

    let cartridge = Cartridge(file: try NESFile(path: path))
    emulator.nes.cartridgeDrive.insert(cartridge)

    try emulator.runLoop()
}

do {
    try main()
} catch let error as SDLError {
    print("Error: \(error.debugDescription)")
    exit(EXIT_FAILURE)
} catch {
    print("Error: \(error)")
    exit(EXIT_FAILURE)
}
