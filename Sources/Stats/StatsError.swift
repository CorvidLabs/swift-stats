/// Errors that can occur during statistical calculations
public enum StatsError: Error, Sendable {
    /// The input collection is empty
    case emptyCollection

    /// The input collection has insufficient data for the operation
    case insufficientData(required: Int, actual: Int)

    /// A calculation resulted in an invalid value (NaN or Inf)
    case invalidCalculation(String)

    /// The provided parameters are invalid
    case invalidParameters(String)

    /// Division by zero occurred
    case divisionByZero

    /// The matrix is singular and cannot be inverted
    case singularMatrix

    /// The regression failed to converge
    case convergenceFailure
}

extension StatsError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emptyCollection:
            return "Cannot perform operation on empty collection"
        case .insufficientData(let required, let actual):
            return "Insufficient data: requires \(required) elements, got \(actual)"
        case .invalidCalculation(let message):
            return "Invalid calculation: \(message)"
        case .invalidParameters(let message):
            return "Invalid parameters: \(message)"
        case .divisionByZero:
            return "Division by zero"
        case .singularMatrix:
            return "Singular matrix cannot be inverted"
        case .convergenceFailure:
            return "Failed to converge"
        }
    }
}
