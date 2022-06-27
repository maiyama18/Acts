import Foundation
import GitHubAPI

public struct GitHubWorkflowRun: Identifiable {
    public var id: Int
    public var title: String
    public var status: GitHubWorkflowStatus
    public var headBranch: String
    public var headCommitMessage: String
    public var createdAt: Date
    public var updatedAt: Date?
    public var htmlUrl: String
    public var jobsUrl: String
    public var logsUrl: String
    public var rerunUrl: String
    public var cancelUrl: String
    public var repository: GitHubRepository

    init(response: GitHubWorkflowRunResponse) {
        id = response.id
        title = "\(response.name) #\(response.runNumber)"
        status = GitHubWorkflowStatus(rawStatus: response.status, conclusion: response.conclusion)
        headBranch = response.headBranch
        headCommitMessage = response.headCommit.message
        createdAt = response.createdAt
        updatedAt = response.updatedAt
        htmlUrl = response.htmlUrl
        jobsUrl = response.jobsUrl
        logsUrl = response.logsUrl
        rerunUrl = response.rerunUrl
        cancelUrl = response.cancelUrl
        repository = GitHubRepository(response: response.repository)
    }

    public var canDownloadLog: Bool {
        switch status {
        case .queued, .inProgress:
            return false
        default:
            return true
        }
    }

    public var formattedRunStatusWithTime: String {
        switch status {
        case .queued:
            return "Queued at \(createdAt.dateTimeFormatted())"
        case .inProgress:
            return "Started at \(createdAt.dateTimeFormatted())"
        case .succeeded:
            if let updatedAt = updatedAt {
                return "Succeeded at \(updatedAt.dateTimeFormatted())"
            } else {
                return "Succeeded"
            }
        case .failed:
            if let updatedAt = updatedAt {
                return "Failed at \(updatedAt.dateTimeFormatted())"
            } else {
                return "Failed"
            }
        case .startupFailed:
            if let updatedAt = updatedAt {
                return "Startup failed at \(updatedAt.dateTimeFormatted())"
            } else {
                return "Startup failed"
            }
        case .cancelled:
            if let updatedAt = updatedAt {
                return "Cancelled at \(updatedAt.dateTimeFormatted())"
            } else {
                return "Cancelled"
            }
        case .skipped:
            if let updatedAt = updatedAt {
                return "Skipped at \(updatedAt.dateTimeFormatted())"
            } else {
                return "Skipped"
            }
        case .timedOut:
            if let updatedAt = updatedAt {
                return "Timed out at \(updatedAt.dateTimeFormatted())"
            } else {
                return "Timed out"
            }
        case let .other(raw: raw):
            return raw
        }
    }
}
