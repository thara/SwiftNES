import Foundation

fileprivate extension FileHandle {
    func readBytes(ofLength length: Int) -> [UInt8] {
        let data = readData(ofLength: length)
        return [UInt8](data)
    }
}

public struct NESFile {
    let header: NESFileHeader
    let bytes: [UInt8]

    public init(path: String, bufferSize: Int = 1024) throws {
        if let f = FileHandle(forReadingAtPath: path) {
            defer {
                f.closeFile()
            }
            bytes = [UInt8](f.readDataToEndOfFile())

            let headerData = bytes[0..<NESFileHeader.size]
            if headerData.count < NESFileHeader.size {
                throw NESFileError.notEnoughHeaderSize(size: headerData.count)
            }
            header = NESFileHeader(bytes: [UInt8](headerData))
            guard header.valid() else {
                throw NESFileError.invalidHeader(bytes: Array(headerData))
            }
        } else {
            throw NESFileError.cannotOpenStream(path: path)
        }
    }

    func readBytes(from first: Int, count: Int) -> ([UInt8], Int) {
        let last = first + count
        return (Array(bytes[first..<last]), last)
    }

    func readProgramROM(from first: Int, romSize: Int) -> ([UInt8], Int) {
        return readBytes(from: first, count: header.programROMSizeOfUnit * romSize)
    }

    func readCharacterROM(from first: Int, romSize: Int) -> ([UInt8], Int) {
        return readBytes(from: first, count: header.characterROMSizeOfUnit * romSize)
    }
}

struct NESFileHeader {
    let magic: [UInt8]
    let programROMSizeOfUnit: Int
    let characterROMSizeOfUnit: Int
    let flags6: UInt8
    let flags7: UInt8
    let flags8: UInt8
    let flags9: UInt8
    let flags10: UInt8
    let padding: [UInt8]

    let rowData: [UInt8]

    init(bytes: [UInt8]) {
        magic = Array(bytes[0...3])
        programROMSizeOfUnit = Int(bytes[4])
        characterROMSizeOfUnit = Int(bytes[5])
        flags6 = bytes[6]
        flags7 = bytes[7]
        flags8 = bytes[8]
        flags9 = bytes[9]
        flags10 = bytes[10]
        padding = Array(bytes[11..<bytes.count])
        rowData = bytes
    }

    func valid() -> Bool {
        return magic == NESFileHeader.magicNumber && padding == NESFileHeader.padding
    }

    var mapperNo: UInt8 {
        return (flags7 & 0b11110000) + (flags6 >> 4)
    }

    var prgRAMSize: UInt8 {
        return flags8
    }

    static let magicNumber: [UInt8] = [0x4E, 0x45, 0x53, 0x1A]
    static let padding = [UInt8](repeating: 0x00, count: 5)

    static let size = 16
}

enum NESFileError: Error {
    case cannotOpenStream(path: String)
    case notEnoughHeaderSize(size: Int)
    case invalidHeader(bytes: [UInt8])
}

extension NESFileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cannotOpenStream(let path):
            return "Can not open file : path=\(path)"
        case .notEnoughHeaderSize(let size):
            return "Not enough header size : expected=16, actual=\(size)"
        case .invalidHeader(let bytes):
            return "Invalid header: bytes=\(bytes)"
        }
    }
}
