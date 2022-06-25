import GitHubAPI

public struct GitHubUser {
    public var login: String
    public var avatarUrl: String

    init(response: GitHubUserResponse) {
        login = response.login
        avatarUrl = response.avatarUrl
    }
}
