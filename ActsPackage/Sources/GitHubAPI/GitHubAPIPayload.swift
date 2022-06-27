import Core
import Foundation

public struct GitHubRepositoryResponse: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var owner: GitHubUserResponse
}

public struct GitHubWorkflowRunsResponse: Codable {
    public var totalCount: Int
    public var workflowRuns: [GitHubWorkflowRunResponse]
}

public struct GitHubWorkflowRunResponse: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var runNumber: Int
    public var status: String
    public var conclusion: String?
    public var actor: GitHubUserResponse
    public var createdAt: Date
    public var updatedAt: Date
    public var htmlUrl: String
    public var jobsUrl: String
    public var logsUrl: String
    public var rerunUrl: String
    public var cancelUrl: String
    public var headBranch: String
    public var headCommit: GitHubWorkflowCommitResponse
    public var repository: GitHubRepositoryResponse
}

public struct GitHubWorkflowCommitResponse: Codable {
    public var message: String
}

public struct GitHubWorkflowJobsResponse: Codable {
    public var totalCount: Int
    public var jobs: [GitHubWorkflowJobResponse]
}

public struct GitHubWorkflowJobResponse: Codable, Identifiable {
    public var id: Int
    public var runId: Int
    public var runAttempt: Int
    public var status: String
    public var conclusion: String?
    public var name: String
    public var steps: [GitHubWorkflowStepResponse]
    public var startedAt: Date?
    public var completedAt: Date?
    public var htmlUrl: String
}

public struct GitHubWorkflowStepResponse: Codable {
    public var number: Int
    public var name: String
    public var status: String
    public var conclusion: String?
    public var startedAt: Date?
    public var completedAt: Date?
}

public struct GitHubUserResponse: Codable {
    public var login: String
    public var avatarUrl: String
}

public struct GitHubWorkflowJobLogResponse {
    public var stepLogs: [GitHubWorkflowStepLogResponse]
}

public struct GitHubWorkflowStepLogResponse {
    public var stepNumber: Int
    public var log: String

    public init(stepNumber: Int, log: String) {
        self.stepNumber = stepNumber
        self.log = log
    }
}
