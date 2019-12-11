// http://wiki.nesdev.com/w/index.php/APU_Length_Counter
class LengthCounter {

    var counter: Int = 0

    var enabled = false {
        didSet {
            if !enabled {
                counter = 0
            }
        }
    }

    var halt = false

    func clock() {
        if counter != 0 && !halt {
            counter &-= 1
        }
    }

    func reload(by value: UInt8) {
        if enabled {
            counter = lookupLength(value)
        }
    }

    func gate(input: UInt16) -> UInt16 {
        if enabled {
            return input
        } else {
            return 0
        }
    }
}

private func lookupLength(_ bitPattern: UInt8) -> Int {
    let tableIndex = Int(bitPattern & 0b11110000 >> 4)
    let lengthIndex = Int(bitPattern[3])
    return lookupTable[tableIndex][lengthIndex]
}

private let lookupTable = [
    [0x0A, 0xFE],
    [0x14, 0x02],
    [0x28, 0x04],
    [0x50, 0x06],
    [0xA0, 0x08],
    [0x3C, 0x0A],
    [0x0E, 0x0C],
    [0x1A, 0x0E],
    [0x0C, 0x10],
    [0x18, 0x12],
    [0x30, 0x14],
    [0x60, 0x16],
    [0xC0, 0x18],
    [0x48, 0x1A],
    [0x10, 0x1C],
    [0x20, 0x1E]
]
