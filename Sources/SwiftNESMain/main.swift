import Foundation

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
    try emulator.loadNESFile(path: romPath)
    try emulator.runLoop()
}

command { (filename: String?) in
    LoggingSystem.bootstrap(StreamLogHandler.standardOutput)

    do {
#if nestest
        try SwiftNES.nestest(romPath: filename ?? "nestest.nes")
#else
        let romPath = filename ?? "Tests/SwiftNESTests/fixtures/helloworld/sample1.nes"
        try main(romPath)
#endif
    } catch let error as SDLError {
        print("Error: \(error.debugDescription)")
        exit(EXIT_FAILURE)
    } catch let error as LocalizedError {
        print("Error: \(error.errorDescription ?? "unknown")")
        exit(EXIT_FAILURE)
    } catch {
        print("Error: \(error)")
        exit(EXIT_FAILURE)
    }
}.run()
