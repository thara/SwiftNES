import XCTest
import Quick

@testable import SwiftNESTests

QCKMain([
    AddressingModeSpec.self,
    CPUSpec.self,
    CPUBusSpec.self,
    InstructionSpec.self,
    RegisterSpec.self,

    NESFileSpec.self,

    PPUPortSpec.self,
    PPUEmulatorSpec.self,
    PPURegistersSpec.self,
    BackgroundSpec.self,
    ScrollingSpec.self
])
