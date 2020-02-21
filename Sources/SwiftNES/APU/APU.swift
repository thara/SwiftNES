import NesSndEmuSwift

let outSize = 4096

class APU {
    let apu = NesApu()
    let buffer = BlipBuffer()

    var outBuffer = [Int16](repeating: 0, count: outSize)

    var soundQueue: SoundQueue?

    init() {
        buffer.formSampleRate(perSeconds: 96000)
        buffer.clockRate = 1789773

        apu.output(buffer: buffer)
    }

    func dmcReader(_ nes: NES) {
        apu.dmcReader(nes.dmcReader)
    }

    func reset() {
        apu.reset()
        buffer.clear()
    }

    func write(_ value: Int32, at addr: UInt16, elapsed: Int) {
        apu.writeRegister(cpuTime: elapsed, cpuAddress: UInt32(addr), data: value)
    }

    func read(at addr: UInt16, elapsed: Int) -> Int32 {
        if addr == 0x4015 {
            return apu.readStatus(cpuTime: elapsed)
        }
        return 0
    }

    func runFrame(elapsed: Int) {
        apu.endFrame(cpuTime: elapsed)
        buffer.endFrame(elapsed)

        if outSize <= buffer.availableSamples {
            let count = buffer.readSamples(into: &outBuffer, until: outSize)
            soundQueue?.write(&outBuffer, count: count)
        }
    }
}

extension NES {
    func dmcReader(_ addr: UInt32) -> Int32 {
        return Int32(cpu.read(at: UInt16(addr)))
    }
}
