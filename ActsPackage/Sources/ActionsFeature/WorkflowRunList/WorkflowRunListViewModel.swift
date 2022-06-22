import AsyncAlgorithms
import Combine
import Core
import GitHubAPI

@MainActor
public final class WorkflowRunListViewModel: ObservableObject {
    enum Event {
        case showWorkflowRun(workflowRun: GitHubWorkflowRun)
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var workflowRunCount: Int = 0
    @Published private(set) var workflowRuns: [GitHubWorkflowRun] = []

    let events: AsyncChannel<Event> = .init()

    private let repository: GitHubRepository
    private let gitHubAPIClient: GitHubAPIClientProtocol

    var title: String {
        repository.fullName
    }

    init(
        repository: GitHubRepository,
        gitHubAPIClient: GitHubAPIClientProtocol
    ) {
        self.repository = repository
        self.gitHubAPIClient = gitHubAPIClient
    }

    func onViewLoaded() async {
        do {
            let response = try await gitHubAPIClient.getWorkflowRuns(repository: repository)

            workflowRunCount = response.totalCount
            workflowRuns = response.workflowRuns
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

    func onWorkflowRunTapped(workflowRun: GitHubWorkflowRun) async {
        await events.send(.showWorkflowRun(workflowRun: workflowRun))
    }
}
