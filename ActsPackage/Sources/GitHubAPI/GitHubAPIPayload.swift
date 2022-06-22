import Foundation

public struct GitHubRepository: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var owner: GitHubUser

    public var fullName: String {
        owner.login + "/" + name
    }
}

public struct GitHubWorkflowRuns: Codable {
    public var totalCount: Int
    public var workflowRuns: [GitHubWorkflowRun]
}

public struct GitHubWorkflowRun: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var status: String
    public var conclusion: String
    public var actor: GitHubUser
    public var createdAt: Date
}

public struct GitHubUser: Codable {
    public var login: String
    public var avatarUrl: String
}
