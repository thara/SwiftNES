protocol PPU {
    var ioRegister: PPUIORegister { get }

    func run(cycle: Int)

    func render()
}
