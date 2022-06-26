import Core
import Foundation
import GitHubAPI

public protocol GitHubUseCaseProtocol {
    func getRepositories(page: Int) async throws -> GitHubRepositories
    func getWorkflowRuns(repository: GitHubRepository) async throws -> [GitHubWorkflowRun]
    func getWorkflowRun(repository: GitHubRepository, runId: Int) async throws -> GitHubWorkflowRun
    func getWorkflowJobs(run: GitHubWorkflowRun) async throws -> [GitHubWorkflowJob]
    func getWorkflowStepLog(step: GitHubWorkflowStep, siblingSteps: [GitHubWorkflowStep], maxLines: Int) async throws -> GitHubWorkflowStepLog?
    func rerunWorkflow(run: GitHubWorkflowRun) async throws
    func cancelWorkflow(run: GitHubWorkflowRun) async throws
}

public actor GitHubUseCase: GitHubUseCaseProtocol {
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

    public func getRepositories(page: Int) async throws -> GitHubRepositories {
        let favoriteRepositoryObjects = try cacheClient.getFavoriteGitHubRepositories()
        let favoriteRepositories = favoriteRepositoryObjects.map { GitHubRepository(object: $0) }
        let favoriteRepositoryIds = Set(favoriteRepositories.map(\.id))

        let usersRepositoryResponses = try await apiClient.getUsersRepositories(page: page)

        return GitHubRepositories(
            usersRepositories: usersRepositoryResponses
                .filter { !favoriteRepositoryIds.contains($0.id) }
                .map { GitHubRepository(response: $0) },
            favoriteRepositories: favoriteRepositories,
            hasMoreUsersRepositories: usersRepositoryResponses.count >= 30
        )
    }

    public func getWorkflowRuns(repository: GitHubRepository) async throws -> [GitHubWorkflowRun] {
        let response = try await apiClient.getWorkflowRuns(repositoryFullName: repository.fullName)
        return response.workflowRuns.map { GitHubWorkflowRun(response: $0) }
    }

    public func getWorkflowRun(repository: GitHubRepository, runId: Int) async throws -> GitHubWorkflowRun {
        let response = try await apiClient.getWorkflowRun(repositoryFullName: repository.fullName, runId: runId)
        return GitHubWorkflowRun(response: response)
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
