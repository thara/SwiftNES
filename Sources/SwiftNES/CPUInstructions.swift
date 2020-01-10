// swiftlint:disable file_length, large_tuple

typealias OperationFunc = (inout NESState, AddressingModeFunc) -> Void

struct CPUInstruction {
    var opcode: UInt8
    var addressingMode: AddressingModeFunc
    var operation: OperationFunc
    var bytes: UInt8
    var cycles: UInt8
}

func buildInstructionTable() -> [CPUInstruction] {
    let instructionTable: [(OperationFunc, AddressingModeFunc, UInt8, UInt8, UInt8)] = [
        (LDA, immediate, 0xA9, 2, 2),
        (LDA, zeroPage, 0xA5, 2, 3),
        (LDA, zeroPageX, 0xB5, 2, 4),
        (LDA, absolute, 0xAD, 3, 4),
        (LDA, absoluteXWithPenalty, 0xBD, 3, 4),
        (LDA, absoluteYWithPenalty, 0xB9, 3, 4),
        (LDA, indexedIndirect, 0xA1, 2, 6),
        (LDA, indirectIndexed, 0xB1, 2, 5)
    ]

    var table: [CPUInstruction?] = Array(repeating: nil, count: 0x100)
    for (operation, addressingMode, opcode, bytes, cycles) in instructionTable {
        table[Int(opcode)] = CPUInstruction(opcode: opcode, addressingMode: addressingMode, operation: operation, bytes: bytes, cycles: cycles)
    }
    return table.compactMap { $0 }
}

func NOP(nes: inout NESState, addressingMode operand: AddressingModeFunc) {
    // nop
}

func LDA(nes: inout NESState, addressingMode operand: AddressingModeFunc) {
    nes.cpu.A = read(at: operand(&nes), from: &nes)
}
