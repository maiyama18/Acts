import RealmSwift

public class FavoriteGitHubRepositoryObject: Object {
    @Persisted(primaryKey: true) public var id: Int
    @Persisted public var name: String
    @Persisted public var ownerLogin: String
    @Persisted public var ownerAvatarUrl: String

    public convenience init(id: Int, name: String, ownerLogin: String, ownerAvatarUrl: String) {
        self.init()

        self.id = id
        self.name = name
        self.ownerLogin = ownerLogin
        self.ownerAvatarUrl = ownerAvatarUrl
    }
}
