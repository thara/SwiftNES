import Logging

public var cpuLogger = Logger(label: "SwiftNES.CPU")

public var ppuLogger = Logger(label: "SwiftNES.PPU")
public var ppuBusLogger = Logger(label: "SwiftNES.PPUBus")
public var ppuBackgroundLogger = Logger(label: "SwiftNES.Background")

public var interruptLogger = Logger(label: "SwiftNES.Interrupt")
