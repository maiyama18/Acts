import RealmSwift

public class GitHubWorkflowStepLogObject: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var log: String
    @Persisted var abbreviated: Bool

    public convenience init(id: Int, log: String, abbreviated: Bool) {
        self.init()

        self.id = id
        self.log = log
        self.abbreviated = abbreviated
    }
}
