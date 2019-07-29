final class Mapper0: Mapper {

    let characterData: [UInt8]
    let program: [UInt8]

    init(file: NESFile) {
        characterData = Array(file.characterData)
        program = Array(file.program)
    }

    func read(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0000...0x1FFF:
            return characterData[Int(address)]
        case 0x8000...0xBFFF:
            return program[Int(address &- 0x8000)]
        case 0xC000...0xFFFF:
            return program[Int(address &- 0xC000)]
        default:
            return 0x00
        }
    }

    func write(_ value: UInt8, at address: UInt16) {
        //NOP
    }
}
