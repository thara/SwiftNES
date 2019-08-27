typealias Operand = UInt16
typealias NextPC = UInt16

typealias Operation = ((Operand) -> NextPC)

// http://obelisk.me.uk/6502/reference.html
enum Mnemonic {
    // MARK: - Load/Store Operations

    /// Load Accumulator
    case LDA
    /// Load X Register
    case LDX
    /// Load Y Register
    case LDY
    /// Store Accumulator
    case STA
    /// Store X Register
    case STX
    /// Store Y Register
    case STY

    // MARK: - Register Operations

    /// Transfer Accumulator to X
    case TAX
    /// Transfer Stack pointer to X
    case TSX
    /// Transfer Accumulator to Y
    case TAY
    /// Transfer X to Accumulator
    case TXA
    /// Transfer X to Stack pointer
    case TXS
    /// Transfer Y to Accumulator
    case TYA

    // MARK: - Stack instructions

    /// Push Accumulator
    case PHA
    /// Push Processor Status
    case PHP
    /// Pull Accumulator
    case PLA
    /// Pull Processor Status
    case PLP

    // MARK: - Logical instructions

    /// Logical AND
    case AND
    /// Exclusive OR
    case EOR
    /// Logical Inclusive OR
    case ORA
    /// Branch if Carry Clear
    case BIT

    // MARK: - Arithmetic instructions

    /// Add with Carry
    case ADC
    /// Subtract with Carry
    case SBC
    /// Compare
    case CMP
    /// Compare X Register
    case CPX
    /// Compare Y Register
    case CPY

    // MARK: - Increment/Decrement instructions

    /// Increment Memory
    case INC
    /// Increment X Register
    case INX
    /// Increment Y Register
    case INY
    /// Decrement Memory
    case DEC
    /// Decrement X Register
    case DEX
    /// Decrement Y Register
    case DEY

    // MARK: - Shift instructions

    /// Arithmetic Shift Left
    case ASL
    /// Logical Shift Right
    case LSR
    /// Rotate Left
    case ROL
    /// Rotate Right
    case ROR

    // MARK: - Jump instructions

    /// Jump
    case JMP
    /// Jump to Subroutine
    case JSR
    /// Return from Subroutine
    case RTS
    /// Return from Interrupt
    case RTI

    // MARK: - Branch instructions

    /// Branch if Carry Clear
    case BCC
    /// Branch if Carry Set
    case BCS
    /// Branch if Equal
    case BEQ
    /// Branch if Minus
    case BMI
    /// Branch if Not Equal
    case BNE
    /// Branch if Positive
    case BPL
    /// Branch if Overflow Clear
    case BVC
    /// Branch if Overflow Set
    case BVS

    // MARK: - Flag control instructions

    /// Clear Carry Flag
    case CLC
    /// Clear Decimal Mode
    case CLD
    /// Clear Interrupt Disable
    case CLI
    /// Clear Overflow Flag
    case CLV
    ///  Set Carry Flag
    case SEC
    ///  Set Decimal Flag
    case SED
    ///  Set Interrupt Disable
    case SEI

    // MARK: - Misc

    /// Force Interrupt
    case BRK
    /// No Operation
    case NOP

    // MARK: - Illegal

    /// Load Accumulator and X
    case LAX
    /// Store Accumulator and X
    case SAX
    /// DEC + CMP
    case DCP
    /// INC + SBC
    case ISB
    /// ASL + ORA
    case SLO
    /// ROL + AND
    case RLA
    /// LSR + EOR
    case SRE
    /// ROR + ADC
    case RRA
}
