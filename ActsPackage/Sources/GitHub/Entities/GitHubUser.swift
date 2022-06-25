import GitHubAPI

public struct GitHubUser {
    public var login: String
    public var avatarUrl: String

    init(login: String, avatarUrl: String) {
        self.login = login
        self.avatarUrl = avatarUrl
    }

    init(response: GitHubUserResponse) {
        login = response.login
        avatarUrl = response.avatarUrl
    }
}
