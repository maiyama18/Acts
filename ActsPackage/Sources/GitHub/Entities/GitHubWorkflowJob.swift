import Foundation
import GitHubAPI

public struct GitHubWorkflowJob: Identifiable {
    public var id: Int
    public var runId: Int
    public var runAttempt: Int
    public var name: String
    public var status: GitHubWorkflowStatus
    public var startedAt: Date?
    public var completedAt: Date?
    public var htmlUrl: String
    public var logsUrl: String
    public var steps: [GitHubWorkflowStep]

    init(response: GitHubWorkflowJobResponse, parentRun: GitHubWorkflowRun) {
        id = response.id
        runId = response.runId
        runAttempt = response.runAttempt
        name = response.name
        status = GitHubWorkflowStatus(rawStatus: response.status, conclusion: response.conclusion)
        startedAt = response.startedAt
        completedAt = response.completedAt
        htmlUrl = response.htmlUrl
        logsUrl = parentRun.logsUrl
        steps = response.steps.map { GitHubWorkflowStep(response: $0, runId: response.runId, runAttempt: response.runAttempt, jobId: response.id, jobName: response.name, logsUrl: parentRun.logsUrl) }
    }

    public var formattedJobStatusWithTime: String {
        switch status {
        case .queued:
            if let startedAt = startedAt {
                return "Queued at \(startedAt.dateTimeFormatted())"
            } else {
                return "Queued"
            }
        case .inProgress:
            if let startedAt = startedAt {
                return "Started at \(startedAt.dateTimeFormatted())"
            } else {
                return "Started"
            }
        case .succeeded:
            if let completedAt = completedAt {
                return "Succeeded at \(completedAt.dateTimeFormatted())"
            } else {
                return "Succeeded"
            }
        case .failed:
            if let completedAt = completedAt {
                return "Failed at \(completedAt.dateTimeFormatted())"
            } else {
                return "Failed"
            }
        case .cancelled:
            if let completedAt = completedAt {
                return "Cancelled at \(completedAt.dateTimeFormatted())"
            } else {
                return "Cancelled"
            }
        case .skipped:
            if let completedAt = completedAt {
                return "Skipped at \(completedAt.dateTimeFormatted())"
            } else {
                return "Skipped"
            }
        case .timedOut:
            if let completedAt = completedAt {
                return "Timed out at \(completedAt.dateTimeFormatted())"
            } else {
                return "Timed out"
            }
        case let .other(raw: raw):
            return raw
        }
    }

    public var formattedDuration: String {
        formatDuration(startedAt: startedAt, completedAt: completedAt)
    }
}
