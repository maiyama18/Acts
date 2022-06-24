import Foundation
import RealmSwift

public protocol CacheClientProtocol {
    func getGitHubWorkflowStepLogObject(id: String) -> GitHubWorkflowStepLogObject?
    func saveGitHubWorkflowStepLogObject(object: GitHubWorkflowStepLogObject)
    func deletePreviousDaysGitHubWorkflowStepLogObjects()
}

public class CacheClient: CacheClientProtocol {
    public static let shared: CacheClient = .init()

    private init() {}

    public func getGitHubWorkflowStepLogObject(id: String) -> GitHubWorkflowStepLogObject? {
        getInstance()?.object(ofType: GitHubWorkflowStepLogObject.self, forPrimaryKey: id)
    }

    public func saveGitHubWorkflowStepLogObject(object: GitHubWorkflowStepLogObject) {
        guard let realm = getInstance() else { return }
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            logger.error("failed to write to realm: \(String(describing: error), privacy: .public)")
        }
    }

    public func deletePreviousDaysGitHubWorkflowStepLogObjects() {
        guard let realm = getInstance() else { return }
        do {
            try realm.write {
                let previousDaysLogObjects = realm.objects(GitHubWorkflowStepLogObject.self).where {
                    $0.createdAt < Date().addingTimeInterval(-24 * 60 * 60)
                }
                realm.delete(previousDaysLogObjects)
            }
        } catch {
            logger.error("failed to delete realm records: \(String(describing: error), privacy: .public)")
        }
    }

    private func getInstance() -> Realm? {
        try? Realm(
            configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        )
    }
}
