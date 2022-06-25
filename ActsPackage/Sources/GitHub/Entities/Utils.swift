import Foundation

func formatDuration(startedAt: Date?, completedAt: Date?) -> String {
    guard let startedAt = startedAt, let completedAt = completedAt else {
        return ""
    }

    let duration = max(0, Int(completedAt.timeIntervalSince1970 - startedAt.timeIntervalSince1970))
    let (h, m, s) = (duration / 3600, (duration % 3600) / 60, (duration % 3600) % 60)

    return [
        h > 0 ? "\(h)h" : "",
        m > 0 ? "\(m)m" : "",
        "\(s)s",
    ].joined(separator: " ")
}
