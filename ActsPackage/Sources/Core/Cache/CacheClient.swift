import Foundation
import RealmSwift

public protocol CacheClientProtocol {
    // log cache
    func getGitHubWorkflowStepLogObject(stepId: String) -> GitHubWorkflowStepLogObject?
    func saveGitHubWorkflowStepLogObject(object: GitHubWorkflowStepLogObject)
    func deletePreviousDaysGitHubWorkflowStepLogObjects()

    // favorite repository
    func getFavoriteGitHubRepositories() throws -> [FavoriteGitHubRepositoryObject]
    func saveFavoriteGitHubRepository(object: FavoriteGitHubRepositoryObject) throws
    func deleteFavoriteGitHubRepository(id: Int) throws
}

public class CacheClient: CacheClientProtocol {
    public static let shared: CacheClient = .init()

    private init() {}

    public func getGitHubWorkflowStepLogObject(stepId: String) -> GitHubWorkflowStepLogObject? {
        getInstance()?.object(ofType: GitHubWorkflowStepLogObject.self, forPrimaryKey: stepId)
    }

    public func saveGitHubWorkflowStepLogObject(object: GitHubWorkflowStepLogObject) {
        guard let realm = getInstance() else { return }
        guard realm.object(ofType: GitHubWorkflowStepLogObject.self, forPrimaryKey: object.stepId) == nil else {
            return
        }

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

    public func getFavoriteGitHubRepositories() throws -> [FavoriteGitHubRepositoryObject] {
        let realm = try shouldGetInstance()
        return realm.objects(FavoriteGitHubRepositoryObject.self).map { $0 }
    }

    public func saveFavoriteGitHubRepository(object: FavoriteGitHubRepositoryObject) throws {
        let realm = try shouldGetInstance()
        try realm.write {
            realm.add(object)
        }
    }

    public func deleteFavoriteGitHubRepository(id: Int) throws {
        guard let realm = getInstance() else { return }
        guard let targetRepository = realm.object(ofType: FavoriteGitHubRepositoryObject.self, forPrimaryKey: id) else { return }
        try? realm.write {
            realm.delete(targetRepository)
        }
    }

    private func getInstance() -> Realm? {
        try? Realm(
            configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        )
    }

    private func shouldGetInstance() throws -> Realm {
        try Realm(
            configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        )
    }
}
