import XCTest
import Quick

@testable import SwiftNESTests

QCKMain([
    NESFileSpec.self,
    SoundQueueSpec.self,

    // APU
    DividerSpec.self,
    EnvelopeGeneratorSpec.self,
    LengthCounterSpec.self,
    SequencerSpec.self,
    SweepUnitSpec.self,
    TimerSpec.self,

    // CPU
    AddressingModeSpec.self,
    CPUMemorySpec.self,
    InstructionSpec.self,
    CPUSpec.self,

    // Controller
    StandardControllerSpec.self,

    // Mappers
    Mapper0Spec.self,

    // PPU
    BackgroundSpec.self,
    PPUMemorySpec.self,
    PPUPortSpec.self,
    PPUSpec.self,
    PPURegistersSpec.self,
    ScanSpec.self,
    VRAMAddressSpec.self,
])
