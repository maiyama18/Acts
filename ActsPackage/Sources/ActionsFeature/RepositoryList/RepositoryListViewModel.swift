import AsyncAlgorithms
import Combine
import Core
import GitHub
import GitHubAPI

@MainActor
public final class RepositoryListViewModel: ObservableObject {
    enum Event {
        case showSettings
        case showRepository(repository: GitHubRepository)
        case unauthorized
        case showError(message: String)
    }

    @Published private(set) var repositories: [GitHubRepository] = []
    @Published private(set) var showingHUD: Bool = false

    let events: AsyncChannel<Event> = .init()

    private let gitHubUseCase: GitHubUseCaseProtocol
    private let cacheClient: CacheClientProtocol

    public init(gitHubUseCase: GitHubUseCaseProtocol, cacheClient: CacheClientProtocol) {
        self.gitHubUseCase = gitHubUseCase
        self.cacheClient = cacheClient
    }

    func onViewLoaded() async {
        showingHUD = true
        defer {
            showingHUD = false
        }
        do {
            repositories = try await gitHubUseCase.getRepositories()
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

        cacheClient.deletePreviousDaysGitHubWorkflowStepLogObjects()
    }

    func onRepositoryTapped(repository: GitHubRepository) async {
        await events.send(.showRepository(repository: repository))
    }

    func onSettingsButtonTapped() async {
        await events.send(.showSettings)
    }
}
