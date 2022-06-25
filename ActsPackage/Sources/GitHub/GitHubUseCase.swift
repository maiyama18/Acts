import Core
import GitHubAPI

public protocol GitHubUseCaseProtocol {
    func getRepositories() async throws -> [GitHubRepository]
    func getWorkflowRuns(repository: GitHubRepository) async throws -> [GitHubWorkflowRun]
    func getWorkflowJobs(run: GitHubWorkflowRun) async throws -> [GitHubWorkflowJob]
    func getWorkflowStepLog(step: GitHubWorkflowStep, siblingSteps: [GitHubWorkflowStep], maxLines: Int) async throws -> GitHubWorkflowStepLog?
    func rerunWorkflow(run: GitHubWorkflowRun) async throws
    func cancelWorkflow(run: GitHubWorkflowRun) async throws
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
        let response = try await apiClient.getRepositories()
        return response.map { GitHubRepository(response: $0) }
    }

    public func getWorkflowRuns(repository: GitHubRepository) async throws -> [GitHubWorkflowRun] {
        let response = try await apiClient.getWorkflowRuns(repositoryFullName: repository.fullName)
        return response.workflowRuns.map { GitHubWorkflowRun(response: $0) }
    }

    public func getWorkflowJobs(run: GitHubWorkflowRun) async throws -> [GitHubWorkflowJob] {
        let response = try await apiClient.getWorkflowJobs(url: run.jobsUrl)
        return response.jobs.map { GitHubWorkflowJob(response: $0, parentRun: run) }
    }

    public func getWorkflowStepLog(step: GitHubWorkflowStep, siblingSteps: [GitHubWorkflowStep], maxLines: Int) async throws -> GitHubWorkflowStepLog? {
        if let cacheObject = cacheClient.getGitHubWorkflowStepLogObject(stepId: step.id) {
            return GitHubWorkflowStepLog(cacheObject: cacheObject)
        }

        let response = try await apiClient.getWorkflowJobLog(logsUrl: step.logsUrl, jobName: step.jobName)

        let stepLogs: [GitHubWorkflowStepLog] = siblingSteps.compactMap { siblingStep in
            guard let rawLog = response[siblingStep.number] else { return nil }
            return GitHubWorkflowStepLog(stepId: siblingStep.id, rawLog: rawLog, maxLines: maxLines)
        }

        for stepLog in stepLogs {
            cacheClient.saveGitHubWorkflowStepLogObject(object: stepLog.toCacheObject())
        }

        return stepLogs.first(where: { $0.stepId == step.id })
    }

    public func rerunWorkflow(run: GitHubWorkflowRun) async throws {
        try await apiClient.rerunWorkflow(url: run.rerunUrl)
    }

    public func cancelWorkflow(run: GitHubWorkflowRun) async throws {
        try await apiClient.cancelWorkflow(url: run.cancelUrl)
    }
}
