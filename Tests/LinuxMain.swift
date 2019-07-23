import XCTest
import Quick

@testable import SwiftNESTests

QCKMain([
    AddressingModeSpec.self,
    CPUSpec.self,
    InstructionSpec.self,
    RegisterSpec.self,

    PPUSpec.self,
    PPUPortSpec.self,
    PPURegistersSpec.self,
    BackgroundSpec.self,
    ScrollingSpec.self,

    CPUBusSpec.self,

    NESFileSpec.self,
])
