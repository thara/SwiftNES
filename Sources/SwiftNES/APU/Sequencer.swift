class Sequencer {

    var currentForm: [UInt8] = waveforms[0]
    var position: Int = 0

    func update(duty: Int) {
        currentForm = waveforms[duty]
    }

    func restart() {
        position = 0
    }

    func clock() {
        // next item is generated
        if position == 7 {
            position = 0
        } else {
            position &+= 1
        }
    }

    func gate(input: UInt16) -> UInt16 {
        if currentForm[position] == 0 {
            return 0
        } else {
            return input
        }
    }
}

let waveforms: [[UInt8]] = [
    [0, 1, 0, 0, 0, 0, 0, 0],  // 12.5%
    [0, 1, 1, 0, 0, 0, 0, 0],  // 25%
    [0, 1, 1, 1, 1, 0, 0, 0],  // 50%
    [1, 0, 0, 1, 1, 1, 1, 1]  // 25% negated
]
