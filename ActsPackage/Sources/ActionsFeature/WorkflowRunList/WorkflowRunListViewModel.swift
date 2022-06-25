import AsyncAlgorithms
import Combine
import Core
import GitHub
import GitHubAPI

@MainActor
public final class WorkflowRunListViewModel: ObservableObject {
    enum Event {
        case showWorkflowRun(workflowRun: GitHubWorkflowRunResponse)
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var workflowRunCount: Int = 0
    @Published private(set) var workflowRuns: [GitHubWorkflowRunResponse] = []

    let events: AsyncChannel<Event> = .init()

    private let repository: GitHubRepositoryResponse
    private let gitHubUseCase: GitHubUseCaseProtocol

    var title: String {
        repository.fullName
    }

    init(
        repository: GitHubRepositoryResponse,
        gitHubUseCase: GitHubUseCaseProtocol
    ) {
        self.repository = repository
        self.gitHubUseCase = gitHubUseCase
    }

    func onViewLoaded() async {
        do {
            let response = try await gitHubUseCase.getWorkflowRuns(repository: repository)

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

    func onWorkflowRunTapped(workflowRun: GitHubWorkflowRunResponse) async {
        await events.send(.showWorkflowRun(workflowRun: workflowRun))
    }
}
