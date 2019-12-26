// swiftlint:disable file_length

func LDA(inout console: Console) {
    console.cpu.A = read(at: operand)
    return registers.PC
}
