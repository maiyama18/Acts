public enum AuthAPIError: Error {
    case unexpectedError
    case disconnected
    case authFailed(message: String)
}
