import XCTest
import Quick

@testable import SwiftNESTests

QCKMain([
    AddressingModeSpec.self,
    CPUSpec.self,
    InstructionSpec.self,
    CPURegisterSpec.self,

    PPUSpec.self,
    PPUPortSpec.self,
    PPURegistersSpec.self,
    BackgroundSpec.self,

    CPUMemoryMapSpec.self,
    PPUMemoryMapSpec.self,

    NESFileSpec.self,
])
