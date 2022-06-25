import Foundation
import GitHubAPI

public struct GitHubRepository: Identifiable {
    public var id: Int
    public var name: String
    public var owner: GitHubUser

    public var fullName: String {
        "\(owner.login)/\(name)"
    }

    init(response: GitHubRepositoryResponse) {
        id = response.id
        name = response.name
        owner = GitHubUser(response: response.owner)
    }
}
