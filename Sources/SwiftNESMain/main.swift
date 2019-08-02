import CSDL2
import SDL

import Commander
import Logging

import SwiftNES

var mainLogger = Logger(label: "SwiftNESMain")

func main(_ romPath: String) throws {
    // cpuLogger.logLevel = .debug
    // ppuLogger.logLevel = .debug
    // interruptLogger.logLevel = .debug
    // mainLogger.logLevel = .debug

    let emulator = try Emulator(windowTitle: "SwiftNES", windowScale: 3)

    guard let cartridge = Cartridge(file: try NESFile(path: romPath)) else {
        fatalError("Unsupported mapper")
    }

    emulator.nes.insert(cartridge: cartridge)

    try emulator.runLoop()
}

command { (filename: String?) in
    LoggingSystem.bootstrap(StreamLogHandler.standardOutput)

#if nestest
    try SwiftNES.nestest(romPath: "Sources/SwiftNESMain/example/nestest/nestest.nes")
#else
    let romPath = filename ?? "Tests/SwiftNESTests/fixtures/helloworld/sample1.nes"
    do {
        try main(romPath)
    } catch let error as SDLError {
        print("Error: \(error.debugDescription)")
        exit(EXIT_FAILURE)
    } catch {
        print("Error: \(error)")
        exit(EXIT_FAILURE)
    }
#endif
}.run()
