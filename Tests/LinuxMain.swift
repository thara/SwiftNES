import XCTest
import Quick

@testable import SwiftNESTests

QCKMain([
    AddressingSpec.self,
    CPUSpec.self,
    CPUAddressSpaceSpec.self,
    InstructionSpec.self,
    RegisterSpec.self,
])
