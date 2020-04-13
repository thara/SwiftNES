import Commander
import Foundation
import Logging
import SwiftGD
import SwiftNES

let palletes: [UInt32] = [
    0x000000, 0x858585, 0xAAAAAA, 0xFFFFFF,
]

extension SwiftNES.Pattern {
    func write(at index: Int, to image: Image) {
        let offset = index * 8
        for (x, y, pixel) in toArray() {
            let argb = Int(palletes[pixel] | (0xFF << 24))
            image.set(pixel: Point(x: offset + x, y: y), to: Color(hex: argb, leadingAlpha: true))
        }
    }
}

command { (filename: String) in
    LoggingSystem.bootstrap(StreamLogHandler.standardOutput)

    let currentDirectory = URL(fileURLWithPath: FileManager().currentDirectoryPath)
    let destination = currentDirectory.appendingPathComponent("dist/sprites.png")

    do {
        _ = try? FileManager.default.removeItem(at: destination)

        let cartridge = try Cartridge(file: try NESFile(path: filename))
        let patterns = loadCharacterPattern(from: cartridge)
        print("Number of patterns: ", patterns.count)

        let image = Image(width: patterns.count * 8, height: 8)!
        patterns.enumerated().forEach { i, p in p.write(at: i, to: image) }
        image.write(to: destination)

        print("Dump complated at \(destination)")
    } catch let error as LocalizedError {
        print("Error: \(error.errorDescription ?? "unknown")")
        exit(EXIT_FAILURE)
    } catch {
        print("Error: \(error)")
        exit(EXIT_FAILURE)
    }
}.run()
