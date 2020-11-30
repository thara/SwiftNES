import Foundation

import CSDL2
import Commander
import SDL

import NES

func run(_ closure: () throws -> Void) {
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
            try runEmulator(romPath: romPath)
        }
    }
}.run()
