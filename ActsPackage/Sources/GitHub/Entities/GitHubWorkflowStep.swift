import Foundation
import GitHubAPI

public struct GitHubWorkflowStep: Identifiable {
    public enum LogState {
        case notLoaded
        case loading
        case loaded(log: String, abbreviated: Bool)
    }

    public var id: String
    public var jobId: Int
    public var number: Int
    public var name: String
    public var jobName: String
    public var status: GitHubWorkflowStatus
    public var startedAt: Date?
    public var completedAt: Date?
    public var logsUrl: String
    public var log: LogState

    init(response: GitHubWorkflowStepResponse, runId: Int, runAttempt: Int, jobId: Int, jobName: String, logsUrl: String) {
        id = "\(runId)-\(runAttempt)-\(jobId)-\(response.number)"
        self.jobId = jobId
        number = response.number
        name = response.name
        self.jobName = jobName
        status = GitHubWorkflowStatus(rawStatus: response.status, conclusion: response.conclusion)
        startedAt = response.startedAt
        completedAt = response.completedAt
        self.logsUrl = logsUrl
        log = .notLoaded
    }

    public var hasLog: Bool {
        switch log {
        case .loaded:
            return true
        default:
            return false
        }
    }

    public var formattedDuration: String {
        formatDuration(startedAt: startedAt, completedAt: completedAt)
    }
}
