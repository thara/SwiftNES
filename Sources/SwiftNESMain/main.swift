import Foundation

import CSDL2
import SDL

import Commander
import Logging

import SwiftNES

var mainLogger = Logger(label: "SwiftNESMain")

func run(_ closure: () throws -> Void) {
    LoggingSystem.bootstrap(StreamLogHandler.standardOutput)

    do {
        try closure()
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
}

Group {
    $0.command("run") { (romPath: String) in
        run {
            let emulator = try Emulator(windowTitle: "SwiftNES", windowScale: 3)
            try emulator.loadNESFile(path: romPath)
            try emulator.runLoop()
        }
    }

#if nestest
    $0.command("nestest") { (romPath: String?) in
        run {
            try SwiftNES.nestest(romPath: romPath ?? "nestest.nes")
        }
    }
#endif
}.run()
