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
    public var logsUrl: String
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
    // filled when needed
    public var log: String? = nil

    public var id: Int {
        number
    }

    public var hasLog: Bool {
        log != nil
    }
}

public struct GitHubUser: Codable {
    public var login: String
    public var avatarUrl: String
}

public struct GitHubWorkflowJobLog {
    public var stepLogs: [GitHubWorkflowStepLog]
}

public struct GitHubWorkflowStepLog {
    public var stepNumber: Int
    public var log: String
    public var abbreviated: Bool
}
