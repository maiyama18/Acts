public struct GitHubRepository: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var owner: GitHubUser
}

public struct GitHubUser: Codable {
    public var login: String
    public var avatarURL: String

    private enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}
