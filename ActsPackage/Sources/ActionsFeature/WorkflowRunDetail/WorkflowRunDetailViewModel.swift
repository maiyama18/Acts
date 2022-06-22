import AsyncAlgorithms
import Combine
import Core
import GitHubAPI

@MainActor
public final class WorkflowRunDetailViewModel: ObservableObject {
    enum Event {
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var workflowJobs: [GitHubWorkflowJob] = []

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

    func onViewLoaded() async {
        do {
            let response = try await gitHubAPIClient.getWorkflowJobs(workflowRun: workflowRun)
            workflowJobs = response.jobs
        } catch {
            switch error {
            case GitHubAPIError.unauthorized:
                await events.send(.unauthorized)
            case GitHubAPIError.disconnected:
                await events.send(.showError(message: L10n.ErrorMessage.disconnected))
            default:
                await events.send(.showError(message: L10n.ErrorMessage.unexpectedError))
            }
        }
    }
}
