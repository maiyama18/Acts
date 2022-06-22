import AsyncAlgorithms
import Combine
import Core
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

    private let gitHubAPIClient: GitHubAPIClientProtocol
    private let secureStorage: SecureStorageProtocol

    public init(gitHubAPIClient: GitHubAPIClientProtocol, secureStorage: SecureStorageProtocol) {
        self.gitHubAPIClient = gitHubAPIClient
        self.secureStorage = secureStorage
    }

    func onViewLoaded() async {
        showingHUD = true
        defer {
            showingHUD = false
        }
        do {
            repositories = try await gitHubAPIClient.getRepositories()
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

    func onRepositoryTapped(repository: GitHubRepository) async {
        await events.send(.showRepository(repository: repository))
    }

    func onSettingsButtonTapped() async {
        await events.send(.showSettings)
    }
}
