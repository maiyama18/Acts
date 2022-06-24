import Core
import GitHubAPI

public protocol GitHubUseCaseProtocol {
    func getRepositories() async throws -> [GitHubRepository]
    func getWorkflowRuns(repository: GitHubRepository) async throws -> GitHubWorkflowRuns
    func getWorkflowJobs(workflowRun: GitHubWorkflowRun) async throws -> GitHubWorkflowJobs
    func getWorkflowStepLog(step: GitHubWorkflowStep, logsUrl: String, maxLines: Int) async throws -> GitHubWorkflowStepLog?
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
        var response = try await apiClient.getWorkflowJobs(workflowRun: workflowRun)
        for jobIndex in response.jobs.indices {
            for stepIndex in response.jobs[jobIndex].steps.indices {
                response.jobs[jobIndex].steps[stepIndex].job = response.jobs[jobIndex]
            }
        }
        return response
    }

    public func getWorkflowStepLog(step: GitHubWorkflowStep, logsUrl: String, maxLines: Int) async throws -> GitHubWorkflowStepLog? {
        if let cacheObject = cacheClient.getGitHubWorkflowStepLogObject(id: step.runId) {
            return GitHubWorkflowStepLog(stepNumber: step.number, log: cacheObject.log, abbreviated: cacheObject.abbreviated)
        }

        let response = try await apiClient.getWorkflowJobsLog(logsUrl: logsUrl, maxLines: maxLines)
        guard let stepLogs = response[step.job.name]?.stepLogs else { return nil }

        for stepLog in stepLogs {
            let runId = GitHubWorkflowStep.generateRunId(jobRunId: step.job.runId, stepNumber: stepLog.stepNumber)
            cacheClient.saveGitHubWorkflowStepLogObject(object: stepLog.toCacheObject(id: runId))
        }

        return stepLogs.first(where: { $0.stepNumber == step.number })
    }

    public func rerunWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await apiClient.rerunWorkflow(workflowRun: workflowRun)
    }

    public func cancelWorkflow(workflowRun: GitHubWorkflowRun) async throws {
        try await apiClient.cancelWorkflow(workflowRun: workflowRun)
    }
}
