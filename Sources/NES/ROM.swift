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
