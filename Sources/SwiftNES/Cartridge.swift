public class Cartridge {
    private var rom = [UInt8](repeating: 0x00, count: 32767)

    private let mapper: Mapper

    public init?(file: NESFile) {
        switch file.header.mapperNo {
        case 0:
            mapper = Mapper0(file: file)
        default:
            return nil
        }
    }

    /// Read a byte at the given `address` on this cartridge
    func read(at address: UInt16) -> UInt8 {
        return mapper.read(at: address)
    }

    /// Write the given `value` at the `address` into this cartridge
    func write(_ value: UInt8, at address: UInt16) {
        mapper.write(value, at: address)
    }

    func load(rawData: [UInt8]) {
        rom = rawData
    }
}
