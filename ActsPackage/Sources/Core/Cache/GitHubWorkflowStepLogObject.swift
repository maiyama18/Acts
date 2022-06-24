import RealmSwift

public class GitHubWorkflowStepLogObject: Object {
    @Persisted(primaryKey: true) public var id: String
    @Persisted public var stepNumber: Int
    @Persisted public var log: String
    @Persisted public var abbreviated: Bool

    public convenience init(id: String, stepNumber: Int, log: String, abbreviated: Bool) {
        self.init()

        self.id = id
        self.stepNumber = stepNumber
        self.log = log
        self.abbreviated = abbreviated
    }
}
