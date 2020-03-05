import NesSndEmuSwift
import SoundQueue

let outSize = 4096

class APU {
    let apu = NesApu()
    let buffer = BlipBuffer()

    var outBuffer = [Int16](repeating: 0, count: outSize)

    var frameCycles: Int = 0

    var soundQueue: SoundQueue?

    init() {
        buffer.formSampleRate(perSeconds: 96000)
        buffer.clockRate = 1789773

        apu.output(buffer: buffer)
    }

    func tick() {
        frameCycles &+= 1
    }

    func dmcReader(_ nes: NES) {
        apu.dmcReader(nes.dmcReader)
    }

    func reset() {
        apu.reset()
        buffer.clear()
    }

    func runFrame() {
        apu.endFrame(cpuTime: 29781)
        buffer.endFrame(29781)

        if outSize <= buffer.availableSamples {
            let count = buffer.readSamples(into: &outBuffer, until: outSize)
            soundQueue!.write(in: &outBuffer, count: Int32(count))
        }
        frameCycles = 0
    }
}

extension NES {
    func dmcReader(_ addr: UInt32) -> Int32 {
        return Int32(cpu.read(at: UInt16(addr)))
    }
}

extension APU: IOPort {
    func read(from address: UInt16) -> UInt8 {
        if address == 0x4015 {
            return UInt8(apu.readStatus(cpuTime: frameCycles))
        }
        return 0
    }

    func write(_ value: UInt8, to address: UInt16) {
        apu.writeRegister(cpuTime: frameCycles, cpuAddress: UInt32(address), data: Int32(value))
    }
}
