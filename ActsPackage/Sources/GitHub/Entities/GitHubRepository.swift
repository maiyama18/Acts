import Core
import Foundation
import GitHubAPI
import RealmSwift

public struct GitHubRepository: Identifiable {
    public var id: Int
    public var name: String
    public var owner: GitHubUser

    public var fullName: String {
        "\(owner.login)/\(name)"
    }

    public init(response: GitHubRepositoryResponse) {
        id = response.id
        name = response.name
        owner = GitHubUser(response: response.owner)
    }

    public init(object: FavoriteGitHubRepositoryObject) {
        id = object.id
        name = object.name
        owner = GitHubUser(login: object.ownerLogin, avatarUrl: object.ownerAvatarUrl)
    }

    public func toObject() -> FavoriteGitHubRepositoryObject {
        FavoriteGitHubRepositoryObject(id: id, name: name, ownerLogin: owner.login, ownerAvatarUrl: owner.avatarUrl)
    }
}
