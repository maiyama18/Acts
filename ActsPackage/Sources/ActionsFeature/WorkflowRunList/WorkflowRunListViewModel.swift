import AsyncAlgorithms
import Combine
import Core
import GitHub
import GitHubAPI

@MainActor
public final class WorkflowRunListViewModel: ObservableObject {
    enum Event {
        case showWorkflowRun(run: GitHubWorkflowRun)
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var workflowRuns: [GitHubWorkflowRun] = []
    @Published private(set) var showingHUD: Bool = false

    let events: AsyncChannel<Event> = .init()

    private let repository: GitHubRepository
    private let gitHubUseCase: GitHubUseCaseProtocol

    var title: String {
        repository.fullName
    }

    init(
        repository: GitHubRepository,
        gitHubUseCase: GitHubUseCaseProtocol
    ) {
        self.repository = repository
        self.gitHubUseCase = gitHubUseCase
    }

    func onViewLoaded() async {
        showingHUD = true
        defer {
            showingHUD = false
        }

        do {
            workflowRuns = try await gitHubUseCase.getWorkflowRuns(repository: repository)
        } catch {
            await handleGitHubError(error: error)
        }
    }

    func onPullToRefreshed() async {
        do {
            workflowRuns = try await gitHubUseCase.getWorkflowRuns(repository: repository)
        } catch {
            await handleGitHubError(error: error)
        }
    }

    func onWorkflowRunTapped(run: GitHubWorkflowRun) async {
        await events.send(.showWorkflowRun(run: run))
    }

    private func handleGitHubError(error: Error) async {
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
