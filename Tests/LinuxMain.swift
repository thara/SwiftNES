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

    DividerSpec.self,
    EnvelopeGeneratorSpec.self,
    LengthCounterSpec.self,
    SequencerSpec.self,
    SweepUnitSpec.self,
    TimerSpec.self,

    CPUMemoryMapSpec.self,
    PPUMemoryMapSpec.self,

    NESFileSpec.self,
])
