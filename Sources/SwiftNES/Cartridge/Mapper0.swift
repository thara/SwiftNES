final class Mapper0: Mapper {

    let program: [UInt8]
    let characterData: [UInt8]

    let mirroring: Mirroring

    let mirrored: Bool

    init(file: NESFile) {
        var next: Int
        (program, next) = file.readProgramROM(from: NESFileHeader.size, romSize: 0x4000)
        (characterData, _) = file.readCharacterROM(from: next, romSize: 0x2000)

        mirroring = file.header.flags6 & 1 == 0 ? .horizontal : .vertical

        mirrored = program.count == 0x4000
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return characterData[Int(address)]
        case 0x8000...0xBFFF:
            return program[prgAddress(address)]
        case 0xC000...0xFFFF:
            return program[prgAddress(address)]
        default:
            return 0x00
        }
    }

    func prgAddress(_ base: UInt16) -> Int {
        if mirrored {
            return Int(base % 0x4000)
        } else {
            return Int(base &- 0x8000)
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        //NOP
    }
}
