import CSDL2
import SDL

import Logging

import SwiftNES

func main() throws {
    LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
    cpuLogger.logLevel = .debug
    ppuLogger.logLevel = .debug
    interruptLogger.logLevel = .debug

    let emulator = try Emulator(windowTitle: "SwiftNES", windowScale: 3)

    let path = "Tests/SwiftNESTests/fixtures/helloworld/sample1.nes"

    guard let cartridge = Cartridge(file: try NESFile(path: path)) else {
        fatalError("Unsupported mapper")
    }

    emulator.nes.insert(cartridge: cartridge)

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
