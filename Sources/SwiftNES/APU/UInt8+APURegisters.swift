// http://wiki.nesdev.com/w/index.php/APU_registers

// MARK: - for Pulse
extension UInt8 {

    @inline(__always)
    var dutyCycle: Int {
        return Int(self >> 6)
    }

    @inline(__always)
    var lengthCounterHalt: Bool {
        return self[5] == 1
    }

    @inline(__always)
    var constantVolumeFlag: Bool {
        return self[4] == 1
    }

    // Used as the volume in constant volume mode. Also used as the reload value for the envelope's divider.
    @inline(__always)
    var value: UInt8 {
        return self & 0b1111
    }
}

