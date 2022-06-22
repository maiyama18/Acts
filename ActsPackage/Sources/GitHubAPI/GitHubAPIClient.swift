import Core
import Foundation

public protocol GitHubAPIClientProtocol {
    func getRepositories() async throws -> [GitHubRepository]
    func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns
    func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs
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

    public func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs {
        try await request(urlString: workflowRun.jobsUrl, method: "GET")
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
            logger.notice("URLSession.data failed: \(error.localizedDescription)")
            throw GitHubAPIError.disconnected
        }

        guard let response = response as? HTTPURLResponse else {
            logger.notice("Response conversion failed")
            throw GitHubAPIError.unexpectedError
        }
        switch response.statusCode {
        case 200 ..< 300:
            do {
                return try jsonDecoder.decode(R.self, from: data)
            } catch {
                logger.notice("GitHub response parse failed: \(String(describing: error))")
                throw GitHubAPIError.unexpectedError
            }
        case 401:
            logger.notice("GitHub request unauthorized")
            try secureStorage.removeToken()
            throw GitHubAPIError.unauthorized
        default:
            logger.notice("GitHub request failed: \(response.debugDescription)")
            throw GitHubAPIError.unexpectedError
        }
    }
}
