import Core
import Foundation

public protocol GitHubAPIClientProtocol {
    func getRepositories() async throws -> [GitHubRepository]
    func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns
}

public final class GitHubAPIClient: GitHubAPIClientProtocol {
    public static let shared: GitHubAPIClient = .init(secureStorage: SecureStorage.shared)

    private let secureStorage: SecureStorageProtocol
    private let jsonDecoder: JSONDecoder

    private init(secureStorage: SecureStorageProtocol) {
        self.secureStorage = secureStorage

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder = jsonDecoder
    }

    public func getRepositories() async throws -> [GitHubRepository] {
        try await request(urlString: "https://api.github.com/user/repos?sort=updated_at", method: "GET")
    }

    public func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns {
        try await request(urlString: "https://api.github.com/repos/\(repository.owner.login)/\(repository.name)/actions/runs", method: "GET")
    }

    private func request<R: Codable>(urlString: String, method: String) async throws -> R {
        guard let token = secureStorage.getToken() else {
            throw GitHubAPIError.unauthorized
        }

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GitHubAPIError.disconnected
        }

        guard let response = response as? HTTPURLResponse else {
            throw GitHubAPIError.unexpectedError
        }
        switch response.statusCode {
        case 200 ..< 300:
            return try jsonDecoder.decode(R.self, from: data)
        case 401:
            try secureStorage.removeToken()
            throw GitHubAPIError.unauthorized
        default:
            throw GitHubAPIError.unexpectedError
        }
    }
}
