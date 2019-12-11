infix operator |>: PipePrecedence

precedencegroup PipePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

func |> <T, U>(value: T, function: ((T) -> (U))) -> U {
    return function(value)
}
