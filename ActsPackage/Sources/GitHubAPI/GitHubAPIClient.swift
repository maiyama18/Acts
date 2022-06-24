import Core
import Foundation
import ZIPFoundation

public protocol GitHubAPIClientProtocol {
    func getRepositories() async throws -> [GitHubRepository]
    func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns
    func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs
    func getWorkflowJobsLog(logsUrl: String, maxLines: Int) async throws -> [String: GitHubWorkflowJobLog]
    func rerunWorkflow(workflowRun: GitHubWorkflowRun) async throws
    func cancelWorkflow(workflowRun: GitHubWorkflowRun) async throws
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

    public func getRepositories() async throws -> [GitHubRepository] {
        try await request(urlString: "https://api.github.com/user/repos?sort=updated_at", method: "GET")
    }

    public func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns {
        try await request(urlString: "https://api.github.com/repos/\(repository.owner.login)/\(repository.name)/actions/runs", method: "GET")
    }

    public func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs {
        try await request(urlString: workflowRun.jobsUrl, method: "GET")
    }

    public func getWorkflowJobsLog(logsUrl: String, maxLines: Int) async throws -> [String: GitHubWorkflowJobLog] {
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

        var jobLogs: [String: GitHubWorkflowJobLog] = [:]
        for jobDirectory in try fileManager.subDirectoriesOfDirectory(at: destinationDirectoryURL) {
            let jobName = jobDirectory.lastPathComponent
            let stepLogFiles = try fileManager.contentsOfDirectory(
                at: jobDirectory,
                includingPropertiesForKeys: nil
            )

            var stepLogs: [GitHubWorkflowStepLog] = []
            for stepLogFile in stepLogFiles {
                guard let stepNumberString = stepLogFile.lastPathComponent.split(separator: "_").first,
                      let stepNumber = Int(stepNumberString)
                else {
                    logger.notice("Failed to parse step number for file \(stepLogFile.absoluteString, privacy: .public)")
                    throw GitHubAPIError.unexpectedError
                }

                do {
                    let logData = try Data(contentsOf: stepLogFile)
                    guard let log = String(data: logData, encoding: .utf8) else {
                        throw GitHubAPIError.unexpectedError
                    }

                    let lines = log.reduce(into: 0) { count, letter in
                        if letter == "\r\n" { count += 1 }
                    }

                    let processedLog = log
                        .split(separator: "\r\n")
                        .suffix(100)
                        .map { line -> String in
                            let components = line.split(separator: " ")
                            if components.count <= 1 {
                                return String(line)
                            } else {
                                return components.dropFirst().joined(separator: " ")
                            }
                        }
                        .joined(separator: "\r\n")
                        .replacingOccurrences(of: "##[group]", with: "> ")
                        .replacingOccurrences(of: "##[endgroup]", with: "")

                    stepLogs.append(.init(stepNumber: stepNumber, log: processedLog, abbreviated: lines > maxLines))
                } catch {
                    logger.notice("Failed to read file \(stepLogFile.absoluteString, privacy: .public)")
                    throw GitHubAPIError.unexpectedError
                }
            }
            jobLogs[jobName] = GitHubWorkflowJobLog(stepLogs: stepLogs)
        }
        return jobLogs
    }

    public func rerunWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await complete(urlString: workflowRun.rerunUrl, method: "POST")
    }

    public func cancelWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await complete(urlString: workflowRun.cancelUrl, method: "POST")
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
        default:
            logger.notice("GitHub request failed: \(response.debugDescription)")
            throw GitHubAPIError.unexpectedError
        }
    }
}
