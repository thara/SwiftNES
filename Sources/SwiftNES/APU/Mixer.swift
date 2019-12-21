// https://wiki.nesdev.com/w/index.php/APU_Mixer
struct Mixer {
    let pulseLookupTable: [Double]

    init() {
        var pulseLookupTable = [Double](repeating: 0, count: 31)
        for n in 0..<pulseLookupTable.count {
            pulseLookupTable[n] = 95.52 / (8128.0 / Double(n) + 100)
        }
        self.pulseLookupTable = pulseLookupTable
    }

    func mix(pulse1: UInt16, pulse2: UInt16) -> Double {
        return pulseLookupTable[Int(pulse1 + pulse2)]
    }
}
