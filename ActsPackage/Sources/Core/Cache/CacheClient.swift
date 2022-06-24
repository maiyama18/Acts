import RealmSwift

public protocol CacheClientProtocol {
    func getGitHubWorkflowStepLogObject(id: Int) -> GitHubWorkflowStepLogObject?
    func saveGitHubWorkflowStepLogObject(id: Int, log: String, abbreviated: Bool)
}

public class CacheClient: CacheClientProtocol {
    public static let shared: CacheClient = .init()

    private let realm: Realm?

    private init() {
        do {
            realm = try Realm(
                configuration: Realm.Configuration(inMemoryIdentifier: "acts")
            )
        } catch {
            logger.error("Failed to initialize realm instance: \(String(describing: error), privacy: .public)")
            realm = nil
        }
    }

    public func getGitHubWorkflowStepLogObject(id: Int) -> GitHubWorkflowStepLogObject? {
        realm?.object(ofType: GitHubWorkflowStepLogObject.self, forPrimaryKey: id)
    }

    public func saveGitHubWorkflowStepLogObject(id: Int, log: String, abbreviated: Bool) {
        realm?.writeAsync {
            let object = GitHubWorkflowStepLogObject(id: id, log: log, abbreviated: abbreviated)
            self.realm?.add(object)
        }
    }
}
