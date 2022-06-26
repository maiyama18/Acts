import GitHubAPI

public struct GitHubRepositories {
    public var usersRepositories: [GitHubRepository]
    public var favoriteRepositories: [GitHubRepository]
    public var hasMoreUsersRepositories: Bool
}
