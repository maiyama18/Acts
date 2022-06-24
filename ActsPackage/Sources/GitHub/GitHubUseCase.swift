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
    public static let shared: GitHubUseCase = .init(client: GitHubAPIClient.shared)

    private let client: GitHubAPIClientProtocol

    private init(client: GitHubAPIClientProtocol) {
        self.client = client
    }

    public func getRepositories() async throws -> [GitHubRepository] {
        try await client.getRepositories()
    }

    public func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns {
        try await client.getWorkflowRuns(repository: repository)
    }

    public func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs {
        try await client.getWorkflowJobs(workflowRun: workflowRun)
    }

    public func getWorkflowJobsLog(workflowRun: GitHubWorkflowRun, jobNames: [String], maxLines: Int) async throws -> [String: GitHubWorkflowJobLog] {
        try await client.getWorkflowJobsLog(workflowRun: workflowRun, jobNames: jobNames, maxLines: maxLines)
    }

    public func rerunWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await client.rerunWorkflow(workflowRun: workflowRun)
    }

    public func cancelWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await client.cancelWorkflow(workflowRun: workflowRun)
    }
}
