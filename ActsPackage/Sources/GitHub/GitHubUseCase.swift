import Core
import GitHubAPI

public protocol GitHubUseCaseProtocol {
    func getRepositories() async throws -> [GitHubRepository]
    func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns
    func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs
    func getWorkflowJobsLog(workflowRun: GitHubWorkflowRun, jobNames: [String], maxLines: Int) async throws -> [String: GitHubWorkflowJobLog]
    func rerunWorkflow(workflowRun: GitHubWorkflowRun) async throws
    func cancelWorkflow(workflowRun: GitHubWorkflowRun) async throws
}

public final class GitHubUseCase: GitHubUseCaseProtocol {
    public static let shared: GitHubUseCase = .init(
        apiClient: GitHubAPIClient.shared,
        cacheClient: CacheClient.shared
    )

    private let apiClient: GitHubAPIClientProtocol
    private let cacheClient: CacheClientProtocol

    private init(apiClient: GitHubAPIClientProtocol, cacheClient: CacheClientProtocol) {
        self.apiClient = apiClient
        self.cacheClient = cacheClient
    }

    public func getRepositories() async throws -> [GitHubRepository] {
        try await apiClient.getRepositories()
    }

    public func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns {
        try await apiClient.getWorkflowRuns(repository: repository)
    }

    public func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs {
        try await apiClient.getWorkflowJobs(workflowRun: workflowRun)
    }

    public func getWorkflowJobsLog(workflowRun: GitHubWorkflowRun, jobNames: [String], maxLines: Int) async throws -> [String: GitHubWorkflowJobLog] {
        try await apiClient.getWorkflowJobsLog(workflowRun: workflowRun, jobNames: jobNames, maxLines: maxLines)
    }

    public func rerunWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await apiClient.rerunWorkflow(workflowRun: workflowRun)
    }

    public func cancelWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await apiClient.cancelWorkflow(workflowRun: workflowRun)
    }
}
