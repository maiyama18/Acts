import Foundation
import GitHubAPI

public struct GitHubWorkflowRun: Identifiable {
    public var id: Int
    public var title: String
    public var status: GitHubWorkflowStatus
    public var createdAt: Date
    public var jobsUrl: String
    public var logsUrl: String
    public var rerunUrl: String
    public var cancelUrl: String
    public var repository: GitHubRepository

    init(response: GitHubWorkflowRunResponse) {
        id = response.id
        title = "\(response.name) #\(response.runNumber)"
        status = GitHubWorkflowStatus(rawStatus: response.status, conclusion: response.conclusion)
        createdAt = response.createdAt
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
}
