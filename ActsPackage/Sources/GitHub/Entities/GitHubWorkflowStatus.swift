import SwiftUI

public enum GitHubWorkflowStatus {
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

    @ViewBuilder
    public func iconImage() -> some View {
        switch self {
        case .queued:
            Image(systemName: "circle.fill").foregroundColor(.yellow)
                .scaleEffect(0.75)
        case .inProgress:
            Image(systemName: "circle.dashed.inset.filled").foregroundColor(.yellow)
                .rotateForever()
        case .succeeded:
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        case .failed, .timedOut:
            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
        case .skipped:
            Image(systemName: "slash.circle.fill").foregroundColor(.gray)
        case .cancelled, .other:
            Image(systemName: "exclamationmark.circle.fill").foregroundColor(.gray)
        }
    }
}
