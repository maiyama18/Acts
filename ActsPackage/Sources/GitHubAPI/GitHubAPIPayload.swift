import Foundation
import SwiftUI

public enum Status {
    case queued
    case inProgress
    case succeeded
    case failed
    case cancelled
    case skipped
    case timedOut
    case other(raw: String)

    init(rawStatus: String, conclusion: String?) {
        switch rawStatus {
        case "queued":
            self = .queued
        case "in_progress":
            self = .inProgress
        case "completed":
            switch conclusion {
            case "cancelled":
                self = .cancelled
            case "failure":
                self = .failed
            case "success":
                self = .succeeded
            case "skipped":
                self = .skipped
            case "timed_out":
                self = .timedOut
            default:
                self = .other(raw: conclusion ?? "unknown")
            }
        default:
            self = .other(raw: rawStatus)
        }
    }

    public func formatted() -> String {
        switch self {
        case .queued:
            return "Queued"
        case .inProgress:
            return "InProgress"
        case .succeeded:
            return "Succeeded"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        case .skipped:
            return "Skipped"
        case .timedOut:
            return "TimedOut"
        case let .other(raw):
            return raw
        }
    }

    public func iconImage() -> some View {
        switch self {
        case .queued, .inProgress:
            return Image(systemName: "circle.fill").foregroundColor(.yellow)
        case .succeeded:
            return Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        case .failed, .timedOut:
            return Image(systemName: "xmark.circle.fill").foregroundColor(.red)
        case .skipped:
            return Image(systemName: "slash.circle.fill").foregroundColor(.gray)
        case .cancelled, .other:
            return Image(systemName: "exclamationmark.circle.fill").foregroundColor(.gray)
        }
    }
}

public struct GitHubRepository: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var owner: GitHubUser

    public var fullName: String {
        owner.login + "/" + name
    }
}

public struct GitHubWorkflowRuns: Codable {
    public var totalCount: Int
    public var workflowRuns: [GitHubWorkflowRun]
}

public struct GitHubWorkflowRun: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var runNumber: Int
    public var actor: GitHubUser
    public var createdAt: Date
    public var jobsUrl: String
    public var logsUrl: String
    public var rerunUrl: String
    public var cancelUrl: String

    private var status: String
    private var conclusion: String?

    public var runStatus: Status {
        Status(rawStatus: status, conclusion: conclusion)
    }
}

public struct GitHubWorkflowJobs: Codable {
    public var totalCount: Int
    public var jobs: [GitHubWorkflowJob]
}

public struct GitHubWorkflowJob: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var htmlUrl: String
    public var steps: [GitHubWorkflowStep]

    private var status: String
    private var conclusion: String?

    public var jobStatus: Status {
        Status(rawStatus: status, conclusion: conclusion)
    }
}

public struct GitHubWorkflowStep: Codable, Identifiable {
    public enum LogState {
        case notLoaded
        case loading
        case loaded(log: String, abbreviated: Bool)
    }

    public var number: Int
    public var name: String
    public var startedAt: Date
    public var completedAt: Date
    // changed by user interaction
    public var log: LogState = .notLoaded

    private var status: String
    private var conclusion: String?

    public var id: Int {
        number
    }

    public var hasLog: Bool {
        switch log {
        case .loaded:
            return true
        default:
            return false
        }
    }

    public var stepStatus: Status {
        Status(rawStatus: status, conclusion: conclusion)
    }
    
    public var formattedDuration: String {
        formatDuration(startedAt: startedAt, completedAt: completedAt)
    }

    enum CodingKeys: String, CodingKey {
        case number
        case name
        case startedAt
        case completedAt
        case status
        case conclusion
    }
}

public struct GitHubUser: Codable {
    public var login: String
    public var avatarUrl: String
}

public struct GitHubWorkflowJobLog {
    public var stepLogs: [GitHubWorkflowStepLog]
}

public struct GitHubWorkflowStepLog {
    public var stepNumber: Int
    public var log: String
    public var abbreviated: Bool
}

func formatDuration(startedAt: Date, completedAt: Date) -> String {
    let duration = max(0, Int(completedAt.timeIntervalSince1970 - startedAt.timeIntervalSince1970))
    let (h, m, s) = (duration / 3600, (duration % 3600) / 60, (duration % 3600) % 60)
    
    return [
        h > 0 ? "\(h)h" : "",
        m > 0 ? "\(m)m" : "",
        "\(s)s",
    ].joined(separator: " ")
}

