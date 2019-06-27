import XCTest
import Quick

@testable import SwiftNESTests

QCKMain([
    AddressingSpec.self,
    CPUSpec.self,
    InstructionSpec.self,
    RegisterSpec.self,
    MemorySpec.self,
])
