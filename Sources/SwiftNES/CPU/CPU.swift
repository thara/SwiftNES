struct OpCode {}
struct Instruction {}

protocol CPU {
    func fetch() -> OpCode
    func decode(_ opcode: OpCode) -> Instruction
    func execute(_ instraction: Instruction)
}

extension CPU {
    func run() {
        let opcode = fetch()
        let instruction = decode(opcode)
        execute(instruction)
    }
}
