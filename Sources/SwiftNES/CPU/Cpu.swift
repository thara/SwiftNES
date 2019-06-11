struct OpCode {}
struct Instruction {}

protocol Cpu {
    func fetch() -> OpCode
    func decode(_ opcode: OpCode) -> Instruction
    func execute(_ instraction: Instruction)
}

extension Cpu {
    func run() {
        let opcode = fetch()
        let instruction = decode(opcode)
        execute(instruction)
    }
}
