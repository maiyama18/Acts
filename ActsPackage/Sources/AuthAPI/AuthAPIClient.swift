import Foundation

let authAPIURL = URL(string: "https://acts-api.herokuapp.com/code")!

public protocol AuthAPIClientProtocol {
    func fetchAccessToken(code: String) async throws -> String
}

public final class AuthAPIClient: AuthAPIClientProtocol {
    public static let shared: AuthAPIClient = .init()

    private init() {}

    public func fetchAccessToken(code: String) async throws -> String {
        var request = URLRequest(url: authAPIURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(AuthRequest(code: code))
        } catch {
            throw AuthAPIError.unexpectedError
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AuthAPIError.disconnected
        }

        guard let response = response as? HTTPURLResponse else {
            throw AuthAPIError.unexpectedError
        }
        guard response.statusCode == 200 else {
            let response: ErrorResponse
            do {
                response = try JSONDecoder().decode(ErrorResponse.self, from: data)
            } catch {
                throw AuthAPIError.unexpectedError
            }
            throw AuthAPIError.authFailed(message: response.message)
        }

        do {
            let response = try JSONDecoder().decode(AuthResponse.self, from: data)
            return response.token
        } catch {
            throw AuthAPIError.unexpectedError
        }
    }
}
