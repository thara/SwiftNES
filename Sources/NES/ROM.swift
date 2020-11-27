import Foundation

public final class ROM {
    let mapper: Mapper

    init(mapper: Mapper) {
        self.mapper = mapper
    }

    public init(file: NESFile) throws {
        switch file.header.mapperNo {
        case 0:
            mapper = Mapper0(file: file)
        default:
            throw MapperError.unsupportedMapper(no: file.header.mapperNo)
        }
    }

    /// Read a byte at the given `address` on this ROM
    func read(at address: UInt16) -> UInt8 {
        return mapper.read(at: address)
    }

    /// Write the given `value` at the `address` into this ROM
    func write(_ value: UInt8, at address: UInt16) {
        mapper.write(value, at: address)
    }
}

enum MapperError: Error {
    case unsupportedMapper(no: UInt8)
}

extension MapperError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unsupportedMapper(let no):
            return "Unsupported mapper: no=\(no)"
        }
    }
}

protocol Mapper: class {

    var program: [UInt8] { get }
    var characterData: [UInt8] { get }

    /// Read a byte at the given `address`
    func read(at address: UInt16) -> UInt8
    /// Write the given `value` at the `address`
    func write(_ value: UInt8, at address: UInt16)

    var mirroring: Mirroring { get }
}
