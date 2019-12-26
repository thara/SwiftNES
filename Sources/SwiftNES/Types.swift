struct Console {
    var cpu = CPUState{}
    var ram = [UInt8]()
}

struct CPUState {
    /// Accumulator
    var A: UInt8 = 0x00
    /// Index register
    var X: UInt8 = 0x00
    /// Index register
    var Y: UInt8 = 0x00
    /// Stack pointer
    var S: UInt8 = 0xFF
    /// Status register
    var P: UInt8 = 0
    /// Program Counter
    var PC: UInt16 = 0x00
}
