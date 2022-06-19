struct AuthRequest: Codable {
    var code: String

    init(code: String) {
        self.code = code
    }
}

struct AuthResponse: Codable {
    var token: String
}

struct ErrorResponse: Codable {
    var message: String
}
