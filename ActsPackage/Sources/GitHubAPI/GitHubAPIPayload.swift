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
    public var runNumber: Int
    public var status: String
    public var conclusion: String
    public var actor: GitHubUser
    public var createdAt: Date
    public var jobsUrl: String
}

public struct GitHubWorkflowJobs: Codable {
    public var totalCount: Int
    public var jobs: [GitHubWorkflowJob]
}

public struct GitHubWorkflowJob: Codable, Identifiable {
    public var id: Int
    public var name: String
    public var status: String
    public var conclusion: String
    public var steps: [GitHubWorkflowStep]
}

public struct GitHubWorkflowStep: Codable, Identifiable {
    public var number: Int
    public var name: String
    public var status: String
    public var conclusion: String

    public var id: Int {
        number
    }
}

public struct GitHubUser: Codable {
    public var login: String
    public var avatarUrl: String
}
