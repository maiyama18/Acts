import Foundation
import RealmSwift

public class GitHubWorkflowStepLogObject: Object {
    @Persisted(primaryKey: true) public var stepId: String
    @Persisted public var processedLog: String
    @Persisted public var abbreviated: Bool
    @Persisted public var createdAt: Date

    public convenience init(stepId: String, processedLog: String, abbreviated: Bool, createdAt: Date = Date()) {
        self.init()

        self.stepId = stepId
        self.processedLog = processedLog
        self.abbreviated = abbreviated
        self.createdAt = createdAt
    }
}
