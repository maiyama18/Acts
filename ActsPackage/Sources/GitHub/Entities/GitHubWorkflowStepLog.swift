import Core
import GitHubAPI

public struct GitHubWorkflowStepLog {
    public var stepId: String
    public var processedLog: String
    public var abbreviated: Bool

    public init(stepId: String, rawLog: String, maxLines: Int) {
        self.stepId = stepId
        (processedLog, abbreviated) = processLog(rawLog: rawLog, maxLines: maxLines)
    }

    public init(cacheObject: GitHubWorkflowStepLogObject) {
        stepId = cacheObject.stepId
        processedLog = cacheObject.processedLog
        abbreviated = cacheObject.abbreviated
    }

    public func toCacheObject() -> GitHubWorkflowStepLogObject {
        .init(stepId: stepId, processedLog: processedLog, abbreviated: abbreviated)
    }
}

private func processLog(rawLog: String, maxLines: Int) -> (String, Bool) {
    let splittedLog = rawLog
        .split(separator: "\r\n")

    let processedLog = splittedLog
        .suffix(maxLines)
        .map { line -> String in
            // remove date log
            let components = line.split(separator: " ")
            if components.count <= 1 {
                return String(line)
            } else {
                return components.dropFirst().joined(separator: " ")
            }
        }
        .joined(separator: "\r\n")
        .replacingOccurrences(of: "##[group]", with: "> ")
        .replacingOccurrences(of: "##[endgroup]", with: "")

    return (processedLog, splittedLog.count > maxLines)
}
