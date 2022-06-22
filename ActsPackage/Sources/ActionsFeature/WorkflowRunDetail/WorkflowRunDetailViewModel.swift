import AsyncAlgorithms
import Combine
import GitHubAPI

@MainActor
public final class WorkflowRunDetailViewModel: ObservableObject {
    enum Event {}

    let events: AsyncChannel<Event> = .init()

    private let workflowRun: GitHubWorkflowRun
    private let gitHubAPIClient: GitHubAPIClientProtocol

    var title: String {
        "\(workflowRun.name) #\(workflowRun.runNumber)"
    }

    public init(
        workflowRun: GitHubWorkflowRun,
        gitHubAPIClient: GitHubAPIClientProtocol
    ) {
        self.workflowRun = workflowRun
        self.gitHubAPIClient = gitHubAPIClient
    }

    func onViewLoaded() async {}
}
