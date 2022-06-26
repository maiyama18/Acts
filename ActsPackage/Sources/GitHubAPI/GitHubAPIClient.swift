import Core
import Foundation
import ZIPFoundation

public protocol GitHubAPIClientProtocol {
    func getUsersRepositories(page: Int) async throws -> [GitHubRepositoryResponse]
    func getWorkflowRuns(repositoryFullName: String) async throws -> GitHubWorkflowRunsResponse
    func getWorkflowRun(repositoryFullName: String, runId: Int) async throws -> GitHubWorkflowRunResponse
    func getWorkflowJobs(url: String) async throws -> GitHubWorkflowJobsResponse
    func getWorkflowJobLog(logsUrl: String, jobName: String) async throws -> [Int: String]
    func rerunWorkflow(url: String) async throws
    func cancelWorkflow(url: String) async throws
}

public final class GitHubAPIClient: GitHubAPIClientProtocol {
    public static let shared: GitHubAPIClient = .init(secureStorage: SecureStorage.shared)

    private let secureStorage: SecureStorageProtocol
    private let jsonDecoder: JSONDecoder = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "invalid date formatted: \(dateStr)")
        }

        return jsonDecoder
    }()

    private init(secureStorage: SecureStorageProtocol) {
        self.secureStorage = secureStorage
    }

    public func getUsersRepositories(page: Int) async throws -> [GitHubRepositoryResponse] {
        try await request(urlString: "https://api.github.com/user/repos?sort=updated_at&page=\(page)", method: "GET")
    }

    public func getWorkflowRuns(repositoryFullName: String) async throws -> GitHubWorkflowRunsResponse {
        try await request(urlString: "https://api.github.com/repos/\(repositoryFullName)/actions/runs", method: "GET")
    }

    public func getWorkflowRun(repositoryFullName: String, runId: Int) async throws -> GitHubWorkflowRunResponse {
        try await request(urlString: "https://api.github.com/repos/\(repositoryFullName)/actions/runs/\(runId)", method: "GET")
    }

    public func getWorkflowJobs(url: String) async throws -> GitHubWorkflowJobsResponse {
        try await request(urlString: url, method: "GET")
    }

    public func getWorkflowJobLog(logsUrl: String, jobName: String) async throws -> [Int: String] {
        let zipFileURL = try await download(urlString: logsUrl)
        let destinationDirectoryURL = URL(
            fileURLWithPath: NSTemporaryDirectory().appending("logs-\(Date().timeIntervalSince1970)"),
            isDirectory: true
        )

        let fileManager = FileManager.default
        try fileManager.createDirectory(
            at: destinationDirectoryURL,
            withIntermediateDirectories: true
        )
        try fileManager.unzipItem(at: zipFileURL, to: destinationDirectoryURL)
        defer {
            try? fileManager.removeItem(at: destinationDirectoryURL)
        }

        let jobLogsURL = destinationDirectoryURL.appendingPathComponent(jobName)
        var stepLogs: [Int: String] = [:]
        for stepLogFile in try fileManager.contentsOfDirectory(at: jobLogsURL, includingPropertiesForKeys: nil) {
            guard let stepNumberString = stepLogFile.lastPathComponent.split(separator: "_").first,
                  let stepNumber = Int(stepNumberString)
            else {
                logger.notice("Failed to parse step number for file \(stepLogFile.absoluteString, privacy: .public)")
                continue
            }

            do {
                let logData = try Data(contentsOf: stepLogFile)
                guard let log = String(data: logData, encoding: .utf8) else {
                    throw GitHubAPIError.unexpectedError
                }

                stepLogs[stepNumber] = log
            } catch {
                logger.notice("Failed to read file \(stepLogFile.absoluteString, privacy: .public)")
                throw GitHubAPIError.unexpectedError
            }
        }
        return stepLogs
    }

    public func rerunWorkflow(url: String) async throws {
        try await complete(urlString: url, method: "POST")
    }

    public func cancelWorkflow(url: String) async throws {
        try await complete(urlString: url, method: "POST")
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

    private func complete(urlString: String, method: String) async throws {
        guard let token = secureStorage.getToken() else {
            throw GitHubAPIError.unauthorized
        }

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")

        let response: URLResponse
        do {
            (_, response) = try await URLSession.shared.data(for: request)
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
            return
        case 401:
            logger.notice("GitHub request unauthorized")
            try secureStorage.removeToken()
            throw GitHubAPIError.unauthorized
        default:
            logger.notice("GitHub request failed: \(response.debugDescription)")
            throw GitHubAPIError.unexpectedError
        }
    }

    private func download(urlString: String) async throws -> URL {
        guard let token = secureStorage.getToken() else {
            throw GitHubAPIError.unauthorized
        }

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")

        let url: URL
        let response: URLResponse
        do {
            (url, response) = try await URLSession.shared.download(for: request)
        } catch {
            logger.notice("URLSession.download failed: \(error.localizedDescription)")
            throw GitHubAPIError.disconnected
        }

        guard let response = response as? HTTPURLResponse else {
            logger.notice("Response conversion failed")
            throw GitHubAPIError.unexpectedError
        }
        switch response.statusCode {
        case 200 ..< 300:
            return url
        case 401:
            logger.notice("GitHub request unauthorized")
            try secureStorage.removeToken()
            throw GitHubAPIError.unauthorized
        case 404:
            throw GitHubAPIError.notFound
        default:
            logger.notice("GitHub request failed: \(response.debugDescription)")
            throw GitHubAPIError.unexpectedError
        }
    }
}
