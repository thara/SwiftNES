import Quick
import XCTest

@testable import SwiftNESTests

QCKMain([
    NESFileSpec.self,
    SoundQueueSpec.self,

    // APU
    PulseSpec.self,

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
